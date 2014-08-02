# encoding: utf-8

class Word < ActiveRecord::Base
	has_many :trainings
	belongs_to :word_list
end
