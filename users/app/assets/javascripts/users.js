(function() {
  //
  // LOCAL FUNCTIONS
  //

  var poll_users, prevent_default, form_failed, form_passed;

  prevent_default = function(event) {
    return event.preventDefault();
  };

  poll_users = function(query, process) {
    return $.get("/1/users.json", {
      query: query
    }).done(process);
  };

  //
  // PUBLIC FUNCTIONS
  //

  srp.session = new srp.Session();

  srp.signedUp = function() {
    return srp.login();
  };

  srp.loggedIn = function() {
    return window.location = '/';
  };

  srp.updated = function() {
    return window.location = '/users/' + srp.session.id();
  };

  //
  // if a json request returns an error, this function gets called and
  // decorates the appropriate fields with the error messages.
  //
  srp.error = function(message) {
    var element, error, field;
    if ($.isPlainObject(message) && message.errors) {
      for (field in message.errors) {
        error = message.errors[field];
        element = $('form input[name$="[' + field + ']"]');
        if (!element) {
          next;
        }
        element.trigger('element:validate:fail.ClientSideValidations', error).data('valid', false);
      }
    } else if (message.error) {
      alert_message(message.error);
    } else {
      alert_message(JSON.stringify(message));
    }
  };

  //
  // INIT
  //

  $(document).ready(function() {
    $('#new_user').submit(prevent_default);
    $('#new_user').submit(srp.signup);
    $('#new_session').submit(prevent_default);
    $('#new_session').submit(srp.login);
    $('#update_login_and_password').submit(prevent_default);
    $('#update_login_and_password').submit(srp.update);
    return $('#user-typeahead').typeahead({
      source: poll_users
    });
  });

}).call(this);
