require 'rails_helper'

RSpec.describe Morphosource::DownloadsController do
	routes { Hyrax::Engine.routes }

	describe "derivative_download_options" do
    context "when file returned is png" do
    	before do
      	allow(controller).to receive(:default_file).and_return 'world.png'
    	end

    	subject { controller.send(:derivative_download_options) }

    	it { is_expected.to eq(disposition: 'inline', type: 'image/png') }
    end

    context "when file returned is glb" do
    	before do
      	allow(controller).to receive(:default_file).and_return 'world.glb'
    	end
    	
    	subject { controller.send(:derivative_download_options) }

    	it { is_expected.to eq(disposition: 'inline', type: 'model/gltf+json') }
    end
  end
end