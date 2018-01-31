describe("Login with srp var", function() {

  var fixtures = {
    "failed_login": {
      "username": "asre",
      "password": "Started GET",
      "salt": "ae631d2d5ed2c41d",
      "verifier": "8abe157957f22cc3b0b004e964d8f4d036636b23c6489877db9a9f7e19f21b78df5b489171996dd4a57ab6714e31ed0f3187c930dd0b00654cab60aaf73d701cf71d3faed99da9cd37c0161c93f3e12c2627e286df9217bad7731d51c7558a7d07d9888808c5b62b275b07706cf2e3d0cdc628791c69975580f760c7bf28bae8",
      "a": "eb9784d9",
      "aa": "ab0109064a2da3c02c0cc6da028495d402affb814f4b40898c9c87922718bd03dbd41cf2fa0e23f4abd0f19722c3687b673177328ae4f74f48f7d8fafc30466652e97a2f8c438b471eb0ccbe66fb5bf0837ac7b2aa34bfc731714c3ce4fbb288abd59458e2e563391925a8b74b4179652839ea91da40a467702b1574728c9e22",
      "bb": "ccc834b851d7d6e1aa86969705ecd53fd47c5e94c1e31f739db3534a73dee8eed362747d7b4c60ea9169352000dfe42ca8ae5d3b20bb8f40590106021e7a4cd398ca2df55cc209ad9732c8d6bd6c6acf8a27254dac3c74cbb326ee53a4519e6a630ccadebf1434f5e3d9bf99c7cd301255c94710445383808638394dd641aa27",
      "s": "919418fb396e125dc8e881b01f3925029e8049e0f15032f601317a99489526fd46b8e8edb62962177b97efe2106a7da44b381e65a500ff1a86459683475b86b31fd81e73accc835a5e0da37b71ed68612c68fbe43a96b57bf3f5d560f71f37a3dbc7a2080c8a4dd7de1bb42cc6e1a21e66e3845f775cb4559ba9ac1faf551a39",
      "k": "0aa8c328244c426c6165be08a1fa8b07e2949c1df577466b4815109221e2da6b",
      "m": "8438a6e4f31334588b826ee92b7669dd8db59856c5934a9c659e1481bcdcae86",
      "m2": "ec1fd1de67a08b981016272222f54f4b1c42768cb46cd3675fe6573fd60eb186"
    },
    "py_srp": {
      // these need to be the same as in the spec runner:
      username: "testuser",
      password: "password",
      salt: '628365a0',
      verifier: '4277ddfdd111cc6a4cd27af570172a93ff4dddd9441ad89ecd78b08504812819d85712fbb6d2b487798ea0e19eeb960ce129725286d1c891314c0620abce02ac0a37fac823d0858553aed30ba99622ec9c66cc937016b96e82ef9e3b5d06e1db707293459c0aa8e082b528fd236cda347c45d8b022a9d4f3701c696e0397332a',
      // a valid auth attempt for the user / password given in the spec runner:
      a: 'a5cccf937ea1bf72df5cf8099442552f5664da6780a75436d5a59bc77a8a9993',
      aa: 'e67d222244564ccd2e37471f226b999a4e987f3d494c7d80e0d36169efd6c6c6d857a96924c25fc165e5e9b0212a31c30701ec376dc32e36be00bbcd6d2104789d368af984e26fc094374f90ee5746478f14cec45c7e131a3cbce15fe79e98894213dac4e63c3f73f644fe25aa8707bc58859dfd1b36972e4e34169db2622899',
      // just for the sake of having a complete set of test vars:
      b: '6aa5c88d1877af9907ccefad31083e1102a7121dc04706f681f66c8680fb7f05', 
      bb: 'd56a80aaafdf9f70598b5d1184f122f326a333fafd37ab76d6f7fba4a9c4ee59545be056335150bd64f04880bc8e76949469379fe9de17cf6f36f3ee11713d05f63050486bc73c545163169999ff01b55c0ca4e90d8856a6e3d3a6ffc70b70d993a5308a37a5c2399874344e083e72b3c9afa083d312dfe9096ea9a65023f135',
      k: 'db6ec0bdab81742315861a828323ff492721bdcd114077a4124bc425e4bf328b',
      m: '640e51d5ac5461591c31811221261f0e0eae7c08ce43c85e9556adbd94ed8c26',
      m2: '49e48f8ac8c4da0e8a7374f73eeedbee2266e123d23fc1be1568523fc9c24b1e',
    }
  };


  describe("(Compatibility with py-srp)", function (){
    var A_, callback;
    var data = fixtures.failed_login;
    var old_pass, old_login, old_conf;


    beforeEach(function() {
      specHelper.setupFakeXHR.apply(this);

      calculate = new srp.Calculate();
      calculate.randomSalt = function() {return "4c78c3f8"};
      srp.session = new srp.Session(undefined, calculate);

      A_ = srp.session.calculateAndSetA(data.a)
      old_login = $('#srp_username').val();
      old_conf = $('#srp_password_confirmation').val();
      old_pass = $('#srp_password').val();
      $('#srp_username').val(data.username);
      $('#srp_password_confirmation').val(data.password);
      $('#srp_password').val(data.password);
    });

    afterEach(function() {
      $('#srp_username').val(old_login);
      $('#srp_password_confirmation').val(old_conf);
      $('#srp_password').val(old_pass);
      this.xhr.restore();
    });

    it("calculates the same A", function(){
      expect(A_).toBe(data.aa);
    });

    it("calculates the same key", function(){
      srp.session.calculations(data.salt, data.bb);
      expect(srp.session.key()).toBe(data.k);
    });

    it("authenticates successfully", function(){
      srp.loggedIn = jasmine.createSpy();
      srp.login();

      this.expectRequest('/1/sessions.json', 'login=' +data.username+ '&A=' +data.aa, 'POST');
      this.respondJSON({salt: data.salt, B: data.bb});
      this.expectRequest('/1/sessions/'+data.username+'.json', 'client_auth='+data.m, 'PUT');
      this.respondJSON({M2: data.m2});

      expect(srp.loggedIn).toHaveBeenCalled();
    });
    
    it("reports errors during handshake", function(){
      srp.error = jasmine.createSpy();
      var error = {login: "something went wrong on the server side"};
      srp.login();

      this.expectRequest('/1/sessions.json', 'login=' +data.username+ '&A=' +data.aa, 'POST');
      this.respondJSON(error, 422);
      //this.expectNoMoreRequests();

      expect(srp.error).toHaveBeenCalledWith(error);
    });
    
    it("rejects B = 0", function(){
      srp.loggedIn = jasmine.createSpy();
      srp.error = jasmine.createSpy();
      srp.login();

      this.expectRequest('/1/sessions.json', 'login=' +data.username+ '&A=' +data.aa, 'POST');
      this.respondJSON({salt: data.salt, B: 0});
      // aborting if B=0
      expect(this.requests).toEqual([]);
      expect(srp.error).toHaveBeenCalledWith("Server send random number 0 - could not login.");
      expect(srp.loggedIn).not.toHaveBeenCalled();
    });
  });


});
