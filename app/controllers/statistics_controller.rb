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

    # words = Word.joins("JOIN trainings ON trainings.word_id = words.id")
    #   .select('words.*, COUNT(trainings.word_id) as timesTrained')
    #   .where(:word_list => list)
    #   .group("trainings.word_id")

    subquery = Training.select("trainings.word_id,
      count(trainings.word_id) as timesTrained,
      avg(trainings.time) as avgTime,
      avg(trainings.trials) as avgTrials
      ").group(:word_id).to_sql

    words = Word.select("words.*,
      p.timesTrained as \"timesTrained\",
      p.avgTime as \"avgTime\",
      p.avgTrials as \"avgTrials\"")
      .joins("LEFT OUTER JOIN (#{subquery}) as p ON words.id = p.word_id").where(:word_list => list).order('words.id')

    for w in words
      if w['timesTrained'].nil?
        w['timesTrained'] = 0
        w['avgTrials'] = 0
        w['avgTime'] = 0
      else
        w['avgTrials'] = w['avgTrials'].to_f
      end
    end

    @words = words.to_json

    respond_to do |format|
      format.json { render :json => @words}
    end
  end

end
