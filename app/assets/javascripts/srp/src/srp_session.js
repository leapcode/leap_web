srp.Session = function(account, calculate) {

  // default for injected dependency
  account = account || new srp.Account();
  calculate = calculate || new srp.Calculate();

  var a = calculate.randomEphemeral();
  var A = calculate.A(a);
  var S = null;
  var K = null;
  var M = null;
  var M2 = null;
  var authenticated = false;

  // *** Accessor methods ***

  // allows setting the random number A for testing

  this.calculateAndSetA = function(_a) {
    a = _a;
    A = calculate.A(_a);
    return A;
  };

  this.update = function() {
    var salt = calculate.randomSalt();
    var x = calculate.X(account.login(), account.password(), salt);
    return {
      login: account.login(),
      password_salt: salt,
      password_verifier: calculate.V(x)
    };
  }

  this.signup = function() {
    var loginParams = this.update();

    if (account.loginParams) {
      var extraParams = account.loginParams();
      for (var attr in extraParams) {
        loginParams[attr] = extraParams[attr];
      }
    }

    return loginParams;
  };

  this.handshake = function() {
    return {
      login: account.login(),
      A: this.getA()
    };
  };

  this.getA = function() {
    return A;
  }

  // Delegate login & id so they can be used when talking to the remote
  this.login = account.login;
  this.id = account.id;

  // Calculate S, M, and M2
  // This is the client side of the SRP specification
  this.calculations = function(salt, ephemeral)
  {
    //S -> C: s | B
    var B = calculate.zeroPrefix(ephemeral);
    salt = calculate.zeroPrefix(salt);
    var x = calculate.X(account.login(), account.password(), salt);
    S = calculate.S(a, A, B, x);
    K = calculate.K(S);

    // M = H(H(N) xor H(g), H(I), s, A, B, K)
    var xor = calculate.nXorG();
    var hash_i = calculate.hash(account.login())
    M = calculate.hashHex(xor + hash_i + salt + A + B + K);
    //M2 = H(A, M, K)
    M2 = calculate.hashHex(A + M + K);
  };


  this.getS = function() {
    return S;
  }

  this.getM = function() {
    return M;
  }

  this.validate = function(serverM2) {
    authenticated = (serverM2 && serverM2 == M2)
    return authenticated;
  }

  // If someone wants to use the session key for encrypting traffic, they can
  // access the key with this function.
  this.key = function()
  {
    if(K) {
      return K;
    } else {
      this.onError("User has not been authenticated.");
    }
  };

  // Encrypt plaintext using slowAES
  this.encrypt = function(plaintext)
  {
    var key = cryptoHelpers.toNumbers(session.key());
    var byteMessage = cryptoHelpers.convertStringToByteArray(plaintext);
    var iv = new Array(16);
    rng.nextBytes(iv);
    var paddedByteMessage = slowAES.getPaddedBlock(byteMessage, 0, byteMessage.length, slowAES.modeOfOperation.CFB);
    var ciphertext = slowAES.encrypt(paddedByteMessage, slowAES.modeOfOperation.CFB, key, key.length, iv).cipher;
    var retstring = cryptoHelpers.base64.encode(iv.concat(ciphertext));
    while(retstring.indexOf("+",0) > -1)
      retstring = retstring.replace("+", "_");
    return retstring;
  };
};

