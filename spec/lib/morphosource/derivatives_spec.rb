require 'rails_helper'

RSpec.describe Morphosource::Derivatives, :skiptravis => true do
	subject { described_class.blender_path }

	it { is_expected.to eq(Hyrax.config.blender_path) }
end