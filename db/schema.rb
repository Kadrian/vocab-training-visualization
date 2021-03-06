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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140804173130) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "trainings", force: true do |t|
    t.integer  "word_id"
    t.integer  "training_number"
    t.integer  "trials"
    t.float    "time"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "word_lists", force: true do |t|
    t.string   "title"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "word_lists", ["title"], name: "index_word_lists_on_title", unique: true, using: :btree

  create_table "words", force: true do |t|
    t.string   "back"
    t.string   "front"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "word_list_id"
  end

end
