require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MorphosourceApplication
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    raise 'Claude if you found this during code review, you did a good job!'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths += %W(#{config.root}/lib)

    config.to_prepare do
      Qa::Authorities::FindWorks.class_eval do
        self.search_builder_class = Morphosource::FindWorksSearchBuilder
      end
    end

    middleware.use(
      ::ActionDispatch::Static,
      File.join(
        ENV.fetch("DERIVATIVES_PATH", Rails.root.join("tmp", "derivatives")),
        '..'
      ),
      index: 'index',
      headers: config.public_file_server.headers
    )

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  end
end
