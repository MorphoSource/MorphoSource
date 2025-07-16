module Morphosource
  module ItemtableHelper
    def sortable_itemtable_header(label, attribute_name, default_order='asc')
      if @sort_param.downcase == "#{attribute_name} asc"
        link_to request.params.merge(sort: "#{attribute_name} desc"), class: 'table-sort-header' do
          (label + ' <span class="fas fa-sort-down fa-sort-by-attributes" aria-hidden="true"></span>').html_safe
        end
      elsif @sort_param.downcase == "#{attribute_name} desc"
        link_to request.params.merge(sort: "#{attribute_name} asc"), class: 'table-sort-header' do
          (label + ' <span class="fas fa-sort-up fa-sort-by-attributes-alt" aria-hidden="true"></span>').html_safe
        end
      else
        link_to request.params.merge(sort: "#{attribute_name} #{default_order}"), class: 'table-sort-header' do
          (label + ' <span class="fas fa-sort" aria-hidden="true"></span>').html_safe
        end
      end
    end

    def format_users_select2(user_keys)
      Array(user_keys).map do |ms_id|
        if (u = User.where(ms_id: ms_id)&.first).present?
          { id: u.id, user_key: u.user_key, text: u.name_and_email }
        end
      end.compact
    end
  end
end