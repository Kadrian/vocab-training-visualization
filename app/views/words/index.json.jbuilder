json.array!(@words) do |word|
  json.extract! word, :id, :back, :front
  json.url word_url(word, format: :json)
end
