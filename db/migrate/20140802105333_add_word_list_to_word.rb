class AddWordListToWord < ActiveRecord::Migration
  def change
  	change_table :words do |t|
    	t.references :word_list
  	end
  end
end
