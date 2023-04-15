# frozen_string_literal: true

module Toio
  class LuaGenerator
    def generate
      <<~LUA
        local toio = require("toio")
        local cube = toio.Simulator.new()
        cube:connect()
        cube:move(100, 100, 1000)
        cube:move(0, 0, 1000)
      LUA
    end
  end
end
