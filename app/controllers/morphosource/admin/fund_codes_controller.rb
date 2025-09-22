module Morphosource
  module Admin
    class FundCodesController < ApplicationController
      include Morphosource::Breadcrumbs

      before_action :require_permissions
      with_themed_layout 'morphosource_dashboard'

      PAGE_TITLE = I18n.t("morphosource.dashboard.admin.fund_codes.page_title")

      def index
        @fund_codes = FundCode.all
        if params[:id].present? && FundCode.exists?(params[:id])
          @current_fund_code = FundCode.find(params[:id])
          @managers_select2 = select2ize(@current_fund_code.managers)
          @standard_members_select2 = select2ize(@current_fund_code.standard_members)
          @form_url = main_app.admin_fund_codes_update_path
          @form_type = 'Edit'
        else
          @current_fund_code = FundCode.new
          @form_url = main_app.admin_fund_codes_create_path
          @form_type = 'New'
        end
      end

      def create
        if fund_code_params[:title].present? && fund_code_params[:description].present?
          fc = FundCode.new( params_attributes.merge(user: current_user) )
          params_managers.each { |u| fc.add_user(u, true) }
          params_standard_members.each { |u| fc.add_user(u, false) }
          fc.save!
        end

        redirect_to main_app.admin_fund_codes_path
      end

      def update
        if FundCode.exists?(params[:id])
          fc = FundCode.find(params[:id])

          form_managers = params_managers
          form_standard_members = params_standard_members

          members_to_delete = fc.members - (form_managers + form_standard_members)
          promoted_managers = form_managers & fc.standard_members
          demoted_members = form_standard_members & fc.managers

          (form_managers - promoted_managers - fc.managers).each { |m| fc.add_user(m, true) } # all-new managers
          (form_standard_members - demoted_members - fc.standard_members).each { |m| fc.add_user(m, false) } # all-new members
          promoted_managers.each { |m| fc.make_user_manager(m) } # promote managers
          demoted_members.each { |m| fc.make_user_standard(m) } # demote standard members
          members_to_delete.each { |m| fc.delete_user(m) } # delete remaining old members

          if params_attributes[:attachments].present? && fc.attachments.present?
            add_more_attachments(fc, params_attributes[:attachments])
            final_params = params_attributes.except(:attachments)
          else
            final_params = params_attributes
          end

          fc.update(final_params)
          fc.save!
        end

        redirect_to main_app.admin_fund_codes_path
      end

      def delete
        if current_user.admin? && FundCode.exists?(params[:id])
          FundCode.find(params[:id]).destroy
        end
        redirect_to main_app.admin_fund_codes_path
      end

      def delete_attachment
        if current_user.admin? && FundCode.exists?(params[:id]) && params[:index].present?
          @fund_code = FundCode.find(params[:id])
          remove_attachment_at_index(params[:index].to_i)
          flash[:error] = "Failed deleting attachment" unless @fund_code.save!
        end
        redirect_to main_app.admin_fund_codes_path(id: params[:id])
      end

      private

      def add_more_attachments(fund_code, new_attachments)
        attachments = fund_code.attachments
        attachments += new_attachments
        fund_code.attachments = attachments
      end

      def remove_attachment_at_index(index)
        remain_attachments = @fund_code.attachments
        if index == 0 && @fund_code.attachments.size == 1
          @fund_code.remove_attachments!
        else
          deleted_attachment = remain_attachments.delete_at(index)
          deleted_attachment.try(:remove!)
          @fund_code.attachments = remain_attachments
        end
      end

      def require_permissions
        authorize! :read, :admin_dashboard
      end

      def select2ize(users)
        users.map { |u| { id: u.id, user_key: u.user_key, text: u.email } }.to_json
      end

      def fund_code_params
        @fund_code_params ||= params.fetch(:fund_code, {}).permit(
          :title,
          :description,
          :identifier,
          :invoice_number,
          :managers,
          :standard_members,
          :expires_at,
          :storage_total_gb,
          :total,
          :external_user,
          :external_user_additional_rate_percent,
          :chargeable,
          :can_add_media,
          { attachments: [] }
        )
      end

      def params_attributes
        fund_code_params.except(:managers, :standard_members)
      end

      def params_managers
        return [] if !fund_code_params[:managers].present?
        fund_code_params[:managers].split(',').map { |id| User.find_by_user_key(id.strip) }.compact
      end

      def params_standard_members
        return [] if !fund_code_params[:standard_members].present?
        fund_code_params[:standard_members].split(',').map { |id| User.find_by_user_key(id.strip) }.compact
      end
    end
  end
end