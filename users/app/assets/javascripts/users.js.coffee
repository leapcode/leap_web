preventDefault = (event) ->
  event.preventDefault()

validOrAbort = (event) ->
  errors = {}
  
  abortIfErrors = ->
    return if $.isEmptyObject(errors)
    # we're relying on client_side_validations here instead of printing
    # our own errors. This gets us translatable error messages.
    $('.control-group.error input, .control-group.error select, control-group.error textarea').first().focus()
    event.stopImmediatePropagation()
    
  validatePassword = ->
    password = $('#srp_password').val()
    confirmation = $('#srp_password_confirmation').val()
    login = $('#srp_username').val()
  
    if password != confirmation
      errors.password_confirmation = "Confirmation does not match!"
    if password == login
      errors.password = "Password and Login may not match!"
    if password.length < 8
      errors.password = "Password needs to be at least 8 characters long!"

  validatePassword()
  abortIfErrors()
  
  
signup = (event) ->
  srp = new SRP(jqueryRest())
  srp.register ->
    window.location = '/'

login = (event) ->
  srp = new SRP(jqueryRest())
  srp.identify ->
    window.location = '/'


$(document).ready ->
  $('#new_user').submit preventDefault
  $('#new_user').submit validOrAbort
  $('#new_user').submit signup
  $('#new_session').submit preventDefault
  $('#new_session').submit login

