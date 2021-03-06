# encoding: utf-8

class Word < ActiveRecord::Base
	has_many :trainings, :dependent => :delete_all
	belongs_to :word_list

	auto_strip_attributes :front, :back, :nullify => false, :squish => true
end
