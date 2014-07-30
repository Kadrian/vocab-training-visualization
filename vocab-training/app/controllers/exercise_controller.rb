require 'csv'    

class ExerciseController < ApplicationController

  def index
  end

  def vocab
  	csv_text = File.read(Rails.root.join('app/assets/files/vocab.txt'))
	@vocab = []
	parsed = CSV.parse(csv_text, :col_sep => ";")
	parsed.each do |w|
		jap = w[0].split('|') #jap
		eng = w[1].split('|') #eng
		@vocab << {"jap" => jap, "eng" => eng}
	end

	respond_to do |format|
	  format.json { render :json => @vocab }
	end
  end

end
