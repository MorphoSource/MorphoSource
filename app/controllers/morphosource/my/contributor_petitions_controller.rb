module Morphosource
  module My
    class ContributorPetitionsController < ApplicationController
      load_and_authorize_resource except: [:create]
      with_themed_layout 'morphosource_dashboard'

      def index
        if current_user.contributor? || current_user.admin?
          flash[:notice] = 'Current user already has contributor status or is ineligible to apply for contributor status.'
          redirect_to main_app.root_url and return
        end

        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'morphosource.dashboard.my.contributor_petitions.header'), main_app.user_contributor_petition_path

        if ContributorPetition.exists?(user: current_user)
          @petition = ContributorPetition.where(user: current_user).first

          if @petition.decision_state == 'approve'
            flash[:notice] = 'Your contributor application has already been approved, and you should have contributor privileges. If you do not, please contact the MorphoSource admins.'
            redirect_to main_app.root_url and return
          end
        else
          @petition = ContributorPetition.new
        end

        fill_user_fields
      end

      def create
        prepare_params
        ( redirect_to main_app.root_url and return ) unless validate_create
        @petition = ContributorPetition.new(petition_params)
        require_petition_decision
        
        if @petition.save
          update_user
          redirect_to main_app.user_contributor_petition_path and return
        else
          render :index, status: :unprocessable_entity
        end
      end

      def update
        if (
          ContributorPetition.exists?(params[:id]) &&
          ( @petition = ContributorPetition.find(params[:id]) ).present?
        )
          prepare_params
          ( redirect_to main_app.root_url and return ) unless validate_update
          require_petition_decision
          if @petition.update(petition_params)
            update_user
            redirect_to main_app.user_contributor_petition_path and return
          else
            render :index, status: :unprocessable_entity
          end
        end

        redirect_to main_app.user_contributor_petition_path and return
      end

      private

      def fill_user_fields
        user_to_petition_fields.each do |user_field, petition_field|
          if current_user.send(user_field).present?
            @petition.send("#{petition_field}=", current_user.send(user_field))
          end
        end
      end

      def user_to_petition_fields
        {
          :affiliation => :user_affiliation,
          :department => :user_department,
          :demographics => :user_demographics,
          :other_demographics => :user_demographics_other,
        }
      end

      def prepare_params
        p = params[:contributor_petition]
        p[:user_id] = current_user.id
        if (
          p[:user_demographics_other].present? && 
          !p[:user_demographics].include?(p[:user_demographics_other])
        )
          p[:user_demographics] = ( p[:user_demographics].presence || [] ) + Array(p[:user_demographics_other])
        end
      end

      def validate_create
        validate_required_params
        validate_terms_agreed
      end

      def validate_update
        validate_required_params
        validate_terms_agreed && validate_not_denied
      end

      def validate_required_params
        params.fetch(:contributor_petition, {}).require(required_params)
      end

      def validate_terms_agreed
        if ActiveModel::Type::Boolean.new.cast(
          params.fetch(:contributor_petition, {})[:terms_agree]
        ) != true
          flash[:notice] = 'To submit contributor application, you must agree to the terms!'
          return false
        else
          return true
        end
      end

      def validate_not_denied
        if @petition.decision_state == 'deny'
          flash[:notice] = 'Denied contributor applications may not be resubmitted!'
          return false
        else
          return true
        end
      end

      def require_petition_decision
        @petition.decision_required = true
      end

      def petition_params
        @petition_params ||= params.fetch(:contributor_petition, {}).permit(
          :user_id, :reason, :user_affiliation, :user_department, 
          :user_demographics_other,:user_advisor, :contribution_amount, 
          :terms_agree, :user_demographics => []
        )
      end

      def required_params
        [:user_id, :reason, :user_affiliation, :user_department, :user_demographics, :contribution_amount, :terms_agree]
      end

      def update_user
        user_to_petition_fields.each do |user_field, petition_field|
          if @petition.user.send(user_field) != @petition.send(petition_field)
            @petition.user.send("#{user_field}=", @petition.send(petition_field))
          end
        end
        @petition.user.save!
      end
    end
  end
end