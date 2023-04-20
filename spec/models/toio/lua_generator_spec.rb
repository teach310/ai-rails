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

  describe '#extract_lua' do
    subject { generator.extract_lua(chatgpt_content) }

    context '最初の文字がfunctionの時' do
      let(:chatgpt_content) do
        <<~CONTENT
          function routine()
            cubeCommand:ShowMessage('Go to start position (=center) and look forward')
            coroutine.yield(cubeCommand:Navi2TargetCoroutine('cube1', 250, 250))
            coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube1', -90))
            cubeCommand:ShowMessage('Ready!')
          end
        CONTENT
      end

      it { is_expected.to eq chatgpt_content }
    end

    context '「```」という文字列で囲まれている場合' do
      let(:chatgpt_content) do
        <<~CONTENT
          To look to the top, you can use the `Rotate2DegCoroutine` command with a degree value of -90. Here's an example:

          ```
          function routine()
            cubeCommand:ShowMessage('Looking to the top')
            coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube1', -90))
            cubeCommand:ShowMessage('Done')
          end
          ```
        CONTENT
      end

      it 'コードブロックを抽出して返す' do
        is_expected.to eq <<~CONTENT
          function routine()
            cubeCommand:ShowMessage('Looking to the top')
            coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube1', -90))
            cubeCommand:ShowMessage('Done')
          end
        CONTENT
      end
    end

    context '「```」という文字列があって囲まれていない場合' do
      let(:chatgpt_content) do
        <<~CONTENT
          To look to the top, you can use the `Rotate2DegCoroutine` command with a degree value of -90. Here's an example:

          ```
          function routine()
            cubeCommand:ShowMessage('Looking to the top')
            coroutine.yield(cubeCommand:Rotate2DegCoroutine('cube1', -90))
            cubeCommand:ShowMessage('Done')
        CONTENT
      end

      it '失敗' do
        is_expected.to eq <<~CONTENT
          function routine()
            cubeCommand:ShowMessage('generate failed')
            cubeCommand:ShowMessage('extract code block failed')
          end
        CONTENT
      end
    end

    context 'それ以外の場合' do
      let(:chatgpt_content) { 'hoge' }

      it '失敗' do
        is_expected.to eq <<~CONTENT
          function routine()
            cubeCommand:ShowMessage('generate failed')
            cubeCommand:ShowMessage('hoge')
          end
        CONTENT
      end
    end
  end
end
