# frozen_string_literal: true

module Toio
  class LuaGenerator
    def generate(src_messages = [])
      response = post_chatgpt(src_messages)
      chatgpt_content = response.dig("choices", 0, "message", "content")
      replace_atan2_to_atan(extract_lua(chatgpt_content)).tap do |lua|
        Rails.logger.info lua
      end
    end

    def build_messages(src_messages)
      [{ role: 'system', content: system_content }] + src_messages
    end

    def extract_lua(chatgpt_content)
      # 最初の文字がfunctionの時はそのまま返す
      return chatgpt_content if chatgpt_content.start_with?('function') || chatgpt_content.start_with?('local')
      
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

    def replace_atan2_to_atan(lua)
      lua.gsub('math.atan2', 'math.atan')
    end

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

        when you move multiple cubes, normaly you should move cubes parallel.

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
        // return null
        cubeCommand:Move(id, left, right, durationMs)

        // seconds | duration seconds | range (0.1~30.0)
        // return IEnumerator
        CS.UnityEngine.WaitForSeconds(seconds)

        // Move to target world position
        // return CSharp IEnumerator
        cubeCommand:Navi2TargetCoroutine(id, x, y)

        // Look to target rotation
        // deg: 0~359
        // return CSharp IEnumerator
        // example) look to right: 0, look to top: 90
        cubeCommand:Rotate2DegCoroutine(id, deg)

        cubeCommand:GetCubePosX(id)
        cubeCommand:GetCubePosY(id)

        // wait until coroutine finished
        coroutine.yield(IEnumerator)
        
        // Start Coroutine Use this command to run coroutine parallel
        // return CSharp IEnumerator
        startCoroutine(IEnumerator or function)

        ## Example move by motor speed

        ```
        function routine()
          cubeCommand:ShowMessage('start!')
          cubeCommand:Move('cube1', 50, -50, 500)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(1))
          cubeCommand:Move('cube1', 50, -50, 500)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(1))
          cubeCommand:ShowMessage('end!')
        end
        ```

        ## Example spin
        
        ```
        function routine()
          cubeCommand:Move('cube1', 60, -60, 1000)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(0.2))
        end
        ```

        ## Example go to start position

        ```
        function routine()
          cubeCommand:ShowMessage('Go to start position and look forward')
          coroutine.yield(cubeCommand:Navi2TargetCoroutine('cube1', 250, 250))
          coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube1', -90))
          cubeCommand:ShowMessage('Ready!')
        end
        ```

        ## Example move each cube parallel

        ```
        function routine()
          cubeCommand:ShowMessage('move cube1 and cube2')
          coroutine1 = startCoroutine(cubeCommand:Navi2TargetCoroutine('cube1', 100, 400))
          coroutine2 = startCoroutine(cubeCommand:Navi2TargetCoroutine('cube2', 100, 100))
          coroutine.yield(coroutine1)
          coroutine.yield(coroutine2)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(0.5))
          cubeCommand:ShowMessage('Finish!')
        end
        ```

        ## Example go to start position each cube

        ```
        function routine()
          cubeCommand:ShowMessage('Go to start position and look forward')
          coroutine1 = startCoroutine(cubeCommand:Navi2TargetCoroutine('cube1', 350, 250))
          coroutine2 = startCoroutine(cubeCommand:Navi2TargetCoroutine('cube2', 150, 250))
          coroutine.yield(coroutine1)
          coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube1', -90))
          coroutine.yield(coroutine2)
          coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube2', -90))
          coroutine.yield(CS.UnityEngine.WaitForSeconds(0.5))
          cubeCommand:ShowMessage('Finish!')
        end
        ```

        ## Example move each cube parallel and rotate

        ```
        function routine()
          cubeCommand:ShowMessage('move cube1 and cube2 and look next point')
          coroutine1 = startCoroutine(cubeCommand:Navi2TargetCoroutine('cube1', 100, 400))
          coroutine2 = startCoroutine(cubeCommand:Navi2TargetCoroutine('cube2', 100, 100))
          coroutine.yield(coroutine1)
          coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube1', 0))
          coroutine.yield(coroutine2)
          coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube2', -90))
          coroutine.yield(CS.UnityEngine.WaitForSeconds(0.5))
          cubeCommand:ShowMessage('Finish!')
        end
        ```

        ## Example start lua coroutine

        ```
        function routine()
          cubeCommand:ShowMessage('Start!')
          csCoroutine = startCoroutine(showIdLater, 'Hello')
          coroutine.yield(csCoroutine)
          coroutine1 = startCoroutine(cubeCommand:Navi2TargetCoroutine('cube1', 100, 100))
          coroutine.yield(coroutine1)
          cubeCommand:ShowMessage('Finished!')
        end

        function showIdLater(id)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(0.5))
          cubeCommand:ShowMessage(id)
        end
        ```

        ## Restrictions

        dont use 「while true」to avoide infinite loop
      CONTENT
    end

    def client
      @client ||= OpenAI::Client.new
    end
  end
end
