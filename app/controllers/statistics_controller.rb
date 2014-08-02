class StatisticsController < ApplicationController
  def index

  	training_number = Training.maximum("training_number")

  	# TODO: Look up why this doesn't work
  	# 	Training.includes(:word).order(time: :desc).to_json
  	# -----------------	
  	data = Training.joins("LEFT JOIN words ON trainings.word_id = words.id")
  		.select('trainings.*, words.*')
  		.where(:training_number => training_number)
  		.order(trials: :desc, time: :desc)

  	for d in data
  		d["timesTrained"] = Training.group(:word_id).where(:word_id => d.word_id).count()[d.word_id]
  	end

  	@data = data.to_json
  	@name = data.first.name

  end
end
