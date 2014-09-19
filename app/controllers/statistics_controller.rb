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

    started = Training.where(:training_number => training_number).first()["created_at"].to_s
    @trainingStarted = started.split('T')[0] + " " + started.split('T')[1].split('.')[0]

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

    # words = Word.select("words.*, trainings.*")
    # RAILS WILL JUST MIX UP NAMES -> LEADS TO CONFUSION, THIS IS CLEAR
    words = Word.select("
      words.id as word_id,
      words.back as word_back,
      words.front as word_front,
      words.word_list_id as word_word_list_id,
      words.created_at as word_created_at,
      words.updated_at as word_updated_at,
      trainings.id as training_id,
      trainings.name as training_name,
      trainings.time as training_time,
      trainings.trials as training_trials
    ")
      .joins("LEFT OUTER JOIN trainings ON words.id = trainings.word_id")
      .where(:word_list => list)
      .order('words.id ASC, trainings.created_at ASC')

    @words = words.to_json

    respond_to do |format|
      format.json { render :json => @words}
    end
  end

end
