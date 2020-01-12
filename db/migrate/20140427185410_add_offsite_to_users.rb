class AddOffsiteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :allow_offsite_request_flag, :boolean, default: false
  end
end
