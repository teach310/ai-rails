# frozen_string_literal: true

module Toio
  class LuaGenerator
    def generate(src_messages = [])
      response = post_chatgpt(src_messages)
      response.dig("choices", 0, "message", "content")
    end

    def build_messages(src_messages)
      [{ role: 'system', content: system_content }] + src_messages
    end

    private

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

        ## Command List

        cubeCommand:ShowMessage(content)

        // left       | left motor speed  | range (0~100)
        // right      | right motor speed | range (0~100)
        // durationMs | duration ms       | range (0~2550)
        cubeCommand:Move(id, left, right, durationMs)

        // seconds | duration seconds | range (0.1~30.0)
        coroutine.yield(CS.UnityEngine.WaitForSeconds(seconds))

        ## Example

        function routine()
          cubeCommand:ShowMessage('動きます!')
          cubeCommand:Move('cube1', 50, -50, 100)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(1))
          cubeCommand:Move('cube1', 50, -50, 100)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(1))
          cubeCommand:ShowMessage('終了！')
        end
      CONTENT
    end

    def client
      @client ||= OpenAI::Client.new
    end
  end
end
