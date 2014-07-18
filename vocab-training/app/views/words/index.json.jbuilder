json.array!(@words) do |word|
  json.extract! word, :id, :jap, :eng
  json.url word_url(word, format: :json)
end
