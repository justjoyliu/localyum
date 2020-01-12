class AddRepliedToMsgIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :replied_to_msg_id, :integer
  end
end
