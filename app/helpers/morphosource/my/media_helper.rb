module Morphosource
  module My
    module MediaHelper
      def sortable_table_header(label, param_name)
        sort_col, sort_dir = sort_parameters
        if sort_col == param_name && sort_dir.downcase == 'asc'
          link_to url_for(sort: "#{param_name} desc"), class: 'table-sort-header' do
            (label + ' <span class="glyphicon glyphicon-sort-by-attributes" aria-hidden="true"></span>').html_safe
          end
        elsif sort_col == param_name && sort_dir.downcase == 'desc'
          link_to url_for(sort: "#{param_name} asc"), class: 'table-sort-header' do
            (label + ' <span class="glyphicon glyphicon-sort-by-attributes-alt" aria-hidden="true"></span>').html_safe
          end
        else
          link_to url_for(sort: "#{param_name} asc"), class: 'table-sort-header' do
            (label + ' <span class="glyphicon glyphicon-sort" aria-hidden="true"></span>').html_safe
          end
        end
      end
    end
  end
end