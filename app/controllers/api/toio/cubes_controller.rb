# frozen_string_literal: true

module Api
  module Toio
    class CubesController < ApiController
      def lua
        respond_success(content: ::Toio::LuaGenerator.new.generate)
      end
    end
  end
end
