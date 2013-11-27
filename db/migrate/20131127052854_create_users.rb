class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :screen_name
      t.text :name
      t.text :created
      t.integer :rank
      t.integer :score
      t.integer :favourite_count
      t.integer :follower_count
      t.integer :friend_count
      t.integer :retweet_count
      t.integer :statuses_count

      t.timestamps
    end
  end
end
