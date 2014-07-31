class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|
      t.integer :word_id
      t.integer :training_number
      t.integer :trials
      t.float :time
      t.string :name

      t.timestamps
    end
  end
end
