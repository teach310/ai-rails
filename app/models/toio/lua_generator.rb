# frozen_string_literal: true

module Toio
  class LuaGenerator
    def generate
      <<~LUA
        cubeCommand:Move('cube1', 50, -50, 100)
      LUA
    end
  end
end
