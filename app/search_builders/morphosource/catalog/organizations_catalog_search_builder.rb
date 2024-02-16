class Morphosource::Catalog::OrganizationsCatalogSearchBuilder < Morphosource::CatalogSearchBuilder

  # @overload initialize(scope)
    #   @param [Object] scope scope the scope where the filter methods reside in.
    # @overload initialize(processor_chain, scope)
    #   @param [List<Symbol>,TrueClass] processor_chain options a list of filter methods to run or true, to use the default methods
    #   @param [Object] scope scope the scope where the filter methods reside in.
    def initialize(*options)
      byebug
      @scope = case options.size
      when 1
        options.first
      when 2
        if options.first == true
          Deprecation.warn Blacklight::SearchBuilder, "SearchBuilder#initialize now takes only one parameter, the scope. Passing `true' will be removed in Blacklight 7"
        else
          @processor_chain = options.first
        end
        options.last
      else
        raise ArgumentError, "wrong number of arguments. (#{options.size} for 1..2)"
      end
      byebug
      @processor_chain ||= default_processor_chain.dup
      @blacklight_params = {}
      @merged_params = {}
      @reverse_merged_params = {}
    end

  private

    def models
      [::Organization, ::OrganizationCollection]
    end
end
