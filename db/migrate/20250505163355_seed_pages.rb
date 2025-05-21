class SeedPages < ActiveRecord::Migration[5.2]
  def change
    Rake::Task['morphosource:create_simple_pages'].invoke
  end
end
