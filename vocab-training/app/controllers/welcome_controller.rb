class WelcomeController < ApplicationController

	def index
		@training = Training.order("training_number").last
		if @training
			@trainings = Training.where(:training_number => @training.training_number)
		end
	end

	def upload
		puts params

		# training_number	= 0
		# if @training = Training.order("training_number").last
		# 	training_number = @training.training_number + 1
		# end

		# parameter creation 
		
		# for t in a.readlines():
		# 	TrainingController.create(training_params)
		# end
	end
end
