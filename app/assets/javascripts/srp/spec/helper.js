var specHelper = (function() {
  // HELPERS

  function setupFakeXHR() {
    this.xhr = sinon.useFakeXMLHttpRequest();
    var requests = this.requests = [];
    this.xhr.onCreate = function (xhr) {
      requests.push(xhr);
    };
    this.expectRequest = expectRequest;
    this.respondJSON = respondJSON;
    this.respondXML = respondXML;
  }

  // TODO: validate http verb
  function expectRequest(url, content, verb) {
    expect(this.requests.length).toBe(1);
    expect(this.requests[0].url).toBe(url);
    expect(decodeURI(this.requests[0].requestBody)).toBe(content);
    if (verb) {
      expect(this.requests[0].method).toBe(verb);
    }
  }

  function respondXML(content) {
    var request = this.requests.pop();
    header = { "Content-Type": "application/xml;charset=utf-8" };
    body = '<?xml version="1.0" encoding="UTF-8"?>\n';
    body += content;
    request.respond(200, header, body);
  }

  function respondJSON(object, responseCode) {
    var request = this.requests.pop();
    header = { "Content-Type": "application/json;charset=utf-8" };
    body = JSON.stringify(object);
    request.respond(responseCode || 200, header, body);
  }

  return {
    setupFakeXHR:  setupFakeXHR,
  }

})();

beforeEach(function () {
  setFixtures("<form action='.' onsubmit='return register()'> <table> <tr><td>Username:</td><td><input type='text' id='srp_username' value='testuser' /></td></tr> <tr><td>Password:</td><td><input type='password' id='srp_password' value='password'/></td></tr> </table> <input type='submit'/> </form> ");
});
