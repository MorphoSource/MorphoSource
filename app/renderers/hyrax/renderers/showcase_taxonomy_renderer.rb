module Hyrax
  module Renderers
    class ShowcaseTaxonomyRenderer < AttributeRenderer

      include Hyrax::TaxonomyHelper

      attr_accessor :output_buffer

      def render
        markup = ''
        return markup if values.blank? && !options[:include_empty]
        Array(values).each do |value|
          block = create_block
          markup << "<div class='panel'>"
          markup << taxonomy_title(block, options[:data_parent], options[:label], value, options[:is_collapsed])
          markup << collapse_accordion_panel(block, options[:is_collapsed])
          markup << taxonomy_ranks(value)
          markup << "</div></div>"
        end
        markup.html_safe
      end

      private

      def taxonomy_ranks(taxonomy)
        markup = ''
        return markup if taxonomy.nil?
        RANKS.each do |attribute, label|
          value = get_rank_value(taxonomy, attribute)
          markup << "<div class='row taxonomy-rank'>
                      <div class='col-xs-6 showcase-label'>#{label}</div>
                      <div class='col-xs-6 showcase-value'>#{value}</div>
                    </div>"
        end
        user = contributing_user_link(taxonomy, false)
        if user.present?
          markup << "<div class='row taxonomy-rank'>
                      <div class='col-xs-6 showcase-label'>Contributing User</div>
                      <div class='col-xs-6 showcase-value'>#{user}</div>
                    </div>"        
        end
        markup
      end

      # If an array of taxonomies, find the one whose title matches value
      def select_taxonomy(value)
        return @values if @values.class == Taxonomy
        @values.select{|taxonomy| taxonomy == value}.first
      end

      def construct_title(taxonomy)
        taxonomy.short_title
      end

      def contributing_user(taxonomy)
        return '' unless options[:label] == I18n.t('morphosource.taxonomy.labels.user')
        contributing_user_link(taxonomy)
      end

      def taxonomy_title(block, data_parent, label, value, is_collapsed)
        taxonomy = select_taxonomy(value)
        title = construct_title(taxonomy)
        icon = is_collapsed ? "bottom" : "top"
        content_tag :div, :class => "row" do
          concat content_tag(:div, label, class: "col-xs-6 showcase-label taxonomy-label")
          concat content_tag(:div, title, class: "col-xs-5 showcase-value taxonomy-title")
          concat content_tag(:span, "", :data => {:toggle => "collapse", :parent => %(##{data_parent})}, :href => %(##{block}), class: "col-xs-1 glyphicon glyphicon-triangle-#{icon} #{block}")
        end
      end

      def collapse_accordion_panel(block, collapsed)
        state = (collapsed ? "" : "in ")
        "<div id=#{block} class='panel-collapse collapse #{state}collapse-accordion'>"
      end

      def create_block
        "collapse-taxonomy-#{('a'..'z').to_a.shuffle[0,8].join}"
      end

      def get_rank_value(taxonomy, attribute)
        value = taxonomy.send(attribute)
        value.empty? ? "--" : value.first
      end

      RANKS = {
        taxonomy_domain: "Domain",
        taxonomy_kingdom: "Kingdom",
        taxonomy_phylum: "Phylum",
        taxonomy_superclass: "Superclass",
        taxonomy_class: "Class",
        taxonomy_subclass: "Subclass",
        taxonomy_superorder: "Superorder",
        taxonomy_order: "Order",
        taxonomy_suborder: "Suborder",
        taxonomy_superfamily: "Superfamily",
        taxonomy_family: "Family",
        taxonomy_subfamily: "Subfamily",
        taxonomy_tribe: "Tribe",
        taxonomy_genus: "Genus",
        taxonomy_subgenus: "Subgenus",
        taxonomy_species: "Species",
        taxonomy_subspecies: "Subspecies"
      }
    end
  end
end
