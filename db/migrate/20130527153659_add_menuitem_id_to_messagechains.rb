class AddMenuitemIdToMessagechains < ActiveRecord::Migration
  def change
    add_column :messagechains, :menuitem_id, :integer
  end
end
