# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Toio::LuaGenerator, type: :model do
  let(:generator) { described_class.new }

  describe '#build_messages' do
    let(:src_messages) do
      [{ role: 'user', content: '前に2秒進んで' }]
    end

    it 'systemと結合したものを返す' do
      got = generator.build_messages(src_messages)
      expect(got.size).to eq 2
    end
  end
end