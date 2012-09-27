API tests
==========


Testing the restful api from a simple python client as that's what we'll be using.

This test so far mostly demoes the API. We have no SRP calc in there.

TODO: keep track of the cookies during login. The server uses the session to keep track of the random numbers A and B.

The output of signup_and_login_wrong_password pretty well describes the SRP API:

```
POST: http://localhost:9292/users.json
    {"user[password_salt]": "54321", "user[password_verifier]": "12345", "user[login]": "SWQ055"}
 -> {"password_salt":"54321","login":"SWQ055"}
POST: http://localhost:9292/sessions
    {"A": "12345", "login": "SWQ055"}
 -> {"B":"1778367531e93a4c7713c76f67649f35a4211ebc520926ae8c3848cd66171651"}
PUT: http://localhost:9292/sessions/SWQ055
    {"M": "123ABC"}
 -> {"field":"password","error":"wrong password"}
```
