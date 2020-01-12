class AddIngredientToMenuitems < ActiveRecord::Migration
  def change
    add_column :menuitems, :ingredient, :text
  end
end
