# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

preventDefault = (event) ->
  event.preventDefault()

validOrAbort = (event) ->
  errors = {}
  
  abortIfErrors = ->
    return if $.isEmptyObject(errors)
    $.each errors, (field, error) ->
      alert(error) 
      $('#srp_password').focus()
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

