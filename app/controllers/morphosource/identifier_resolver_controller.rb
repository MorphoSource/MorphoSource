# This module resolves ARKs and DOIs and redirects to appropriate pages
module Morphosource
  class IdentifierResolverController < ApplicationController
    def resolve_ark
      if !ark_path_valid?
        redirect_to '/', alert: 'ARK path is not valid or application is not configured to resolve ARKs.' and return
      end

      if !ark_media_id_valid?
        redirect_to '/', alert: 'Media ID is not valid or media is unavailable.' and return
      end

      if ark_path_valid? && ark_media_id_valid?
        redirect_to main_app.media_showcase_path(ms2_id) and return
      end
    end

    def resolve_doi
      if !doi_path_valid?
        redirect_to '/', alert: 'DOI path is not valid or application is not configured to resolve DOIs.' and return
      end

      if !doi_media_id_valid?
        redirect_to '/', alert: 'Media ID is not valid or media is unavailable.' and return
      end

      if doi_path_valid? && doi_media_id_valid?
        redirect_to main_app.media_showcase_path(ms2_id) and return
      end
    end

    private 

    # ark methods

    def ark_path_valid?
      path_split.present? && path_split.count == 3 &&
        ark_shoulder_split.present? && ark_shoulder_split.count == 3 &&
        path_split[0].downcase == ark_shoulder_split[1].downcase &&
        path_split[1].downcase == ark_shoulder_split[2].downcase
    end

    # Expects env var EZID_DEFAULT_SHOULDER to be present and in form "ark:/00000/00"
    def ark_shoulder_split
      @ark_shoulder_split ||= ( ENV['EZID_DEFAULT_SHOULDER'] || '' ).split('/')
    end

    def ark_media_id_valid?
      @media_id = path_split[2][/\d+/]
      @media_id.present? && Media.exists?(ms2_id)
    end

    # doi methods    

    def doi_path_valid?
      path_split.present? && path_split.count == 2 &&
        doi_shoulder_split.present? && doi_shoulder_split.count == 2 &&
        params[:doi_tag].downcase == doi_shoulder_split[0].downcase &&
        path_split[0].downcase == doi_shoulder_split[1].downcase
    end

    # Expects env var CROSSREF_DOI_SHOULDER to be present and in form "00.00000/00"
    def doi_shoulder_split
      @doi_shoulder_split ||= ( ENV['CROSSREF_DOI_SHOULDER'] || '' ).split('/')
    end

    def doi_media_id_valid?
      @media_id = path_split[1][/\d+/]
      @media_id.present? && Media.exists?(ms2_id)
    end


    # common utility methods
    def path_split
      @path_split ||= ( params[:identifier] || '' ).split('/')
    end

    def ms2_id
      @ms2_id ||= pad(@media_id)
    end

    def pad(id)
      if id.length < 9
        id = ("0" * (9 - id.length)) + id
      else
        id
      end
    end
  end
end