# encoding: utf-8

class Word < ActiveRecord::Base
	self.primary_keys = :jap, :eng
	has_many :trainings, :foreign_key => [:jap, :eng]
end
