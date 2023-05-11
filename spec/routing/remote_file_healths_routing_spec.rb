require "rails_helper"

RSpec.describe Morphosource::Admin::RemoteFileHealthsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/admin/remote_file_health").to route_to("morphosource/admin/remote_file_healths#index")
    end

    it "routes to #index" do
      expect(:get => "/admin/remote_file_health/verify_all").to route_to("morphosource/admin/remote_file_healths#verify_all")
    end

    it "routes to #index" do
      expect(:get => "/admin/remote_file_health/verify_media/1").to route_to("morphosource/admin/remote_file_healths#verify_media", :id => "1")
    end
 end
end
