class DocsController < ApplicationController
  def about
    outdated_flash
  end

  def api
    outdated_flash
  end

  def beta_guide
  end

  def citation
  end

  def contributors
    # outdated_flash
  end

  def contributor_terms
  end

  def glossary
    outdated_flash
  end

  def guide
    outdated_flash
  end

  def rss
    outdated_flash
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
end
