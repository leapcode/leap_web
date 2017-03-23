describe("Calculate", function() {
  
  beforeEach(function() {
    calculate = new srp.Calculate();
  });

  // login attempt with correct password that failed never the less:
  var compare = {
    username: "blues",
    password: "justtest",
    salt: "6a6ef9ce5cb998eb",
      v: "a5da6d376d503e22d93385db0244c382d1413d9f721ad9866dfc5e895cf2a3331514ceec5f48aceab58b260651cc9ee1ba96d906f67a6b4a7414c82d1333607ebe96403ecc86050224dc4c17b1d30efdbb451a68d1b6a25cce10f0e844082329d3cb46e1c3d46298a0de2cd3b8c6acc1a80c206f0f10ec8cd3c050babdf338ba",
    aa: "4decb8543891f5a744b1e9b5bc375a474bfe3c5417e1db176cefcc7ba915338a14f309f8e0a4c7641bc9c9b9bd2e91c4d1beda1772c30d0350c9ba44f7c5911dfe6bb593ac2a2b30f1f6e5ec8a656cb4947c1907cf62f8d7283cbe32eb44b02158b51091ae130afa6063bb28cdea9ae159d4f222571e146f8715bfa31af09868",
    a: "d498c3d024ec17689b5320e33fc349a3f3f91320384155b3043fa410c90eab71",
    bb: "dee64fd54daafc18b338c5783ade3ff4275dfee8c97008e2d9fb445880a2e1d452c822a35e8e3f012bc6facaa28022f8de3fb1d632667d635abde0afc0ca4ed06c9197ea88f379042b10bc7b7f816a1ec14fefe6e9adef4ab904315b3a3f36749f3f6d1083b0eb0029173770f8e9342b098298389ba49a88d4ea6b78a7f576a4",
    s: "50973f6e8134f95bd04f54f522e6e57d957d0640f91f0a989ff775712b81d5856ae3bdd2aa9c5eda8019e9db18065519c99c33a62c7f12f98e7aed60b153feee9ab73ba1272b4d76aa002da8cd47c6da733c88a0e70d4c3d6752fd366d66efe40870d26fd5d1755883b9489721e1881376628bf6ef89902f35e5e7e31227e2f",
    k: "dd93e648abfe2ac6c6d46e062ded60b31ec043e55ceca1946ec29508f4c68461",
    m: "ccf0c492f715484dc8343e22cd5967c2c5d01de743c5f0a9c5cfd017db1804c"
  };
  
  it("calculates the proper A", function() {
    expect(calculate.A(compare.a)).toBe(compare.aa);
  });
  
  it("prefixes A with 0 if needed", function() {
    expect(calculate.A("3971782b")[0]).toBe("0");
  });
  
  it("calculates the right x", function() {
    x = calculate.X("testuser","password","7686acb8")
    expect(x).toBe('84d6bb567ddf584b1d8c8728289644d45dbfbb02deedd05c0f64db96740f0398');
  });

  it("calculates the right verifier", function() {
    calculate_and_compare_verifier(compare);
  });

  it("calculates the right verifier with umlauts", function() {
    with_umlauts = {
      username: "test_joakcq", 
      password: "fs5uofäöìfvqynn",
      salt: "eec1ff4c",
      v: "551e82de8d61a6575a3da7fbede61f6f38164ed52eb64db031c1ec2316b474745d3ff24408bfcca3c50fc53283f2f975feebf1564d197051c834a56bf8bd804f3696d81e579915141f306242f133db210cbd11385afff01c355ca8446d92d8a54ff147ebb0e1cd3d5c78750a0488f1453473e9449a946c7c9298c167cc5adafc"
    }
    calculate_and_compare_verifier(with_umlauts);
  });

  function calculate_and_compare_verifier(values) {
    x = calculate.X(values.username, values.password, values.salt)
    expect(calculate.V(x)).toBe(values.v);
  }
});
