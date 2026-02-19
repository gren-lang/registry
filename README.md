# The New Gren Package Registry

The goal of the new package registry is to eventually replace the packages site.
For the first release, however, we just want to do the minimum amount of work that gets us somewhere.

We'll start with a barebones web api, to be communicated with through the compiler.
Serving actual users via the browser will come later.

The goal is to be able to do the following operations:

* [ ] Register a new user, or login
* [ ] Register a publishing identity (`gren-lang` is a publishing identity, `me@example.com` is a user)
* [ ] Add or remove additional users to a publishing identity
* [ ] Permissions in a publishing identity (only download, publish new packages, user admin)
* [ ] Publish new packages/versions
* [ ] Revoke a package/version (the name/version is still registered, but the actual content is removed).
* [ ] Ask which version is latest for a given compiler version, and which was the previous version related to some version number.

Account creation or login is handled via an email magic link.
The client recieves a random token that they can use to exhange into a proper login token, but the endpoint doing the exhange will only respond once the user has clicked on a link they receive by e-mail.
This means we need some email sending provider (thinking Postmark).

Once you have a login token (stored somewhere on disk. `$HOME/.gren/user`?) you can create publishing identities and manage users connected to that identity.

Users in an identity can be allowed to:
* Download private packages only (might want to add a `private` field to `gren.json`)
* The above + publish new packages or versions of packages
* The above + add, remove and modify permissions on users

Publishing a package/versions is just the matter of uploading a bundle (compiler's `next` branch currently creates those), if you have the permissions.
Publishing a package should tell `packages.gren-lang.org` to update.

As much code as possible should be written in Gren, with as few dependencies as possible.
Start by persisting the registry via filesystem on disk.
Once task ports land (25S?), switch to sqlite via ports with litestream for backups.

## Local Development

This project uses [devbox](https://www.jetify.com/devbox) and [direnv](https://direnv.net/).
Install both for the smoothest experience.

Copy `.envrc.sample` to `.envrc` and set environment variables appropriately.
Then run `direnv allow` so it will be evaluated when you enter this directory.

You can run the server with `devbox services up`

To run in the background, run `devbox services up -b` and stop with `devbox services stop`

Run tests with `devbox run test`

See `devbox.json` for other local dev scripts.

## Open Questions

* [ ] Refresh tokens?
* [ ] Prevent spamming endpoints? (e.g. bots flooding system with spam users or publishing identities)

## TODO

* [ ] User Authentication API (in progress - see below)
* [ ] Package search
* [ ] Package docs
    * [ ] Avoid ambiguous type names (e.g. `Task` vs `Init.Task`)
    * [ ] Enable links to specific sections
    * [ ] Avoid ambiguous section anchors (e.g. [focus](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Dom#focus) section vs function)
    * [ ] Package doc search

## User Authentication

Goals:

- Create and authenticate users from CLI on the command line.
- Verify user identity using email.

Auth flow:

1. User initiates auth on CLI, providing email address.
2. CLI posts email address to the server, receives a fetch session token, and waits for confirmation code.
3. Server emails a confirmation code to the user. User enters code in CLI.
4. CLI posts fetch session token and email confirmation code to get a secure session token.
5. CLI saves token on disk to use for authenticated requests.

Goals:

- Not saving or requiring passwords.
- CLI auth tightly coupled to email confirmation.
- CLI auth loosely coupled to where you check your email.
    - email confirmation code is short and uses easily-identifiable characters
    - tokens are long UUIDs but managed by the CLI and server
