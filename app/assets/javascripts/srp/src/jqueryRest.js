srp.remote = (function(){
  var jqueryRest = (function() {

    // TODO: Do we need to differentiate between PUT and POST?
    function register(session) {
      return $.post("/1/users.json", {user: session.signup() });
    }

    function update(session, token) {
      return $.ajax({
        url: "/1/users/" + session.id() + ".json",
        type: 'PUT',
        headers: { Authorization: 'Token token="' + token + '"' },
        data: {user: session.update() }
      });
    }

    function handshake(session) {
      return $.post("/1/sessions.json", session.handshake());
    }

    function authenticate(session) {
      return $.ajax({
        url: "/1/sessions/" + session.login() + ".json",
        type: 'PUT',
        data: {client_auth: session.getM()}
      });
    }

    return {
      register: register,
      update: update,
      handshake: handshake,
      authenticate: authenticate
    };
  }());


  function signup(){
    jqueryRest.register(srp.session)
    .done(srp.signedUp)
    .fail(error)
  };

  function update(submitEvent){
    var form = submitEvent.target;
    var token = form.dataset.token;
    jqueryRest.update(srp.session, token)
    .done(srp.updated)
    .fail(error)
  };

  function login(){
    jqueryRest.handshake(srp.session)
    .done(receiveSalts)
    .fail(error)
  };

  function receiveSalts(response){
    // B = 0 will make the algorithm always succeed
    // -> refuse such a server answer
    if(response.B === 0) {
      srp.error("Server send random number 0 - could not login.");
    }
    else if(! response.salt || response.salt === 0) {
      srp.error("Server failed to send salt - could not login.");
    }
    else
    {
      srp.session.calculations(response.salt, response.B);
      jqueryRest.authenticate(srp.session)
      .done(confirmAuthentication)
      .fail(error);
    }
  };

  // Receive M2 from the server and verify it
  // If an error occurs, raise it as an alert.
  function confirmAuthentication(response)
  {
    if (srp.session.validate(response.M2))
      srp.loggedIn();
    else
      srp.error("Server key does not match");
  };

  // The server will send error messages as json alongside
  // the http error response.
  function error(xhr, text, thrown)
  {
    if (xhr.responseText && xhr.responseText != "")
      srp.error($.parseJSON(xhr.responseText));
    else
      srp.error("Server did not respond.");
  };

  return {
    signup: signup,
    update: update,
    login: login
  }

}());
