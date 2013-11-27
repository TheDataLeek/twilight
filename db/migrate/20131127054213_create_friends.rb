class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.integer :user

      t.timestamps
    end
  end
end
