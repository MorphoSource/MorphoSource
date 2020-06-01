module Morphosource
  # Finds a single work result. It returns no result if you don't have
  # access to the requested work.  If the work is suppressed (due to being in a
  # workflow), then it checks to see if the current_user has any workflow role
  # on the given work.
  class WorkSearchBuilder < Hyrax::WorkSearchBuilder

    # override Hydra::AccessControlsEnforcement to include 'download'
    def discovery_permissions
      @discovery_permissions ||= ["edit","discover","download","read"]
    end

  end
end
