# Privacy Policy

This document is our Privacy Policy, which describes what information we collect and what it's used for. It applies to all interactions with **<%=APP_CONFIG[:domain]%>**. Your use of **<%=APP_CONFIG[:domain]%>** services will constitute your agreement to this Privacy Policy. Please also review our [Terms of Service](terms-of-service).

<p class="alert alert-info">
  <b>Summary:</b> We collect very little personal information, and none of the information we do collect is ever shared or disclosed to anyone.
</p>

## Information we collect and retain

**Registration information:** When you create an account, we retain the date and time you registered, along with your username and email aliases or forwarding addresses.

**Customer code:** If you sign up for recurring payments, we retain a unique customer code. Although it may appear that you enter your billing information at <%=APP_CONFIG[:domain]%>, this information is sent directly to a separate payment processing company and is not seen or retained by us. However, the customer code that we do retain for recurring payments can be used to lookup billing information held by the payment processor.

**Public key:** In order for secure communication to work, your device generates a private key and public key. The public key is pushed to our services and published publicly.

**Help tickets:** The content of any help ticket you create or comment on while authenticated will be associated with your user account. You can choose to fill out a help ticket anonymously by creating a ticket while not logged in. We periodically delete old help tickets that are closed.

**Session identifiers:** While currently logged in, either via the client application or the web application, we keep a temporary session identifier on your computer that your software uses to prove your authentication state. In the web browser, this consists of a session "cookie". In the client, this consists of a similar session token. In both cases, these are erased immediately after the user logs out or the session expires. We do not use any third party cookies or tracking of any kind.

**Email transit logs:** In order to detect when our servers are under attack from a "spam bomb" or when a spammer is using our system, we keep a log of the "from" or "to" information for every message relayed. These logs are purged on a daily basis.

**Month of last log in**: We keep a record of the current calendar month and year of your last successful authentication (in order to be able to disable dormant accounts). We do not record the time or day of the last log in.

## Information we choose to not retain

**IP addresses**: No IP addresses of any user for any service are retained. The IP addresses are removed from all log files and replaced with all zeros before the logs are written to disk. This is important, because a user's IP address can disclose both their real identity and physical location.

**Browser fingerprint**: Your web browser communicates uniquely identifying information to all web servers it visits by allowing the site to know details about your operating system, browser information, plugins installed, fonts installed, screen resolution, and much more. We do not retain any of this information.

**Credentials for encrypted internet service**: If you use the encrypted internet service, your client presents our servers with a certificate to confirm you are a valid user before a connection is established. These certificates regularly expire, and the user must log in every month or two in order to obtain a new certificate. However, we do not keep a record of which user account is associated with which authentication certificate.

**Message metadata**: Even when using end-to-end OpenPGP encryption for email messages, the email "subject" and routing information regarding the message "from" and "to" are seen by our servers in the clear when the email initially arrives. This is due to inherent limitations in the email protocol and in OpenPGP. Immediately upon reception, we encrypt the entire message, including the metadata, and store it so that only you can read anything about it.

**Cleartext messages**: Some messages that you send or receive will not be end-to-end encrypted (for example, when the other party does not support email encryption). In these cases, when cleartext messages are received or sent, we do not retain anything about these messages other than what has been specified above. Immediately upon reception, we encrypt the entire message and store it so that only you can read anything about it.

## Information we cannot retain

**Your password**: Unlike most services, your user password never travels to our servers. We use a system called Secure Remote Password (SRP), a type of 'zero-knowledge proof' cryptography that ensures the server has no access to your password and that you can't be tricked into authenticating with an impostor server. However, there are two limitations: (1) An attacker might still guess your password or discover it by trying millions of combinations, but we have no special access in this regard (SRP makes this much more difficult, but not impossible); (2) The guarantees of SRP are only strong if you use the client application for authentication, but are less strong if you login directly through the website (this is because browser security is relatively weak and an attacker might find a way to modify the computer code in the web page that handles this secure authentication).

**Your communication**: Once stored, we cannot read the content or metadata of your communication. It is entirely encrypted and decrypted on your device. We also cannot recover it if you lose your password.

**Your secret keys**: For encryption to work, the client application manages numerous secret keys on your behalf. These keys are also backed up and stored on our servers, but they are saved anonymously, and encrypted so that someone needs to know both the username and password to query and decrypt these keys.

## How we use or disclose collected information

**We do not disclose user information**: We retain only the bare minimum of information about each user that is required to make the service work. We do not disclose, sell, or share any of it.

**Academic research**: Anonymous, aggregated information that cannot be linked back to an individual user may be made available to third parties for the sole purpose of researching better systems for anonymous and secure communication. For example, we may aggregate information on how many messages a typical user sends and receives, and with what frequency.

**Account deletion**: You may choose to delete your <%=APP_CONFIG[:domain]%> account at any time. Doing so will destroy all the data we retain that is associated with your account. The one exception is that your public key may still be available, although we will revoke our endorsement of this key. The usernames associated with deleted accounts remain unavailable for others to use for at least two years, possibly longer.

## Changes to this policy

We reserve the right to change this policy. If we make major changes, we will notify our users in a clear and prominent manner. Minor changes may only be highlighted in the footer of our website.