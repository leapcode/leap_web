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
    display_errors(message.errors)
  else
    alert(message)

display_errors = (errors) ->
  for field, error of errors
    if field == 'base'
      display_base_error(error);
    else
      display_field_error(field, error);

display_field_error = (field, error) ->
  element = $('form input[name$="['+field+']"]')
  return unless element
  element.trigger('element:validate:fail.ClientSideValidations', error).data('valid', false)

display_base_error = (message) ->
  messages = $('#messages')
  messages.append "<div class=\"alert alert-error\"><a class=\"close\" \"data-dismiss\"=\"alert\">×</a><div class=\"flash_error\">" + message + "</div></div>"


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
  $('.user.form.update_login_and_password').submit srp.update
  $('.user.form.update_login_and_password').submit preventDefault
  $('.user.typeahead').typeahead({source: pollUsers});
  $('a[data-toggle="tab"]').on('shown', ->
    $(ClientSideValidations.selectors.forms).validate()
    )

