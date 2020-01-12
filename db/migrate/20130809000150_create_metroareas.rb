class CreateMetroareas < ActiveRecord::Migration
  def change
    create_table :metroareas do |t|
      t.string :metro_name
      t.string :metro_name_nospace
      t.timestamps
    end
  end
end
