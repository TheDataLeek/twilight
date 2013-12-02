class ScreenToUsername < ActiveRecord::Migration
  def change
      rename_column :users, :screen_name, :username
  end
end
