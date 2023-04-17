# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Toio::Cubes API', type: :request do
  describe 'POST /api/toio/cubes/lua' do
    subject { post '/api/toio/cubes/lua', params: request_params }
    let(:request_params) { {} }
    let(:json_response) { JSON.parse(response.body)['data'] }

    context '正常系' do
      it do
        subject
        expect(response).to have_http_status(:success)
      end
    end
  end
end
