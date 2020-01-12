class CreateEventcategories < ActiveRecord::Migration
  def change
    create_table :eventcategories do |t|
      t.string :categorytype

      t.timestamps
    end
  end
end
