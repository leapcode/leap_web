(function() {



  //
  // LOCAL FUNCTIONS
  //

  var poll_users,
      poll_identities,
      prevent_default,
      clear_errors,
      validate_password_confirmation,
      signup,
      update_user;

  prevent_default = function(event) {
    return event.preventDefault();
  };

  poll_users = function(query, process) {
    return $.get("/1/users.json", {
      query: query
    }).done(process);
  };

  poll_identities = function(query, process) {
    return $.get("/identities.json", {
      query: query
    }).done(process);
  };

  clear_errors = function() {
    return $('#messages').empty();
  };

  signup = function(submitEvent) {
    var form = submitEvent.target;
    var validations = form.ClientSideValidations
    if ( ( typeof validations === 'undefined' ) ||
         $(form).isValid(validations.settings.validators) ) {
      srp.signup();
    }
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
      $(form).find('.btn[type="submit"]').button('reset');
    });
  };

  validate_password_confirmation = function(submitEvent) {
    var form = submitEvent.target;
    var password = $(form).find('input#srp_password').val();
    var confirmation = $(form).find('input#srp_password_confirmation').val();
    if (password === confirmation) {
      return true;
    }
    else {
      displayFieldError("password_confirmation", "does not match.");
      submitEvent.stopImmediatePropagation()
      return false;
    }
  };

  var account = {

    // Returns the user's identity
    login: function() {
      return document.getElementById("srp_username").value;
    },

    // Returns the password currently typed in
    password: function() {
      return document.getElementById("srp_password").value;
    },

    // The user's id
    id: function() {
      return document.getElementById("user_param").value;
    },

    // Returns the invite code currently typed in
    loginParams: function () {
      return { "invite_code": document.getElementById("srp_invite_code").value };
    }
  }

  //
  // PUBLIC FUNCTIONS
  //

  srp.session = new srp.Session(account);

  srp.signedUp = function() {
    return srp.login();
  };

  srp.loggedIn = function() {
    return srp.localeRedirect('/');
  };

  srp.updated = function() {
    return srp.localeRedirect('/users/' + srp.session.id());
  };

  // redirect, while preserving locale if set by url path.
  srp.localeRedirect = function(path) {
    var localeMatch = window.location.pathname.match(/^(\/[a-z]{2})\//)
    if (localeMatch) {
      return window.location = localeMatch[1] + path;
    } else {
      return window.location = path;
    }
  };

  //
  // if a json request returns an error, this function gets called and
  // decorates the appropriate fields with the error messages.
  //
  srp.error = function(message) {
    clear_errors();
    var errors = extractErrors(message);
    displayErrors(errors);
    $('.btn[type="submit"]').button('reset');
  }

  function extractErrors(message) {
    if ($.isPlainObject(message)) {
      return message.errors || { base: message.error };
    } else {
      return {
        base: '<pre>' + message + '</pre>'
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
    var message = $.isArray(error) ? error[0] : error;
    var element = $('form input[name$="[' + field + ']"]');
    if (element) {
      addError(element, message);
    }
  };

  function addError(element, message) {
    var form = element.closest('form');
    var settings = form[0].ClientSideValidations.settings;
    ClientSideValidations.formBuilders['SimpleForm::FormBuilder'].add(element, settings, message);

  }

//
// INIT
//

  $(document).ready(function() {
    $('.hidden.js-show').removeClass('hidden');
    $('.js-show').show();
    $('#new_user').submit(prevent_default);
    $('#new_user').submit(validate_password_confirmation);
    $('#new_user').submit(signup);
    $('#new_session').submit(prevent_default);
    $('#new_session').submit(srp.login);
    $('#update_login_and_password').submit(prevent_default);
    $('#update_login_and_password').submit(srp.update);
    $('#update_pgp_key').submit(prevent_default);
    $('#update_pgp_key').submit(update_user);
    $('#user-typeahead').typeahead({ source: poll_users });
    $('#identity-typeahead').typeahead({ source: poll_identities });
  });

}).call(this);
