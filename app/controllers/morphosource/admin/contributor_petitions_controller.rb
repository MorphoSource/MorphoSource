module Morphosource
  module Admin
    class ContributorPetitionsController < Morphosource::ItemtableController
      include Morphosource::MessageHelper

      before_action :require_permissions

      before_action :get_current_items, only: [:current_applications]
      before_action :get_previous_items, only: [:previous_applications, :update_application_decision]
      before_action :split_filter_user_keys, only: [:current_applications, :previous_applications]
      before_action :filter_items, only: [:current_applications, :previous_applications, :update_application_decision]
      before_action :paginate_items, only: [:current_applications, :previous_applications, :update_application_decision]

      PAGE_TITLE = I18n.t("morphosource.admin.contributor_petitions.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.admin.contributor_petitions.page_description")

      def current_applications
        @tab = 'current'
        @decided_petition_count = ContributorPetition.where.not(decision_required: true).count
        @undecided_petition_count = @items.count
        @item_count = @items.count
        @search = true if search_form_present?
        respond_to do |format|
          format.html do 
            render('index')
          end
          format.csv  do
            prepare_items_for_csv
            render('index')
          end
        end
      end

      def previous_applications
        @tab = 'previous'
        @decided_petition_count = @items.count
        @undecided_petition_count = ContributorPetition.where(decision_required: true).count
        @item_count = @items.count
        @search = true if search_form_present?
        respond_to do |format|
          format.html do 
            render('index')
          end
          format.csv  do
            prepare_items_for_csv
            render('index')
          end
        end
      end

      def update_application_decision
        @tab = 'previous'
        @decided_petition_count = ContributorPetition.where.not(decision_required: true).count
        @undecided_petition_count = ContributorPetition.where(decision_required: true).count
        if ContributorPetition.exists?(params[:id])
          @petition = ContributorPetition.find(params[:id])
        end
        @item_count = @items.count
        @search = true if search_form_present?
        respond_to do |format|
          format.html do 
            render('index')
          end
          format.csv  do
            prepare_items_for_csv
          end
        end
      end

      def decide_petition
        if (
          ContributorPetition.exists?(params[:id]) &&
          ( @petition = ContributorPetition.find(params[:id]) ).present?
        )
          if params[:commit].downcase == 'approve'
            set_petition_decision_attributes('approve')
            message_petitioner('approve')
          elsif params[:commit].downcase == 'return'
            set_petition_decision_attributes('return')
            message_petitioner('return')
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

      def get_current_items
        @items = ContributorPetition.where(decision_required: true).includes(:user).order(sort_param)
      end

      def get_previous_items
        @items = ContributorPetition.where.not(decision_required: true).includes(:user).order(sort_param)
      end

      def require_permissions
        authorize! :read, :admin_dashboard
      end

      def valid_sort_attributes
        [
          'created_at',
          'users.display_name',
          'user_affiliation',
          'user_department',
          'date_returned', 
          'date_approved',
          'date_denied',
          'decision_state',
          'reason',
          'user_demographics',
          'user_advisor',
          'contribution_amount',
          'terms_agree',
          'decision'
        ]
      end

      def default_sort_param
        'created_at DESC'
      end

      def user_key_params
        ['user_id']
      end

      def valid_filter_attributes
        [
          'date_application_submitted_start',
          'date_application_submitted_end',
          'user_id',
          'user_affiliation',
          'date_returned_start', 
          'date_returned_end', 
          'date_approved_start',
          'date_approved_end',
          'date_denied_start',
          'date_denied_end',
          'decision_state'
        ]
      end

      def filter_attribute_where_statements
        {
          'date_application_submitted_start' => 'created_at >= ?',
          'date_application_submitted_end' => 'created_at <= ?',
          'date_returned_start' => 'date_returned >= ?',
          'date_returned_end' => 'date_returned <= ?',
          'date_approved_start' => 'date_approved >= ?',
          'date_approved_end' => 'date_approved <= ?',
          'date_denied_start' => 'date_denied >= ?',
          'date_denied_end' => 'date_denied <= ?'
        }
      end

      def prepare_items_for_csv
        @items = @items.map do |item|
          item.attributes.map do |field, value|
            if field == 'user_id' or field == 'decision_by'
              value = User.find_by_id(value)&.name_and_email
            end

            if field == 'user_id'
              field = t('.list_headers.table.user')
            else
              field = t('.list_headers.table.'+field, default: field)
            end

            if value.kind_of? Array
              value = value.join(';')
            end
  
            [field, value]
          end.to_h
        end
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

        @petition.save
      end

      def acceptable_states
        ['approve', 'return', 'deny']
      end

      def state_to_date_field(state)
        "date_#{state_past[state]}"
      end

      def state_past
        {
          'approve' => 'approved',
          'return' => 'returned',
          'deny' => 'denied'
        }
      end

      def message_petitioner(state)
        raise 'Unacceptable state for contributor petition message' if !acceptable_states.include?(state)

        additional_msg = ""
        if state == 'approve'
          additional_msg = "This means you should now have contributor and data manager privileges on MorphoSource. You may upload new media, create or participate in projects and teams, and have other users transfer media ownership to you."
        elsif state == 'return'
          additional_msg = "This means that your application has been temporarily returned to you, likely with a request for further or modified information. If a message is present below, you should consult it, as it likely has instructions for you to follow. Please resubmit your application to become a contributor or data manager, making any necessary changes."
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