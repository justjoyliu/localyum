# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140501011813) do

  create_table "addressusers", :force => true do |t|
    t.string   "line1"
    t.string   "city"
    t.string   "state"
    t.string   "zip5"
    t.string   "metroarea"
    t.integer  "user_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "nickname"
    t.string   "neighborhood"
    t.boolean  "gmaps"
    t.float    "lat_rand"
    t.float    "lng_rand"
    t.boolean  "private_flag",       :default => false
    t.boolean  "allow_booking_flag", :default => true
  end

  add_index "addressusers", ["state", "zip5", "metroarea"], :name => "index_addressusers_on_state_and_zip5_and_metroarea"

  create_table "cancellationpolicies", :force => true do |t|
    t.integer  "hrs_before_1"
    t.integer  "refund_percent_1"
    t.integer  "hrs_before_2"
    t.integer  "refund_percent_2"
    t.string   "cancellation_description"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "cancellationpolicies", ["hrs_before_1", "hrs_before_2"], :name => "index_cancellationpolicies_on_hrs_before_1_and_hrs_before_2"

  create_table "charitypolicies", :force => true do |t|
    t.integer  "percentcontribute"
    t.string   "charityname"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "eventactivities", :force => true do |t|
    t.string   "activity"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "eventactivities_hostevents", :id => false, :force => true do |t|
    t.integer "hostevent_id",     :null => false
    t.integer "eventactivity_id", :null => false
  end

  add_index "eventactivities_hostevents", ["hostevent_id", "eventactivity_id"], :name => "eventactivities_hostevents_id", :unique => true

  create_table "eventcategories", :force => true do |t|
    t.string   "categorytype"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "eventphotos", :force => true do |t|
    t.integer  "hostevent_id"
    t.string   "photodescription"
    t.boolean  "onlyattendeeview",      :default => false
    t.string   "eventpic_file_name"
    t.string   "eventpic_content_type"
    t.integer  "eventpic_file_size"
    t.datetime "eventpic_updated_at"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "host_penalties", :force => true do |t|
    t.integer  "hostevent_id"
    t.integer  "user_id"
    t.integer  "number_guests"
    t.integer  "amt_refunded_cents"
    t.integer  "penalty_amount_cents"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "hostevents", :force => true do |t|
    t.date     "startdate"
    t.datetime "mealstarttime"
    t.decimal  "price",                     :precision => 6, :scale => 2
    t.boolean  "guestallowforprep",                                       :default => false
    t.datetime "timestartprep"
    t.integer  "maxguests"
    t.text     "discussiontopics"
    t.string   "bestwaytocontact"
    t.text     "extracomments"
    t.text     "requestsforguests"
    t.integer  "mustbookhoursinadvance"
    t.string   "eventstatus",                                             :default => "Setup"
    t.boolean  "confirmability",                                          :default => true
    t.integer  "user_id"
    t.integer  "addressuser_id"
    t.integer  "eventcategory_id"
    t.integer  "charitypolicy_id"
    t.integer  "cancellationpolicy_id",                                   :default => 1
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.string   "event_name"
    t.string   "transfer_id"
    t.string   "payout_method",                                           :default => "Check"
    t.integer  "address_to_send_payout_id"
    t.string   "payout_status"
    t.date     "payout_date"
    t.integer  "host_net_earnings_cents",                                 :default => 0
    t.integer  "host_charity_cents"
    t.integer  "ly_charity_cents"
    t.integer  "ly_net_host_fee"
    t.string   "payout_non_ach_info"
    t.integer  "penalty_cents",                                           :default => 0
    t.boolean  "clean_optin",                                             :default => false
    t.boolean  "local_ingredients_optin",                                 :default => false
    t.string   "permalink"
    t.boolean  "tip_included",                                            :default => false
    t.boolean  "age_21plus",                                              :default => false
    t.integer  "chef_id"
    t.text     "chef_comment"
    t.boolean  "chef_confirm",                                            :default => false
  end

  add_index "hostevents", ["permalink"], :name => "index_hostevents_on_permalink", :unique => true
  add_index "hostevents", ["user_id", "startdate", "price"], :name => "index_hostevents_on_user_id_and_startdate_and_price"

  create_table "hostevents_menuitems", :id => false, :force => true do |t|
    t.integer "hostevent_id", :null => false
    t.integer "menuitem_id",  :null => false
  end

  add_index "hostevents_menuitems", ["hostevent_id", "menuitem_id"], :name => "hostevents_menuitems_id", :unique => true

  create_table "menuitems", :force => true do |t|
    t.string   "name"
    t.string   "course"
    t.string   "description"
    t.text     "recipe"
    t.string   "recipeview"
    t.text     "notes"
    t.integer  "spicyscale"
    t.integer  "sweetscale"
    t.integer  "flavorinstensity"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "user_id"
    t.text     "ingredient"
    t.string   "menupic_file_name"
    t.string   "menupic_content_type"
    t.integer  "menupic_file_size"
    t.datetime "menupic_updated_at"
    t.string   "permalink"
  end

  add_index "menuitems", ["permalink"], :name => "index_menuitems_on_permalink", :unique => true

  create_table "messagechains", :force => true do |t|
    t.integer  "hostevent_id"
    t.string   "title"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "menuitem_id"
    t.string   "permalink"
  end

  add_index "messagechains", ["permalink"], :name => "index_messagechains_on_permalink", :unique => true

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "messagechain_id"
    t.boolean  "first_flag",        :default => false
    t.text     "message_content"
    t.boolean  "receiver_read",     :default => false
    t.boolean  "receiver_replied",  :default => false
    t.boolean  "public_flag",       :default => false
    t.integer  "order_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "sender_hidden",     :default => false
    t.boolean  "receiver_hidden",   :default => false
    t.integer  "signup_id"
    t.integer  "replied_to_msg_id"
  end

  add_index "messages", ["messagechain_id"], :name => "index_messages_on_messagechain_id"
  add_index "messages", ["receiver_id"], :name => "index_messages_on_receiver_id"
  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"

  create_table "metroareas", :force => true do |t|
    t.string   "metro_name"
    t.string   "metro_name_nospace"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "recipereqs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "menuitem_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "chef_id"
    t.boolean  "as_host_flag",       :default => false
    t.string   "req_date"
    t.text     "req_detail"
    t.string   "est_guests"
    t.string   "price_range"
    t.integer  "req_addressuser_id"
    t.integer  "req_status",         :default => 0
    t.integer  "hostevent_id"
    t.string   "permalink"
  end

  add_index "recipereqs", ["permalink"], :name => "index_recipereqs_on_permalink", :unique => true

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "signups", :force => true do |t|
    t.integer  "hostevent_id"
    t.integer  "user_id"
    t.boolean  "confirmation_host",                                    :default => false
    t.boolean  "confirmation_guest",                                   :default => false
    t.string   "confirmation_status"
    t.string   "payment_status",                                       :default => "Pending"
    t.decimal  "payment_amt",           :precision => 12, :scale => 2
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
    t.integer  "taste_rating"
    t.integer  "experience_rating"
    t.string   "charge_id"
    t.string   "card_id"
    t.integer  "pay_portal_fee_cents"
    t.integer  "card_last_4"
    t.integer  "card_mth"
    t.integer  "card_yr"
    t.string   "pay_failure_msg"
    t.integer  "refund_amt_cent"
    t.string   "card_status",                                          :default => "ok"
    t.boolean  "dispute_flag",                                         :default => false
    t.integer  "host_rating_for_guest"
    t.string   "permalink"
    t.integer  "guest_count",                                          :default => 1
    t.boolean  "own_group_flag",                                       :default => false
  end

  add_index "signups", ["hostevent_id", "user_id"], :name => "index_signups_on_hostevent_id_and_user_id", :unique => true
  add_index "signups", ["hostevent_id"], :name => "index_signups_on_hostevent_id"
  add_index "signups", ["permalink"], :name => "index_signups_on_permalink", :unique => true
  add_index "signups", ["user_id"], :name => "index_signups_on_user_id"

  create_table "suggestion_inputs", :force => true do |t|
    t.integer  "suggestion_id"
    t.integer  "user_id"
    t.integer  "want"
    t.integer  "like_vote"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "suggestions", :force => true do |t|
    t.string   "feature_description"
    t.string   "status"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "unsubscribes", :force => true do |t|
    t.string   "email"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  add_index "unsubscribes", ["email"], :name => "index_unsubscribes_on_email"

  create_table "userbalances", :force => true do |t|
    t.string   "transfer_id"
    t.integer  "amount"
    t.string   "status"
    t.integer  "user_id"
    t.integer  "stripe_fee"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "admin",                      :default => false
    t.string   "last_name"
    t.text     "user_story"
    t.string   "link_facebook"
    t.string   "link_twitter"
    t.string   "link_pintrest"
    t.string   "link_foodblog"
    t.string   "validation_code"
    t.boolean  "validation_flag"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean  "active_status",              :default => true
    t.integer  "account_balance_cents",      :default => 0
    t.string   "recipient_id"
    t.string   "permalink"
    t.string   "provider",                   :default => "web"
    t.integer  "fbid"
    t.boolean  "yummer_flag",                :default => true
    t.boolean  "host_flag",                  :default => true
    t.boolean  "chef_flag",                  :default => false
    t.boolean  "allow_offsite_request_flag", :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["permalink"], :name => "index_users_on_permalink", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
