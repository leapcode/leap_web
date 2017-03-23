srp.Account = function(login, password, id) {

  // Returns the user's identity
  this.login = function() {
    return login || document.getElementById("srp_username").value;
  };

  // Returns the password currently typed in
  this.password = function() {
    return password || document.getElementById("srp_password").value;
  };

  // The user's id
  this.id = function() {
    return id || document.getElementById("user_param").value;
  };
}
