# This module resolves ARKs and DOIs and redirects to appropriate pages
module Morphosource
  class IdentifierResolverController < ApplicationController
    def resolve_ark
      if !ark_path_valid?
        redirect_to '/', alert: 'ARK path is not valid or application is not configured to resolve ARKs.' and return
      end

      if resolved_path.present?
        redirect_to resolved_path and return
      else
        redirect_to '/', alert: 'Work ID is not valid or work is unavailable.' and return
      end
    end

    def resolve_doi
      if !doi_path_valid?
        redirect_to '/', alert: 'DOI path is not valid or application is not configured to resolve DOIs.' and return
      end

      if !doi_work_id_valid?
        redirect_to '/', alert: 'Media ID is not valid or media is unavailable.' and return
      end

      if doi_path_valid? && doi_work_id_valid?
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

    def resolved_path
      @resolved_path ||= begin
        @work_id = path_split[2][/\d+/]
        if @work_id.present?
          if (work = ActiveFedora::Base.find(ms2_id)).present?
            case work.class.to_s
            when 'Media'
              return main_app.media_showcase_path(id: ms2_id)
            when 'Device'
              return main_app.hyrax_device_path(id: ms2_id)
            when 'BiologicalSpecimen'
              return main_app.specimen_showcase_path(id: ms2_id)        
            when 'CulturalHeritageObject'
              return main_app.cho_showcase_path(id: ms2_id)        
            when 'OrganizationCollection'
              return main_app.organization_collection_path(id: ms2_id)
            end
          end
        end
        nil
      end
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

    def doi_work_id_valid?
      @work_id = path_split[1][/\d+/]
      @work_id.present? && Media.exists?(ms2_id)
    end

    # common utility methods
    def path_split
      @path_split ||= ( params[:identifier] || '' ).split('/')
    end

    def ms2_id
      @ms2_id ||= pad(@work_id)
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