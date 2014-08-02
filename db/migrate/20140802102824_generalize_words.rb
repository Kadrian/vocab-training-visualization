class GeneralizeWords < ActiveRecord::Migration
  def change
    rename_column :words, :eng, :front
    rename_column :words, :jap, :back
  end
end
