class CreateMenuitems < ActiveRecord::Migration
  def change
    create_table :menuitems do |t|
      t.string :name
      t.string :course
      t.string :description
      t.text :recipe
      t.string :recipeview
      t.text :notes
      t.integer :spicyscale
      t.integer :sweetscale
      t.integer :flavorinstensity

      t.timestamps
    end
  end
end
