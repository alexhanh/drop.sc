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

ActiveRecord::Schema.define(:version => 20110904144145) do

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "text",             :limit => 2000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "events", :force => true do |t|
    t.string   "name",        :limit => 50
    t.string   "description"
    t.datetime "begins"
    t.datetime "ends"
  end

  create_table "messages", :force => true do |t|
    t.integer "replay_id"
    t.string  "sender"
    t.string  "msg"
    t.integer "target"
    t.integer "time"
    t.string  "sender_color", :limit => 7
  end

  create_table "news_posts", :force => true do |t|
    t.string   "author"
    t.string   "title",          :limit => 500
    t.string   "body",           :limit => 2000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count",                 :default => 0
  end

  create_table "notifications", :force => true do |t|
    t.boolean  "read",       :default => false
    t.string   "body"
    t.string   "url"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "pack_games", :force => true do |t|
    t.integer  "pack_id"
    t.integer  "replay_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packs", :force => true do |t|
    t.string   "original_filename"
    t.string   "file"
    t.string   "pass"
    t.boolean  "is_public",                         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description",       :limit => 2000
    t.integer  "downloads",                         :default => 0
    t.string   "state",             :limit => 20
    t.integer  "comments_count",                    :default => 0
  end

  create_table "players", :force => true do |t|
    t.string   "name"
    t.string   "gateway",      :limit => 2
    t.integer  "sub_region"
    t.string   "league_1v1",   :limit => 11
    t.integer  "rank_1v1"
    t.datetime "crawled_at",                  :default => '2001-08-15 09:06:44'
    t.integer  "crawl_status",                :default => 0
    t.datetime "last_played",                 :default => '2001-07-19 12:49:27'
    t.string   "region",       :limit => 3
    t.integer  "bnet_id"
    t.string   "aliases",      :limit => 100
  end

  create_table "plays", :force => true do |t|
    t.integer "player_id"
    t.integer "replay_id"
    t.string  "chosen_race", :limit => 1
    t.string  "race",        :limit => 1
    t.string  "color",       :limit => 7
    t.boolean "won"
    t.integer "team"
    t.integer "avg_apm"
    t.string  "player_type", :limit => 8
    t.string  "difficulty",  :limit => 10
  end

  create_table "replays", :force => true do |t|
    t.string   "file"
    t.string   "original_filename"
    t.integer  "game_length"
    t.string   "map_name"
    t.string   "gateway",           :limit => 2
    t.string   "file_hash",         :limit => 32
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pass"
    t.boolean  "is_public",                        :default => true
    t.datetime "saved_at"
    t.integer  "downloads",                        :default => 0
    t.string   "game_format",       :limit => 3
    t.string   "version",           :limit => 11
    t.integer  "zergs",                            :default => 0
    t.integer  "terrans",                          :default => 0
    t.integer  "protosses",                        :default => 0
    t.boolean  "winner_known",                     :default => false, :null => false
    t.integer  "event_id"
    t.string   "description",       :limit => 300, :default => ""
    t.string   "state",             :limit => 20
    t.integer  "comments_count",                   :default => 0
    t.string   "game_speed",        :limit => 8
    t.string   "game_type",         :limit => 7
    t.string   "map_file_name",     :limit => 75
  end

  create_table "subscriptions", :force => true do |t|
    t.integer "subscribable_id"
    t.string  "subscribable_type"
    t.integer "user_id"
  end

  create_table "uploads", :force => true do |t|
    t.integer  "uploadable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uploadable_type"
    t.string   "source",          :limit => 10, :default => "drop.sc"
    t.integer  "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",                              :default => false
    t.datetime "pro_until"
    t.string   "username"
    t.string   "uuid",                   :limit => 36
    t.boolean  "use_colors",                            :default => true
  end

end
