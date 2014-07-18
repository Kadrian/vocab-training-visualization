json.array!(@trainings) do |training|
  json.extract! training, :id, :word,, :training_number, :trials, :time
  json.url training_url(training, format: :json)
end
