class AddPenaltyToHostevents < ActiveRecord::Migration
  def change
    add_column :hostevents, :penalty_cents, :integer, default:0
  end
end
