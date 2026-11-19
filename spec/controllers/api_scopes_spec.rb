require 'rails_helper'

# Which OAuth scope grants access to each REST API endpoint.
#
# API keys work on every endpoint below. OAuth access tokens work only where they hold
# the listed scope. If you add or change an `api_auth` declaration, update this map so
# API key and OAuth access stay in sync deliberately.
RSpec.describe 'REST API OAuth scopes' do
  let(:catalog_rule) { [:optional, 'api:read', %i[index show show_file_metadata]] }
  let(:export_rule) do
    [:optional, 'api:reports', %i[media_export objects_export media_download_counts media_downloads media_requests]]
  end

  let(:expected_rules) do
    {
      'MediaCatalogController' => [catalog_rule, [:optional, 'api:read', %i[index_for_object]]],
      'ObjectsCatalogController' => [catalog_rule, [:optional, 'api:read', %i[show_by_occurrence_id]]],
      'CollectionsCatalogController' => [catalog_rule],
      'OrganizationsCatalogController' => [catalog_rule],
      'MediaListsCatalogController' => [catalog_rule],
      'Morphosource::ManifestsController' => [
        [:required, 'api:read', %i[get_manifest_link]],
        [:optional, 'api:read', %i[show]]
      ],
      'Morphosource::DerivativeDownloadsController' => [[:optional, 'api:download', []]],
      'Morphosource::MediaAPIDownloadsController' => [
        [:optional, 'api:download', %i[download]],
        [:required, 'api:download', %i[api_generate_download]]
      ],
      'Morphosource::Collections::TeamsController' => [export_rule, [:optional, 'api:reports', %i[media_projects]]],
      'Hyrax::UsersController' => [[:optional, nil, %i[index show]]]
    }
  end

  def rules_for(controller)
    controller.api_auth_rules.map { |r| [r[:mode], r[:scope], r[:only]] }
  end

  let(:api_controllers) do
    Dir[Rails.root.join('app/controllers/**/*_controller.rb')].sort.each { |f| require_dependency f }
    # Only real, named controllers: rspec-rails anonymous controllers report a name
    # ("AnonymousController") that isn't a constant.
    ActionController::Base.descendants.select do |c|
      c.name && c.name.safe_constantize == c && c.respond_to?(:api_auth_rules) && c.api_auth_rules.any?
    end
  end

  it 'matches the expected scope for each listed controller' do
    expected_rules.each do |name, expected|
      expect(rules_for(name.constantize)).to match_array(expected), "unexpected api_auth rules for #{name}"
    end
  end

  it 'gives every other collection controller only the export rule' do
    others = api_controllers.select { |c| c < Morphosource::CollectionsControllerExportBehavior } -
             expected_rules.keys.map(&:constantize)
    expect(others).not_to be_empty
    others.each do |controller|
      expect(rules_for(controller)).to eq([export_rule]), "unexpected api_auth rules for #{controller.name}"
    end
  end

  it 'lists every controller that declares api_auth' do
    unlisted = api_controllers.reject do |c|
      expected_rules.key?(c.name) ||
        c < Morphosource::CollectionsControllerExportBehavior ||
        inherits_rules_only?(c)
    end
    expect(unlisted.map(&:name)).to be_empty,
      "add these controllers to expected_rules in this spec: #{unlisted.map(&:name).join(', ')}"
  end

  # A subclass that declares no api_auth of its own (e.g. Morphosource::DataManagersController
  # < Hyrax::UsersController) is covered by its parent's entry.
  def inherits_rules_only?(controller)
    parent = controller.superclass
    parent.respond_to?(:api_auth_rules) && controller.api_auth_rules == parent.api_auth_rules
  end

  it 'uses every configured api scope' do
    used = api_controllers.flat_map { |c| c.api_auth_rules.map { |r| r[:scope] } }.compact.uniq
    expect(used).to match_array(Morphosource::RestApiBehavior.api_scopes)
  end

  describe 'api_auth declarations' do
    it 'rejects unknown scopes' do
      expect {
        Class.new(ApplicationController) { include Morphosource::RestApiBehavior; api_auth :optional, scope: 'api:raed' }
      }.to raise_error(ArgumentError, /Unknown API scope/)
    end

    it 'rejects unknown modes' do
      expect {
        Class.new(ApplicationController) { include Morphosource::RestApiBehavior; api_auth :sometimes, scope: 'api:read' }
      }.to raise_error(ArgumentError, /mode/)
    end

    it 'requires a scope to be stated' do
      expect {
        Class.new(ApplicationController) { include Morphosource::RestApiBehavior; api_auth :optional }
      }.to raise_error(ArgumentError, /scope/)
    end
  end
end

RSpec.describe 'API-key-only endpoints', type: :controller do
  controller(ApplicationController) do
    include Morphosource::RestApiBehavior
    api_auth :optional, scope: nil, only: :index

    def index
      render json: { ok: true }
    end
  end

  let(:user) { FactoryBot.create(:confirmed_user) }
  let(:application) do
    Doorkeeper::Application.create!(name: 'Partner app', redirect_uri: 'https://partner.example.org/callback')
  end

  it 'rejects OAuth access tokens, whatever their scopes' do
    token = Doorkeeper::AccessToken.create!(
      application: application, resource_owner_id: user.id, scopes: 'openid api:read api:download api:reports',
      expires_in: 2.hours
    )
    request.headers['Authorization'] = "Bearer #{token.plaintext_token}"
    get :index
    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)['error']).to eq('insufficient_scope')
    expect(response.headers['WWW-Authenticate']).to include('does not accept OAuth access tokens')
  end

  it 'still serves API key requests' do
    request.headers['Authorization'] = user.token
    get :index
    expect(response).to have_http_status(:ok)
  end
end
