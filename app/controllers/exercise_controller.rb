require 'csv'    

class ExerciseController < ApplicationController

  def index
  	@wordlists = WordList.all()
  end

  def finish
	data = params["data"]
	name = params["name"]

	# Increment to get a fresh training number
	training_number = Training.maximum('training_number')
	if training_number.nil?
		training_number = 0
	else
		trianing_number += 1
	end

	for training in data
		word = Word.where({:front => training["front"].join('|'), :back => training["back"].join('|')}).first

		if word
			Training.create({
				:word => word,
				:time => training["time"],
				:trials => training["trials"],
				:training_number => training_number,
				:name => name
			})
		else
			puts 'ERROR: Cannot find ' + training["back"] + " : " + training["front"] + ". Recording not saved!"
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
		back = w[0].split('|') #back
		front = w[1].split('|') #front
		vocab << {"back" => back, "front" => front}
	end
	vocab
  end
  	
  def vocab
  	list = nil
  	if not params['wordlist'].nil? and not params['wordlist'] == ""
  		list = WordList.where(:title => params['wordlist'])
  	else
  		list = WordList.first
  	end

	@vocab = Word.select('id, back, front').where(:word_list => list).order(:id)
	@vocab.each do | w |
		w["back"] = w["back"].split('|')
		w["front"] = w["front"].split('|')
	end

	respond_to do |format|
	  format.json { render :json => @vocab }
	end
  end

end
