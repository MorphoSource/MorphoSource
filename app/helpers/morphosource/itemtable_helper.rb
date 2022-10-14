module Morphosource
  module ItemtableHelper
    def sortable_itemtable_header(label, attribute_name, default_order='asc')
      if @sort_param.downcase == "#{attribute_name} asc"
        link_to request.params.merge(sort: "#{attribute_name} desc"), class: 'table-sort-header' do
          (label + ' <span class="glyphicon glyphicon-sort-by-attributes" aria-hidden="true"></span>').html_safe
        end
      elsif @sort_param.downcase == "#{attribute_name} desc"
        link_to request.params.merge(sort: "#{attribute_name} asc"), class: 'table-sort-header' do
          (label + ' <span class="glyphicon glyphicon-sort-by-attributes-alt" aria-hidden="true"></span>').html_safe
        end
      else
        link_to request.params.merge(sort: "#{attribute_name} #{default_order}"), class: 'table-sort-header' do
          (label + ' <span class="glyphicon glyphicon-sort" aria-hidden="true"></span>').html_safe
        end
      end
    end
  end
end