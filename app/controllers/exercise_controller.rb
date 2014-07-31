require 'csv'    

class ExerciseController < ApplicationController

  def index
  end

  def finish
	data = params["data"]
	name = params["name"]

	# Find biggest training number + increment
	training_number = 0
	if @training = Training.order("training_number").last
		training_number = @training.training_number + 1
	end

	for training in data
		word = Word.where({:eng => training["eng"].join('|'), :jap => training["jap"].join('|')}).first

		if word
			Training.create({
				:word => word,
				:time => training["time"],
				:trials => training["trials"],
				:training_number => training_number,
				:name => name
			})
		else
			puts 'ERROR: Cannot find ' + training["jap"] + " : " + training["eng"] + ". Recording not saved!"
		end

	end

	respond_to do |format|
		format.json { head :no_content }
	end
  end

  # NOT USED AT THE MOMENT - GOOD FOR TESTING
  def loadFromCSV
 	csv_text = File.read(Rails.root.join('app/assets/files/vocab.txt'))
	vocab = []
	parsed = CSV.parse(csv_text, :col_sep => ";")
	parsed.each do |w|
		jap = w[0].split('|') #jap
		eng = w[1].split('|') #eng
		vocab << {"jap" => jap, "eng" => eng}
	end
	vocab
  end
  	
  def vocab
	@vocab = Word.select('id, jap, eng')
	@vocab.each do | w |
		w["jap"] = w["jap"].split('|')
		w["eng"] = w["eng"].split('|')
	end

	respond_to do |format|
	  format.json { render :json => @vocab }
	end
  end

end
