class AddUserEmailAndHash < ActiveRecord::Migration
    def change
        add_column :users, :email, :string
        add_column :users, :hash, :string
    end
end
