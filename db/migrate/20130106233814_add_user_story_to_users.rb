class AddUserStoryToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :admin, :boolean, default: false
    add_column :users, :last_name, :string
    add_column :users, :user_story, :text
    add_column :users, :link_facebook, :string
    add_column :users, :link_twitter, :string
    add_column :users, :link_pintrest, :string
    add_column :users, :link_foodblog, :string
  end
end
