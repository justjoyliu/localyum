class AddChefCommentIdToHostevents < ActiveRecord::Migration
  def change
    add_column :hostevents, :chef_comment, :text
    add_column :hostevents, :chef_confirm, :boolean, default: false
  end
end
