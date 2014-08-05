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

    @wordlists = WordList.all()
  end

  # AJAX GET /statistics/wordListStats
  def wordListStats
    list = nil
    if not params['wordlist'].nil? and not params['wordlist'] == ""
      list = WordList.where(:title => params['wordlist'])
    else
      list = WordList.first
    end

    # TODO: Figure out a way to do it in one query
    words = Word.where(:word_list => list)
    for w in words
      w['timesTrained'] = 0
      timesTrained = Training.group(:word_id).where(:word_id => w.id).count()[w.id]
      if not timesTrained.nil?
        w['timesTrained'] = timesTrained
      end
    end

    @words = words.to_json

    respond_to do |format|
      format.json { render :json => @words}
    end
  end

end
