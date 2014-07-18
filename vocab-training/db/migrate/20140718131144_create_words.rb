class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :jap
      t.string :eng

      t.timestamps
    end
  end
end
