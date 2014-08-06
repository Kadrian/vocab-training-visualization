class WordList < ActiveRecord::Base
	has_many :words
	validates :title, :author, :presence => true
	accepts_nested_attributes_for :words

	# def a_lot_of_words=(a_lot_of_words)
	# end

	# def word_attributes=(word_attributes)
	# end
	# 	if word_attributes
	# 	word_attributes.each do |attributes|
	# 		[{front => "haha", back => "hoho"}, {front => "lol", back => "lal"}]
	# 		{523 => {front => "haha", back => "hoho"}, 534 => {front => "lol", back => "lal"}}
	# 		puts attributes
	# 		attributes.each do |key, val|
	# 			if val == ""
	# 				next
	# 			end
	# 		end
	# 		if words.find(attributes)
	# 			words.

	# 		words.build(attributes)
	# 	end
	# end
end
