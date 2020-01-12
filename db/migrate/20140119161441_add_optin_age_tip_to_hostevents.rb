class AddOptinAgeTipToHostevents < ActiveRecord::Migration
  def change
    add_column :hostevents, :tip_included, :boolean, default: true
    add_column :hostevents, :age_21plus, :boolean, default: false
  end
end