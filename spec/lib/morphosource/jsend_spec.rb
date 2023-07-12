# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Jsend do

  subject { Class.new { include Morphosource::Jsend } }

  describe '.jsend_success' do
    let(:data)      {
                      {
                        'data' => {
                          'posts' =>
                            [{ 'id' => 1, 'title' => 'A blog post', 'body' => 'Some useful content' },
                             { 'id' => 2, 'title' => 'Another blog post', 'body' => 'More content' }]
                        }
                      }
                    }
    let(:response) {
                      {
                        status: :success,
                        data: data
                      }
                    }

    it { expect(subject.jsend_success(data)).to eq(response) }
  end

  describe '.jsend_error' do
    let(:e) { RestClient::Exception.new }

    context 'no message is passed as an argment' do
      let(:response)  {
                        {
                          status: :error,
                          message: e.message
                        }
                      }

      it { expect(subject.jsend_error(e)).to eq(response) }
    end

    context 'custom message is passed as an argument' do
      let(:message)   { 'A custom error message' }
      let(:response)  {
                        {
                          status: :error,
                          message: message
                        }
                      }

      it { expect(subject.jsend_error(e, message)).to eq(response) }
    end

    context 'optional code and data are passed as arguments' do
      let(:code)      { 555 }
      let(:data)      { { 'error_code' => code } }
      let(:response)  {
                        {
                          status: :error,
                          message: e.message,
                          code: code,
                          data: data
                        }
                      }

      it { expect(subject.jsend_error(e, nil, code, data)).to eq(response) }
    end
  end

  describe '.jsend_fail' do
    let(:data)      { { 'fail' => { 'title' => 'A title is required' } } }
    let(:response)  {
                      {
                        status: :fail,
                        data: data
                      }
                    }

    it { expect(subject.jsend_fail(data)).to eq(response) }
  end
end
