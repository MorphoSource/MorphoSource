# @deprecated Use Pages instead 
class DocsController < ApplicationController
  layout 'homepage'

  def survey
    @title = I18n.t("docs.survey.title")
  end
end
