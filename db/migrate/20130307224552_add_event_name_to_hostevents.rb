class AddEventNameToHostevents < ActiveRecord::Migration
  def change
    add_column :hostevents, :event_name, :string
  end
end
