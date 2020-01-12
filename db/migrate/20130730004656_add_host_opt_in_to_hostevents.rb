class AddHostOptInToHostevents < ActiveRecord::Migration
  def change
    add_column :hostevents, :clean_optin, :boolean, default: false
    add_column :hostevents, :local_ingredients_optin, :boolean, default: false
  end
end
