# SOME COMMON APP JAVASCRIPT

ready = ->
	$('#new_wordlist').bootstrapValidator(
		live: 'enabled'
	)

# TURBOLINKS FIX
$(document).ready(ready)
$(document).on('page:load', ready)
