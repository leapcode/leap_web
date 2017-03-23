describe("Session", function() {

  // data gathered from py-srp and ruby-srp
  var old_compare = {
    username: "UC6LTQ",
    password: "PVSQ7DCEIR0B",
    salt: "d6ed8dba",
    v: "c86a8c04a4f71cb10bfe3fedb74bae545b9a20e0f3e95b6334fce1cb3384a296f75d774a3829ffd63f405f13f58ffbae415fd234b08b996c11e8618c17961defcebb1d244b388b75cf36882ee97182a900ebeaf7cffa0a83eed294f3a9449a06beb88954952759d2957b80ef851f4cc4fcaa6001fee4f00c273ecdd712d48371",
    aa: "4decb8543891f5a744b1e9b5bc375a474bfe3c5417e1db176cefcc7ba915338a14f309f8e0a4c7641bc9c9b9bd2e91c4d1beda1772c30d0350c9ba44f7c5911dfe6bb593ac2a2b30f1f6e5ec8a656cb4947c1907cf62f8d7283cbe32eb44b02158b51091ae130afa6063bb28cdea9ae159d4f222571e146f8715bfa31af09868",
    a: "d498c3d024ec17689b5320e33fc349a3f3f91320384155b3043fa410c90eab71",
    bb: "5f5bedd1f95b6b0d6809614f162e49753acce6979e1041f4da5bfa91e1dadd2a5470270ed102a49c5f74fd42f2b61a8a1a43218159a22b31a7cbd4670679480e56d0e4e72a22c07e07102ff063045d0c3c96085dec1cc2959453e0299890bd95af76403cec6ec5f212667a75ae6f4a8327183d72c3ee85792ca43820fbccf244",
    m: "bc30b8781e67a657e93d0a6cf7e7847fc60f79e2b0641e9c26b3522bc8f974cc"
  }

  // login attempt with correct password that failed never the less:
  var zero_prefixed_m = {
    username: "blues",
    password: "justtest",
    salt: "6a6ef9ce5cb998eb",
      v: "a5da6d376d503e22d93385db0244c382d1413d9f721ad9866dfc5e895cf2a3331514ceec5f48aceab58b260651cc9ee1ba96d906f67a6b4a7414c82d1333607ebe96403ecc86050224dc4c17b1d30efdbb451a68d1b6a25cce10f0e844082329d3cb46e1c3d46298a0de2cd3b8c6acc1a80c206f0f10ec8cd3c050babdf338ba",
    aa: "4decb8543891f5a744b1e9b5bc375a474bfe3c5417e1db176cefcc7ba915338a14f309f8e0a4c7641bc9c9b9bd2e91c4d1beda1772c30d0350c9ba44f7c5911dfe6bb593ac2a2b30f1f6e5ec8a656cb4947c1907cf62f8d7283cbe32eb44b02158b51091ae130afa6063bb28cdea9ae159d4f222571e146f8715bfa31af09868",
    a: "d498c3d024ec17689b5320e33fc349a3f3f91320384155b3043fa410c90eab71",
    bb: "dee64fd54daafc18b338c5783ade3ff4275dfee8c97008e2d9fb445880a2e1d452c822a35e8e3f012bc6facaa28022f8de3fb1d632667d635abde0afc0ca4ed06c9197ea88f379042b10bc7b7f816a1ec14fefe6e9adef4ab904315b3a3f36749f3f6d1083b0eb0029173770f8e9342b098298389ba49a88d4ea6b78a7f576a4",
    s: "050973f6e8134f95bd04f54f522e6e57d957d0640f91f0a989ff775712b81d5856ae3bdd2aa9c5eda8019e9db18065519c99c33a62c7f12f98e7aed60b153feee9ab73ba1272b4d76aa002da8cd47c6da733c88a0e70d4c3d6752fd366d66efe40870d26fd5d1755883b9489721e1881376628bf6ef89902f35e5e7e31227e2f",
    k: "dd93e648abfe2ac6c6d46e062ded60b31ec043e55ceca1946ec29508f4c68461",
    m: "0ccf0c492f715484dc8343e22cd5967c2c5d01de743c5f0a9c5cfd017db1804c"
  };

  var short_b = {
    "username": "fwe",
    "password": "eckout -b ne",
    "salt": "67f5f4aaf82a2a86",
    "verifier": "d0624d86b8ce793e8570d0a8e31df50bb5bd7c6bf56926b00b10125c541d663324018be5a9c9ec794e44e1be739270d0fa258af0e15c780d47ff889c881c7a6b22fd201265471953f2788f08b2f95709602b1a47207241432226bba224285c8ed706d0a47a49eb06c111dfdafe01fe6ac3ab98c9a4958a00a136d9c069bea065",
    "a": "b82dbaac",
    "aa": "6e0197741d4da91a97adb05c705dae37a778d44cab697afdbcfc2450a5ccbc96dae1f4144a8446b53bfda65bc4ae4bc04c81f41f17da3389a5477bd8c5799538fffda2d745a4aa0381297c904b474d0525c2d08b4f70f7d3f9c1c52a0e126fc3402e37ea82aed603fe76fa2d8827e1e5d80996260a8aba6dc53e5e57dd7bd6a4",
    "bb": "c9ffd5cb17e29aedf08fb37f54af2f4b798ce8341d8d1f36fde589e76f8aa2541118125d419632eef1582fb4fe7d5df4e795c808b0b2f964f67927b73be6f7545f2d291b9b36ab3d4b9fd0eb506f22887706b94c36ff963af44050bd89043d85b6f75846244785624fd2afb91ee1b5706b5a6f453f057be14537faa8051be56",
    "s": "ca95b0d1223f4180f9b664d7aab69325263ee8700c02cbb7b3e67f1b08f94e11397f03faf186559602f9948305c73a6b69eb31770421f9e69757a3e4235e61197eab703e8378a290d70c335f5b4a39af402d9c68512def102737c5e70182645f3a1b9e8dcfea6eb4407a2bfbe1d923b6a7322e1b058e2f551f584ab12b61bc2b",
    "k": "2cc2a0641bfd142a9c34b038c61e64a2298d1fd07de10fae945ad9b1a6172d19",
    "m": "c3e3096ed1553a7dad36d600cee4e2f43fa67e306ae9771fc045d4f1b092d5e6",
    "m2": "13bae65005e54e6ccfc5c5d04e143c4ff1124972875be6860aa8a99ab179ebf3"
  }

  var session;

  it("calculates the proper M even if that is 0 prefixed (INTEGRATION)", function() {
    var compare = zero_prefixed_m;
    account = new srp.Account(compare.username, compare.password);
    session = new srp.Session(account);
    session.calculateAndSetA(compare.a);
    session.calculations(compare.salt, compare.bb);
    expect(session.getS().toString(16)).toBe(compare.s);
    expect(session.key()).toBe(compare.k);
    expect(session.getM()).toBe(compare.m);
  });
  
  it("calculates the proper M from a smaller B (INTEGRATION)", function() {
    // B has one less char than usual
    var compare = short_b;
    account = new srp.Account(compare.username, compare.password);
    session = new srp.Session(account);
    session.calculateAndSetA(compare.a);
    session.calculations(compare.salt, compare.bb);
    expect(session.getS().toString(16)).toBe(compare.s);
    expect(session.key()).toBe(compare.k);
    expect(session.getM()).toBe(compare.m);
  });


  it("delegates login", function() {
    var compare = zero_prefixed_m;
    account = new srp.Account(compare.username, compare.password);
    session = new srp.Session(account);
    expect(session.login()).toBe(compare.username);
  });

  it('calculates secure user parameters for signup', function() {
    var compare = short_b;
    account = new srp.Account(compare.username, compare.password);
    session = new srp.Session(account);

    var signupParams = session.signup();

    expect(Object.keys(signupParams)).toEqual(['login', 'password_salt', 'password_verifier']);
  });

  it('calculates secure user parameters for update', function() {
    var compare = short_b;
    account = new srp.Account(compare.username, compare.password);
    session = new srp.Session(account);

    var signupParams = session.update();

    expect(Object.keys(signupParams)).toEqual(['login', 'password_salt', 'password_verifier']);
  });

  it("grabs extra signup parameters from account", function() {
    account = jasmine.createSpyObj('account', ['login', 'password']);
    account.loginParams = function() {
      return {
        "extraParam": "foobar"
      }
    }
    session = new srp.Session(account);

    expect(session.signup().extraParam).toBe("foobar");
  });

});
