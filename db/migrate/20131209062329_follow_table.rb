class FollowTable < ActiveRecord::Migration
  def change
      add_column :followers, :follows, :integer
  end
end
