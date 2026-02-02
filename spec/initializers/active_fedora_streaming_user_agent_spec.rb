# frozen_string_literal: true

require "rails_helper"
require "active_fedora/file/streaming"

RSpec.describe "ActiveFedora streaming User-Agent" do
  let(:ua) { "MorphoSource/5-test" }
  let(:uri) { URI("https://example.org/file") }

  before do
    allow(Hyrax.config).to receive(:remote_request_headers).and_return({ "User-Agent" => ua })
    load Rails.root.join("config/initializers/active_fedora_streaming_user_agent.rb")

    stub_const("DummyStreaming", Class.new do
      include ActiveFedora::File::Streaming

      attr_reader :last_headers, :uri

      def initialize(uri)
        @uri = uri
      end

      def open(_uri, headers:, &block)
        @last_headers = headers
        block.call("chunk") if block
      end
    end)
  end

  it "adds the configured User-Agent header to streaming requests" do
    dummy = DummyStreaming.new(uri)
    chunks = []
    dummy.each { |chunk| chunks << chunk }

    expect(chunks).to eq(["chunk"])
    expect(dummy.last_headers).to include("User-Agent" => ua)
  end
end
