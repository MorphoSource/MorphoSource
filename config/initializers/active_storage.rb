# Patch for Rails 6.1 + Ruby 3.2/3.3 autoload issue
# todo5 remove when we upgrade to Rails 7
if !Rails.env.production?
  ActiveSupport.on_load(:active_storage_blob) do
    module Analyzable
    end
  end  
end