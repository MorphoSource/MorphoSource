module Morphosource
  module Works
    class Base < ActiveFedora::Base

      class_attribute :work_requires_files

      self.work_requires_files = false

    end
  end
end
