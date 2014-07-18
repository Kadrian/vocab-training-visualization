class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|
      t.string :word
      t.integer :training_number
      t.integer :trials
      t.float :time

      t.timestamps
    end
  end
end
