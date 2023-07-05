class ChangeDateFormatInWorkViewStat < ActiveRecord::Migration[5.2]
  def change
    change_column :work_view_stats, :date, :date
  end
end
