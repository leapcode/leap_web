describe("Account", function() {
  describe("without seeded values", function(){
    beforeEach(function() {
      account = new srp.Account();
    });

    it("fetches the password from the password field", function(){
      expect(account.password()).toBe("password");
    });

    it("fetches the login from the login field", function(){
      expect(account.login()).toBe("testuser");
    });

  });
  
  describe("with seeded values", function(){
    beforeEach(function() {
      account = new srp.Account("login", "secret");
    });

    it("uses the seeded password", function(){
      expect(account.password()).toBe("secret");
    });

    it("uses the seeded login", function(){
      expect(account.login()).toBe("login");
    });

  });
});
