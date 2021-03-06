# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# TODO: ORGANIZE VARIABLES - GLOBAL VARIABLES (window.*) ETC
allowedTrials = 2
progressCorrect = '#exercise-correct'
progressWrong = '#exercise-wrong'
historyLength = 10

# ------------------------
# TRAINING
# ------------------------
finishTraining = () ->
    payload = 
        "data": window.doneWords
        "name": $('#name').val()

    $('#name').val('')

    $.ajax '/exercise/finish',
        type: 'POST'
        contentType: "application/json"
        data: JSON.stringify(payload)
        error: (jqXHR, textStatus, errorThrown) ->
            console.log "AJAX Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
            console.log "Successfully saved your results."

    abortTraining()

startTraining = () ->
    # UI
    $("#min").prop('disabled', true)
    $("#max").prop('disabled', true)
    $(".wordlistpicker").prop('disabled', true)
    $(".wordlistpicker").selectpicker('refresh')
    $("#answer").prop('disabled', false)
    $("#slider").slider('disable')
    $("#start").html('Cancel')
    $("#start").css('border', '1px solid black')
    $("#start").removeClass('btn-primary')
    $(".row-odd").css('background-color', '#EEE')
    $(".row-odd").find('.headline').css('color', '#DDD')
    $("body").css('background-color', '#FFF')
    $(".row-even").find('.headline').css('color', '#EEE')
    $('#answer').focus()
    $('.vocab-settings').fadeOut('fast')
    $('.wordlistpicker-container').fadeOut('fast', ->
        $('.info').fadeIn('fast')
    )

    # TRAINING
    range = $('#slider').data('slider').getValue()
    $('.info-text').html('Words ' + range[0] + " - " + range[1] + 
        ' from <span class="wordlist">' + window.currentList + '</span>'
    )
    window.words = window.vocab.slice(range[0], range[1])
    window.trainingAmount = window.words.length
    window.repeatWords = []
    window.doneWords = []
    window.repetitionPhase = false

    resetExerciseProgress()
    enterReadyPhase()

abortTraining = () ->
    # UI    
    $("#min").prop('disabled', false)
    $("#max").prop('disabled', false)
    $(".wordlistpicker").prop('disabled', false)
    $(".wordlistpicker").selectpicker('refresh')
    $('#answer').show()
    $("#answer").prop('disabled', true)
    $("#slider").slider('enable')
    $('.alert').hide()
    $("#start").html('Start')
    $("#start").css('border', 'none')
    $("#start").addClass('btn-primary')
    $(".row-odd").css('background-color', '#FFF')
    $(".row-odd").find('.headline').css('color', '#EEE')
    $("body").css('background-color', '#EEE')
    $(".row-even").find('.headline').css('color', '#DDD')
    $("#answer").attr('placeholder', '')
    $('.vocab-settings').show()
    $('.wordlistpicker-container').show()
    $('.info').hide()

    # TRAINING
    resetExerciseProgress()
    $('#question').html(" ")
    $('#history').html("")
    $('#report').html("")
    $('#answer').val("")
    $('#question').css('color', 'black')

endTraining = () ->
    if window.repetitionPhase
        # END TRAINING
        report = $('<h3></h3>')
        if window.repeatWords.length == 0
            report.html("ALL CORRECT")
        else
            report.html("PROBLEMS WERE")
        $('#report').append(report)
        for w in window.repeatWords
            back = w["back"].join(' | ')
            front = w["front"].join(' | ')
            report = $('<p></p>').html(back + " - " + front)
            $('#report').append(report)

        $('#answer').hide()

        $('.alert').show()
        $('#name').focus()
    else
        # START REPETITION
        window.repetitionPhase = true
        window.words = $.extend(true, [], window.repeatWords)
        nextWord()

enterReadyPhase = () ->
    window.readyphase = true
    $('#answer').attr('placeholder', 'Ready? (Press Return)')

exitReadyPhase = () ->
    window.readyphase = false
    $('#answer').attr('placeholder', '')
    $('#answer').val('')
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
    for back in window.word["back"]
        if answer.toLowerCase() == back.toLowerCase()

            window.word["time"] += new Date().getTime() - window.startTime
            window.doneWords.push(window.word)

            if not window.repetitionPhase
                updateExerciseProgress()

            window.word['back']
            
            # Determine correct alternatives
            alternatives = $.extend(true, [], window.word["back"])
            alternatives.splice(alternatives.indexOf(answer), 1)

            if alternatives.length == 0
                pushHistory(answer, true)
            else
                pushHistory(answer, true, "Also: " + alternatives.join(' or '))

            nextWord()
            return

    handleWrong(answer)


handleWrong = (answer) ->
    window.currentTrials++
    window.word["trials"]++

    if window.currentTrials > allowedTrials
        $('#question').css('color', 'red')

        window.word["time"] += new Date().getTime() - window.startTime

        if window.repetitionPhase
            window.words.push(window.word)
        else
            window.repeatWords.push(window.word)
            updateExerciseProgress()

        pushHistory(answer, false, window.word['back'].join(' or '))
        enterReadyPhase()
        return

    pushHistory(answer, false)

nextWord = () ->
    if window.words.length == 0
        endTraining()
        return

    window.word = removeRandom(window.words)
    if not window.word["trials"]?
        window.word["trials"] = 1

    if not window.word["time"]?
        window.word["time"] = 0.0
    window.currentTrials = 1
    
    front = selectRandom(window.word["front"])
    $('#question').html(front)
    window.startTime = new Date().getTime();

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
    correctPercent = (correctness * 100).toFixed(2)
    wrongPercent = (wrongness * 100).toFixed(2) 
    total = (correctness * 100 + wrongness * 100).toFixed(2)

    if reset or correctPercent != 0.0
        $(progressCorrect).css('width', correctPercent + '%')
    if reset or wrongPercent != 0.0
        $(progressWrong).css('width', wrongPercent + '%')
    if reset
        $(progressCorrect).html('')
        $(progressWrong).html('')
        $('#exercise-label').html('')        
    else
        $(progressCorrect).html(correct)
        $(progressWrong).html(wrong)
        $('#exercise-label').html(total + '%')        


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
    initMin = Math.floor(numVocab / 2)
    initMax = numVocab
    updateLabelRange([initMin, initMax])

    if not window.wordslider?
        window.wordslider = $('#slider').slider(
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
    else
        window.wordslider.slider('setAttribute','min', min)
        window.wordslider.slider('setAttribute','max', max)
        window.wordslider.slider('setValue', [initMin, initMax])

    # FIX SLIDER WIDTH ISSUE
    $('#vocab-slide').width($('.vocab-settings-left').width())

    # EVENT REGISTRATION & INPUT SYNCHRONIZATION
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


loadVocabulary = (wordlist) ->
    payload =
        wordlist: wordlist

    # If wordlist is undefined, ajax will respond with words from the first vocab list
    $.ajax '/exercise/vocab',
        type: 'GET'
        dataType: 'json'
        data: payload
        error: (jqXHR, textStatus, errorThrown) ->
            console.log "AJAX Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
            window.vocab = data

            numVocab = window.vocab.length
            if numVocab > 0
                setupSliderInput(numVocab)
            else
                console.log "ERROR: No words in your vocabulary."


initWordListPicker = ->
    $('.wordlistpicker').selectpicker(
        style: 'btn-default'
    )

    $('.wordlistpicker').change( ->
        val = $(@).val()
        if window.currentList != val
            window.currentList = val
            loadVocabulary(val)
    )
    window.currentList = $('.wordlistpicker').val()


setupInputEvents = ->
    $('#start').click ->
        if $(@).html() == "Start"
            startTraining()
        else
            abortTraining()

    $('#awesome-btn').click ->
        finishTraining()

    $('#answer').keypress( (e) ->
        if e.keyCode == 13 # ENTER KEY PRESSED
            e.preventDefault()
            submitAnswer($(@).val())
    )

# ------------------------
# MAIN
# ------------------------
ready = ->
    window.wordslider = null
    loadVocabulary()
    initWordListPicker()
    setupInputEvents()

# Turbolink fix
$(document).ready(ready)
$(document).on('page:load', ready)
