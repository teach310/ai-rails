# frozen_string_literal: true

module Toio
  class LuaGenerator
    def generate
      <<~LUA
        function routine()
          cubeCommand:ShowMessage('動きます!')
          cubeCommand:Move('cube1', 50, -50, 100)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(1))
          cubeCommand:Move('cube1', 50, -50, 100)
          coroutine.yield(CS.UnityEngine.WaitForSeconds(1))
          cubeCommand:ShowMessage('終了！')
        end
      LUA
    end
  end
end
