var srp = (function(){

  function signup()
  {
    srp.remote.signup();
  };

  function login()
  {
    srp.remote.login();
  };

  function update(submitEvent)
  {
    srp.remote.update(submitEvent);
  };

  return {
    signup: signup,
    update: update,
    login: login
  }
}());

