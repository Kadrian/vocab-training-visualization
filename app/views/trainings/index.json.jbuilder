json.array!(@trainings) do |training|
  json.extract! training, :id, :word_id, :training_number, :trials, :time, :name
  json.url training_url(training, format: :json)
end
