# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

allowedTrials = 2
progressCorrect = '#exercise-correct'
progressWrong = '#exercise-wrong'
historyLength = 10

# ------------------------
# TRAINING
# ------------------------
startTraining = () ->
    range = $('#slider').data('slider').getValue()
    window.words = window.vocab.slice(range[0], range[1])
    window.trainingAmount = window.words.length
    window.repeatWords = []
    window.repetitionPhase = false

    resetExerciseProgress()
    enterReadyPhase()

abortTraining = () ->
    resetExerciseProgress()
    $('#question').html(" ")
    $('#history').html("")
    $('#report').html("")
    $('#answer').val("")
    $('#answer-form').removeClass("has-error").removeClass('has-success')
    $('#question').css('color', 'black')

endTraining = () ->
    if window.repetitionPhase
        # END TRAINING
        report = $('<h3></h3>').html("PROBLEMS WERE")
        $('#report').append(report)
        for w in window.repeatWords
            jap = w["jap"].join(' | ')
            eng = w["eng"].join(' | ')
            report = $('<p></p>').html(jap + " - " + eng)
            $('#report').append(report)
    else
        # START REPETITION
        window.repetitionPhase = true
        window.words = $.extend(true, [], window.repeatWords); 
        enterReadyPhase()

enterReadyPhase = () ->
    window.readyphase = true
    $('#answer').attr('placeholder', 'Ready? (Press Enter)')

exitReadyPhase = () ->
    window.readyphase = false
    $('#answer').attr('placeholder', '')
    $('#answer').val('')
    $('#answer-form').removeClass("has-error").removeClass('has-success')
    $('#question').css('color', 'black')

submitAnswer = (answer) ->
    # Validate and reset
    if window.readyphase
        exitReadyPhase()
        nextWord()
        return

    if answer == ''
        return

    $('#answer').val('')

    # Check correctness
    for jap in window.word["jap"]
        if answer == jap
            console.log "CORRECT"
            # TODO: SAVE ALL SORTS OF STATISTICS
            $('#answer-form').removeClass('has-error').addClass('has-success')

            updateExerciseProgress()
            pushHistory(answer, true)
            nextWord()
            return

    $('#answer-form').removeClass('has-success').addClass('has-error')

    handleWrong(answer)


handleWrong = (answer) ->
    window.trials++
    window.word["trials"]++

    if window.word["trials"] > allowedTrials
        $('#answer-form').removeClass('has-error')
        $('#question').css('color', 'red')

        if window.repetitionPhase
            window.words.push(window.word)
        else
            window.repeatWords.push(window.word)
            updateExerciseProgress()

        pushHistory(answer, false, window.word['jap'].join(' or '))
        enterReadyPhase()
        return

    pushHistory(answer, false)

nextWord = () ->
    if window.words.length == 0
        endTraining()

    window.word = removeRandom(window.words)
    window.word["trials"] = 1
    
    eng = selectRandom(window.word["eng"])
    $('#question').html(eng)

# ------------------------
# PROGRESS
# ------------------------
updateExerciseProgress = ->
    correctness = (window.trainingAmount - window.words.length) / window.trainingAmount
    wrongness = window.repeatWords.length / window.trainingAmount
    correctness -= wrongness

    wrong = window.repeatWords.length 
    correct = window.trainingAmount - window.words.length - wrong

    setExerciseProgress(correctness, wrongness, correct, wrong, false)

resetExerciseProgress = ->
    setExerciseProgress(0.0, 0.0, 0, 0, true);

setExerciseProgress = (correctness, wrongness, correct, wrong, reset) ->
    correctPercent = Math.round(correctness * 100)
    wrongPercent = Math.round(wrongness * 100)

    if correctPercent > 1 or reset
        $(progressCorrect).css('width', correctPercent + '%')
        if reset
            $(progressCorrect).html('')
        else
            $(progressCorrect).html(correct)

    if wrongPercent > 1 or reset
        $(progressWrong).css('width', wrongPercent + '%')
        if reset
            $(progressWrong).html('')
        else
            $(progressWrong).html(wrong)

    # Progress bars automatically transition
    $(progressCorrect).one($.support.transition.end, ->
        adjustColorOfProgressElement(progressCorrect, 55)
    )
    $(progressWrong).one($.support.transition.end, ->
        adjustColorOfProgressElement(progressWrong, 55)
    )
    $('#exercise-label').html((correctPercent + wrongPercent) + '%')
        
adjustColorOfProgressElement = (element, switchWidth) ->
    if $(element).width() > switchWidth
        $(element).css('color', 'white')
    else
        $(element).css('color', 'black')

# ----------------------
# HISTORY
# ----------------------
pushHistory = (string, isCorrect, solution) ->
    if $('#history').children().length >= historyLength
        $('#history').children().last().remove()

    question = $('<span></span>').html($('#question').html() + ' : ')

    el = $('<p></p>')
    el.append(question)

    if isCorrect
        answer = $('<span></span>').html(string).css('color', 'green')
        el.append(answer)
    else 
        answer = $('<span></span>').html(string).css('color', 'red')
        el.append(answer)

        if solution?
            sol = $('<span></span>').html(" -- " + solution)
            el.append(sol)

    $('#history').prepend(el)

    updateHistoryFading()

updateHistoryFading = ->
    i = 0
    shift = 2
    for el in $('#history').children()
        opacity = (historyLength - i) / historyLength
        opacity += shift / historyLength

        $(el).css('opacity', Math.min(1.0, opacity)) 
        i++

# ----------------------
# HELPER
# ----------------------
removeRandom = (array) ->
    idx = Math.floor(Math.random() * array.length)
    array.splice(idx, 1)[0]

selectRandom = (array) ->
    array[Math.floor(Math.random() * array.length)]


# ------------------------
# UI
# ------------------------
updateLabelRange = (range) ->
    $('#numwords-label').html(Math.abs(range[1] - range[0]) + " words")

updateLabel = (html) ->
    $('#numwords-label').html(html)

setupSliderInput = (numVocab) ->
    min = 0
    max = numVocab
    initMin = numVocab / 2
    initMax = numVocab
    updateLabelRange([initMin, initMax])

    $('#slider').slider(
        orientation: "horizontal"
        tooltip: "show"
        min: min
        max: max
        step: 1
        value: [initMin, initMax]
        handle: "round"
        formater: (value) ->
            " " + value + " "
    )

    $('#slider').on('slide', ->
        range = $(@).data('slider').getValue()
        $('#min').val(range[0])
        $('#max').val(range[1])
        updateLabelRange(range)
    )

    $('#min').val(initMin)
    $('#min').on('input', ->
        range = $('#slider').data('slider').getValue()
        range[0] = parseInt($(@).val())
        $('#slider').slider('setValue', range)
        updateLabelRange(range)
    )

    $('#max').val(initMax)
    $('#max').on('input', ->
        range = $('#slider').data('slider').getValue()
        range[1] = parseInt($(@).val())
        $('#slider').slider('setValue', range)
        updateLabelRange(range)
    )

$ ->
    $.ajax '/exercise/vocab',
        type: 'GET'
        dataType: 'json'
        error: (jqXHR, textStatus, errorThrown) ->
            console.log "AJAX Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
            window.vocab = data

            numVocab = window.vocab.length
            if numVocab > 10
                setupSliderInput(numVocab)
            else
                console.log "ERROR: You need at least 10 Words in your vocabulary."

    $('#start').click ->
        if $(@).html() == "Start"
            $("#min").prop('disabled', true)
            $("#max").prop('disabled', true)
            $("#answer").prop('disabled', false)
            $("#slider").slider('disable')
            $(@).html('Cancel')
            $(@).removeClass('btn-primary')
            $('#answer').focus()

            startTraining()
        else
            $("#min").prop('disabled', false)
            $("#max").prop('disabled', false)
            $("#answer").prop('disabled', true)
            $("#slider").slider('enable')
            $(@).html('Start')
            $(@).addClass('btn-primary')

            abortTraining()

    $('#answer').keypress( (e) ->
        if(e.keyCode == 13) # ENTER KEY PRESSED
            e.preventDefault()
            submitAnswer($(@).val())
    )
