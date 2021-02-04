# frozen_string_literal: true

module Morphosource
  module WorksControllerBehavior

    def ancestors(works)
      return [] unless works.present?
      ancestors = []
      works.each do |work|
        work.ancestors.each { |a| ancestors << a }
      end
      ancestors.flatten.uniq
    end

    def select_specimens(works)
      works.select(&:specimen?)
    end

    def select_organizations(works)
      works.select(&:organization?)
    end

    def select_media(works)
      works.select { |w| w.class == Media }
    end
  end
end
