module Morphosource
  module Admin
    class FundCodesController < ApplicationController
      before_action :require_permissions
      with_themed_layout 'morphosource_dashboard'

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'morphosource.admin.fund_codes.header'), main_app.admin_fund_codes_path

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
          fc = FundCode.new(
            title: fund_code_params[:title], 
            description: fund_code_params[:description],
            identifier: fund_code_params[:identifier],
            expires_at: fund_code_params[:expires_at],
            storage_limit_tb: fund_code_params[:storage_limit_tb],
            external_user: fund_code_params[:external_user],
            external_user_additional_rate_percent: fund_code_params[:external_user_additional_rate_percent],
            chargeable: fund_code_params[:chargeable],
            user: current_user
          )
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

          fc.update(
            { 
              title: fund_code_params[:title], 
              description: fund_code_params[:description],
              identifier: fund_code_params[:identifier],
              expires_at: fund_code_params[:expires_at],
              storage_limit_tb: fund_code_params[:storage_limit_tb],
              external_user: fund_code_params[:external_user],
              external_user_additional_rate_percent: fund_code_params[:external_user_additional_rate_percent],
              chargeable: fund_code_params[:chargeable]
            }
          )
        end

        redirect_to main_app.admin_fund_codes_path
      end

      def delete
        if current_user.admin? && FundCode.exists?(params[:id])
          FundCode.find(params[:id]).destroy
        end
        redirect_to main_app.admin_fund_codes_path
      end

      private

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
          :managers, 
          :standard_members, 
          :expires_at, 
          :storage_limit_tb, 
          :external_user, 
          :external_user_additional_rate_percent, 
          :chargeable
        )
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