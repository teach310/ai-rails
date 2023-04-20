# frozen_string_literal: true

module Toio
  class LuaGenerator
    def generate(src_messages = [])
      response = post_chatgpt(src_messages)
      chatgpt_content = response.dig("choices", 0, "message", "content")
      extract_lua(chatgpt_content)
    end

    def build_messages(src_messages)
      [{ role: 'system', content: system_content }] + src_messages
    end

    def extract_lua(chatgpt_content)
      # 最初の文字がfunctionの時はそのまま返す
      return chatgpt_content if chatgpt_content.start_with?('function')
      
      # 「```」という文字列を含む場合には
      if chatgpt_content.include?('```')
        extracted_lua = extract_lua_from_code_block(chatgpt_content)
        if extracted_lua.present?
          return extracted_lua
        else
          return generate_failed('extract code block failed') # 「'」が文章に入るのを避けるために固定文言返す
        end
      end
      
      generate_failed(chatgpt_content)
    end

    private

    def extract_lua_from_code_block(chatgpt_content)
      regex = /^```.*?\r?\n((.*?\r?\n)*?)```/m;
      m = regex.match(chatgpt_content)
      return m[1] if m
      nil
    end

    def generate_failed(failed_content)
      <<~LUA
        function routine()
          cubeCommand:ShowMessage('generate failed')
          cubeCommand:ShowMessage(\'#{failed_content}\')
        end
      LUA
    end

    def post_chatgpt(src_messages)
      client.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: build_messages(src_messages),
          temperature: 0.2
        })
    end

    def system_content
      <<~CONTENT
        You are code generator of Lua.

        ## Output Format
        
        function routine()
          {write command here}
        end

        ### Coordinate
        origin is left bottom.

        x: left 45 ~ right 455
        y: bottom 45 ~ top 455

        ## Command List

        cubeCommand:ShowMessage(content)

        // left       | left motor speed  | range (0~100)
        // right      | right motor speed | range (0~100)
        // durationMs | duration ms       | range (0~2550)
        cubeCommand:Move(id, left, right, durationMs)

        // seconds | duration seconds | range (0.1~30.0)
        coroutine.yield(CS.UnityEngine.WaitForSeconds(seconds))

        // Move to target world position
        coroutine.yield(cubeCommand:Navi2TargetCoroutine('cube1', x, y))

        // Look to target rotation
        // deg: 0~359
        // example) look to right: 0, look to top: -90
        coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube1', deg))
        
        ## Example1 move by motor speed

        function routine()
          cubeCommand:ShowMessage('start!')
          cubeCommand:Move('cube1', 50, -50, 100)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(1))
          cubeCommand:Move('cube1', 50, -50, 100)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(1))
          cubeCommand:ShowMessage('end!')
        end

        ## Example2 set start position

        function routine()
          cubeCommand:ShowMessage('Go to start position (=center) and look forward')
          coroutine.yield(cubeCommand:Navi2TargetCoroutine('cube1', 250, 250))
          coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube1', -90))
          cubeCommand:ShowMessage('Ready!')
        end
      CONTENT
    end

    def client
      @client ||= OpenAI::Client.new
    end
  end
end
