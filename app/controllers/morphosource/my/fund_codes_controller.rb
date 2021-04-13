module Morphosource
  module My
    class FundCodesController < ApplicationController
      with_themed_layout 'morphosource_dashboard'

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'morphosource.dashboard.my.fund_codes.header'), main_app.my_fund_codes_path

        @fund_codes = current_user.fund_codes
        redirect_to main_app.dashboard_path if @fund_codes.empty?

        @managed_fund_codes = current_user.managed_fund_codes
        @standard_member_fund_codes = current_user.standard_member_fund_codes

        if (
          params[:id].present? && 
          FundCode.exists?(params[:id]) && 
          @managed_fund_codes.include?(fc = FundCode.find(params[:id])) 
        )
          @current_fund_code = fc
          @standard_members_select2 = select2ize(@current_fund_code.standard_members)
        end
      end

      def update
        if FundCode.exists?(params[:id]) && current_user.managed_fund_codes.include?(fc = FundCode.find(params[:id]))
          new_standard_members = params_standard_members
          (new_standard_members - fc.standard_members).each { |m| fc.add_user(m, false) } # add new
          (fc.standard_members - new_standard_members).each { |m| fc.delete_user(m) } # delete old
          fc.save!
        end

        redirect_to main_app.my_fund_codes_path
      end

      private

      def select2ize(users)
        users.map { |u| { id: u.id, user_key: u.id.to_s, text: u.email } }.to_json
      end

      def fund_code_params
        @fund_code_params ||= params.fetch(:fund_code, {}).permit(:standard_members)
      end

      def params_standard_members
        fund_code_params[:standard_members].split(',').map { |id| User.find_by_user_key(id.strip) }.compact
      end
    end
  end
end