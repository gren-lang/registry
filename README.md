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

1. CLI posts email address to the server (IN PROGRESS)
    1. [X] server finds or creates row in `user` table
    2. [X] server creates new row in `session` table with:
        - `email_validation_token` for unique url for user to validate their email address and get a `validation_code`
        - `fetch_session_token` for unique url for cli to fetch session (along with `validation_code`)
    4. [ ] server emails validation link with `email_validation_token` (postmark)
    5. [ ] server returns fetch session link with `fetch_session_token`
2. User follows email validation link to get a validation code.
3. User enters validation code on the CLI, where it was prompting/waiting for it.
4. CLI posts to the fetch link with the validation code.
5. Server creates and returns a session token.
6. CLI saves token on disk to use for authenticated requests.

Benefits:

- Not saving or requiring passwords.
- CLI auth tightly coupled to email validation.
    - Can't get session token without fetch token/link from the cli initiation and the validation code.
    - Can't get the validation code without validation token/link from the email.
- CLI auth loosely coupled to where you check your email (clicking validation link in email gives you a code that can be manually entered on the cli)
