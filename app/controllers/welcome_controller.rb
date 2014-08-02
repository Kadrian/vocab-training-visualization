class WelcomeController < ApplicationController

	skip_before_filter :verify_authenticity_token

	def index
		@training = Training.order("training_number").last
		if @training
			@trainings = Training.where(:training_number => @training.training_number)
		end
	end

	def upload
		all = params["text"]
		lines = all.split("\n")


		training_number = 0
		if @training = Training.order("training_number").last
			training_number = @training.training_number + 1
		end

		puts training_number

		# parameter creation 
		puts lines.length

		for line in lines do
			cols = line.split("#")

			# validity checks
			if cols[2].to_f == 0.0 # time
				next
			end

			word = Word.where({:front => cols[0], :back => cols[1]}).first_or_create

			if word
				Training.create({
					:word => word,
					:time => cols[2], # how badass 
					:trials => cols[3], # how badass 
					:training_number => training_number
				})
			end
		end

		render :nothing => true
	end
end
