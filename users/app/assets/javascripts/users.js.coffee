preventDefault = (event) ->
  event.preventDefault()

srp.session = new srp.Session()
srp.signedUp = ->
  srp.login()

srp.loggedIn = ->
  window.location = '/'

#// TODO: not sure this is what we want.
srp.updated = ->
  window.location = '/'

srp.error = (message) ->
  if $.isPlainObject(message) && message.errors
    for field, error of message.errors
      element = $('form input[name$="['+field+']"]')
      next unless element
      element.trigger('element:validate:fail.ClientSideValidations', error).data('valid', false)
  else
    alert(message)

pollUsers = (query, process) ->
  $.get( "/users.json", query: query).done(process)

followLocationHash = ->
  location = window.location.hash
  if location
    href_select = 'a[href="' + location + '"]'
    link = $(href_select)
    link.tab('show') if link

$(document).ready ->
  followLocationHash()
  $('#new_user').submit preventDefault
  $('#new_user').submit srp.signup
  $('#new_session').submit preventDefault
  $('#new_session').submit srp.login
  $('.user.form.change_password').submit srp.update
  $('.user.form.change_password').submit preventDefault
  $('.user.typeahead').typeahead({source: pollUsers});
  $('a[data-toggle="tab"]').on('shown', ->
    $(ClientSideValidations.selectors.forms).validate()
    )

