class MakeWordListsTitleUnique < ActiveRecord::Migration
  def change
  	add_index :word_lists, :title, :unique => true
  end
end
