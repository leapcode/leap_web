# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

validate_password = (event) ->

  password = $('#srp_password').val()
  confirmation = $('#srp_password_confirmation').val()
  login = $('#srp_username').val()

  if password != confirmation
    alert "Password and Confirmation do not match!"
    $('#srp_password').focus()
    return false
  if password == login
    alert "Password and Login may not match!"
    $('#srp_password').focus()
    return false
  if password.length < 8
    alert "Password needs to be at least 8 characters long!"
    $('#srp_password').focus()
    return false
  
  return true
  

signup = (event) ->
  srp = new SRP(jqueryRest())
  srp.register()
  false

login = (event) ->
  srp = new SRP(jqueryRest())
  srp.identify ->
    window.location = '/'
  false


$(document).ready ->
  $('#new_user').submit validate_password
  $('#new_user').submit signup
  $('#new_session').submit login

