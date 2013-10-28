(function() {
  //
  // LOCAL FUNCTIONS
  //

  var poll_users, 
      prevent_default, 
      form_failed, 
      form_passed, 
      clear_errors,
      update_user;

  prevent_default = function(event) {
    return event.preventDefault();
  };

  poll_users = function(query, process) {
    return $.get("/1/users.json", {
      query: query
    }).done(process);
  };

  clear_errors = function() {
    return $('#messages').empty();
  };

  update_user = function(submitEvent) {
    var form = submitEvent.target;
    var token = form.dataset.token;
    var url = form.action;
    var req = $.ajax({
      url: url,
      type: 'PUT',
      headers: { Authorization: 'Token token="' + token + '"' },
      data: $(form).serialize()
    });
    req.done( function() {
      $(form).find('input[type="submit"]').button('reset');
    });
  };

  markAsSubmitted = function(submitEvent) {
    var form = submitEvent.target;
    $(form).addClass('submitted')
    // bootstrap loading state:
    $(form).find('input[type="submit"]').button('loading');
  };

  resetButtons = function(submitEvent) {
    var form = $('form.submitted')
    // bootstrap loading state:
    $(form).find('input[type="submit"]').button('reset');
    $(form).removeClass('submitted')
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
    clear_errors();
    var errors = extractErrors(message);
    displayErrors(errors);
    resetButtons();
  }

  function extractErrors(message) {
    if ($.isPlainObject(message) && message.errors) {
      return message.errors;
    } else {
      return {
        base: (message.error || JSON.stringify(message))
      };
    }
  }

  function displayErrors(errors) {
    for (var field in errors) {
      var error = errors[field];
      if (field === 'base') {
        alert_message(error);
      } else {
        displayFieldError(field, error);
      }
    }
  }

  function displayFieldError(field, error) {
    var element = $('form input[name$="[' + field + ']"]');
    if (element) {
      element.trigger('element:validate:fail.ClientSideValidations', error).data('valid', false);
    }
  };

  //
  // INIT
  //

  $(document).ready(function() {
    $('form').submit(markAsSubmitted);
    $('#new_user').submit(prevent_default);
    $('#new_user').submit(srp.signup);
    $('#new_session').submit(prevent_default);
    $('#new_session').submit(srp.login);
    $('#update_login_and_password').submit(prevent_default);
    $('#update_login_and_password').submit(srp.update);
    $('#update_pgp_key').submit(prevent_default);
    $('#update_pgp_key').submit(update_user);
    return $('#user-typeahead').typeahead({
      source: poll_users
    });
  });

}).call(this);
