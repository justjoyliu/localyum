class AddAttachmentMenupicToMenuitems < ActiveRecord::Migration
  def self.up
    change_table :menuitems do |t|
      t.has_attached_file :menupic
    end
  end

  def self.down
    drop_attached_file :menuitems, :menupic
  end
end
