# frozen_string_literal: true

module Api
  module Toio
    class CubesController < ApiController
      def lua
        respond_success(content: ::Toio::LuaGenerator.new.generate(messages_params_hash))
      end

      private

      def messages_params_hash
        params[:messages].map do |message|
          { role: message[:role], content: message[:content] }
        end
      end
    end
  end
end
