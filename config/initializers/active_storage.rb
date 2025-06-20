# Patch for Rails 6.1 + Ruby 3.2/3.3 autoload issue
# todo5 remove when we upgrade to Rails 7
module ActiveStorage
  class Blob
    module Analyzable
    end
  end
end