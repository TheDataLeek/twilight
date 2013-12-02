class HashToPassword < ActiveRecord::Migration
  def change
      rename_column :users, :hash, :password
  end
end
