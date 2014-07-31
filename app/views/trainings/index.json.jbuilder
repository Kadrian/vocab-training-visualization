json.array!(@trainings) do |training|
  json.extract! training, :id, :word, :training_number, :trials, :time, :name
  json.url training_url(training, format: :json)
end
