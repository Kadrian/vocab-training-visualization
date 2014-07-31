# encoding: utf-8

class Word < ActiveRecord::Base
	has_many :trainings
end
