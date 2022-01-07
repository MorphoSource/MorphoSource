module Morphosource
  module Admin
    class ContributorPetitionsController < ApplicationController
      include Morphosource::MessageHelper

      before_action :require_permissions
      with_themed_layout 'morphosource_dashboard'

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'morphosource.admin.contributor_petitions.header'), main_app.admin_contributor_petitions_path
      
        @undecided_petitions = ContributorPetition.where(decision_required: true)
        @decided_petitions = ContributorPetition.where.not(decision_required: true)
      end

      def decide_petition
        if (
          ContributorPetition.exists?(params[:id]) &&
          ( @petition = ContributorPetition.find(params[:id]) ).present?
        )
          if params[:commit].downcase == 'approve'
            set_petition_decision_attributes('approve')
            message_petitioner('approve')
          elsif params[:commit].downcase == 'clear'
            set_petition_decision_attributes('clear')
            message_petitioner('clear')
          elsif params[:commit].downcase == 'deny'
            set_petition_decision_attributes('deny')
            message_petitioner('deny')
          end
        end

        if params[:form_is_previous].present?
          redirect_to main_app.admin_contributor_petitions_previous_path
        else
          redirect_to main_app.admin_contributor_petitions_path
        end
      end

      private 

      def require_permissions
        authorize! :read, :admin_dashboard
      end

      def set_petition_decision_attributes(state)
        raise 'Unacceptable state for contributor petition decision' if !acceptable_states.include?(state)

        @petition.decision_state = state
        @petition.decision_message = petition_params[:decision_message]
        @petition.decision_by = current_user.id
        @petition.send("#{state_to_date_field(state)}=", Time.current)
        @petition.decision_required = false

        if state == 'approve'
          @petition.user.make_contributor
        else
          @petition.user.remove_contributor
        end

        @petition.save!
      end

      def acceptable_states
        ['approve', 'clear', 'deny']
      end

      def state_to_date_field(state)
        "date_#{state_past[state]}"
      end

      def state_past
        {
          'approve' => 'approved',
          'clear' => 'cleared',
          'deny' => 'denied'
        }
      end

      def message_petitioner(state)
        raise 'Unacceptable state for contributor petition message' if !acceptable_states.include?(state)

        additional_msg = ""
        if state == 'approve'
          additional_msg = "This means you should now have contributor and data manager privileges on MorphoSource. You may upload new media, create or participate in projects and teams, and have other users transfer media ownership to you."
        elsif state == 'clear'
          additional_msg = "This means that your application has been temporarily rejected, likely with a request for further or modified information. If a message is present below, you should consult it, as it likely has instructions for you to follow. Please resubmit your application to become a contributor or data manager, making any necessary changes."
        elsif state == 'deny'
          additional_msg = "This means that your application has been rejected. You will not be able to resubmit a contributor application while your application is denied. You should contact the <a href='mailto:morphosource@duke.edu'>MorphoSource administrators</a> to learn what (if anything) may be done to resolve this situation."
        end

        msg = "<p>Your application to become a contributor or data manager on MorphoSource has been #{state_past[state]}. #{additional_msg}</p>"
        msg += "<p>The administrator who decided this application provided the following message: #{petition_params[:decision_message]}</p>" if petition_params[:decision_message].present?
        msg += "<p>Please contact the <a href='mailto:morphosource@duke.edu'>MorphoSource administrators</a> if you have additional questions about this decision.</p>"

        deliver_message(email_sender, @petition.user, msg.html_safe, "Contributor Application #{state_past[state].capitalize}")
      end



      def petition_params
        @petition_params ||= params.fetch(:contributor_petition, {}).permit(:decision_message)
      end
    end
  end
end