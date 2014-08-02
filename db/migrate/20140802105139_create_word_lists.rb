class CreateWordLists < ActiveRecord::Migration
  def change
    create_table :word_lists do |t|
      t.string :title
      t.string :author

      t.timestamps
    end
  end
end
