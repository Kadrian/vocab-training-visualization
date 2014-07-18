class Training < ActiveRecord::Base
	belongs_to :word, :foreign_key => [:jap, :eng]
end
