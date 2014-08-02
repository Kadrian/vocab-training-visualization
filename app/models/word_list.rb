class WordList < ActiveRecord::Base
	has_many :words

	def word_attributes=(word_attributes)
		word_attributes.each do |attributes|
			words.build(attributes)
		end
	end
end
