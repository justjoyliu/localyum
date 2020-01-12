class CreateCharitypolicies < ActiveRecord::Migration
  def change
    create_table :charitypolicies do |t|
      t.integer :percentcontribute
      t.string :charityname

      t.timestamps
    end
  end
end
