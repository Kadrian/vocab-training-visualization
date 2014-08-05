class WordList < ActiveRecord::Base
	has_many :words
	validates :title, :author, :presence => true

	def words_text=(words_text)
	end

	def word_attributes=(word_attributes)
		word_attributes.each do |attributes|
			attributes.each do |key, val|
				if val == ""
					return
				end
			end
			
			words.build(attributes)
		end
	end
end
