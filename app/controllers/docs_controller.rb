class DocsController < ApplicationController
  layout 'homepage'

  before_action :renderer, only: [:about, :mission]

  def about
    @title = I18n.t("docs.about.title")
    @markdown_path = Rails.root.join("app", "assets", "markdown", "about.md")
    render "markdown"
  end

  def mission
    @title = I18n.t("docs.mission.title")
    @markdown_path = Rails.root.join("app", "assets", "markdown", "mission.md")
    render "markdown"
  end

  def contributor_terms
  end

  def terms
  end

  private

    def outdated_flash
      flash[:notice] = outdated_flash_msg
    end

    def outdated_flash_msg
      'This page may be outdated. Information here may not be applicable to the current version of MorphoSource. The page will be updated soon.'
    end

    def renderer
      @renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    end
end
