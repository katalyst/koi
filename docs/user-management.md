# Koi User Management

Use this guide to understand how the Koi engine models admin users, which authentication features ship out of the box, and how to provision, invite, and maintain users in a Koi-backed application. Treat it as the companion to the setup guide—reference it whenever you add new administrators or write code that depends on the current admin.

## Overview: How Koi Handles Admin Users

- **Model**: `Admin::User` (`app/models/admin/user.rb`) stores names, emails, optional passwords, and sign-in timestamps on the `admins` table. It mixes in `Koi::Model::Archivable` and `Koi::Model::OTP`, so records can be archived instead of deleted and can enrol in one-time-password MFA.
- **Session enforcement**: `Koi::Middleware::AdminAuthentication` intercepts all `/admin` requests and redirects unauthenticated visitors to `/admin/session/new`, preserving the original path in `flash[:redirect]` for post-login return.
- **Controller helpers**: Every admin controller includes `Koi::Controller`, which exposes `current_admin_user`, `current_admin`, and `admin_signed_in?` to controllers and views (`app/controllers/concerns/koi/controller.rb`). Use these helpers for scoping queries or rendering personalised UI.
- **Authentication features**: Koi supports email/password sign-in, optional TOTP-based MFA, WebAuthn passkeys, magic login links, and a development-only auto-login (`Koi.config.authenticate_local_admins`). Sign-in/out events update `sign_in_count` and timestamps via `Koi::Controller::RecordsAuthentication`.
- **No authorisation layer**: Koi does not ship with policies or role-based access. Projects must layer their own Pundit, CanCan, or bespoke authorisation checks on top of the authenticated admin.

## Authentication Options

### Password Sign-in (with optional MFA)

When an admin submits an email and password, `Admin::SessionsController#create` uses `Admin::User.authenticate_by` for constant-time verification. If `otp_secret` is present (`requires_otp?` returns true), Koi pauses to collect a 6-digit token before completing the login. OTP codes are issued by TOTP apps and verified through `Koi::Model::OTP`. Removing the secret disables MFA immediately.

### Passkeys (WebAuthn)

Admins can register WebAuthn credentials from their profile (`/admin/admin_users/:id`). `Admin::CredentialsController` issues a challenge, stores it in the session, and captures device metadata when the OS completes attestation. Subsequent logins call `webauthn_authenticate!`, which verifies the assertion, updates the credential `sign_count`, and signs the admin in passwordlessly. Registration requires `https://` in production; browsers only permit WebAuthn on HTTPS origins or `http://localhost`.

### Magic Login Links

`Admin::TokensController` uses `generates_token_for(:password_reset, expires_in: 30.minutes)` to mint short-lived login links. Tokens expire after the first successful sign-in (because the generator ties validity to `current_sign_in_at`). Use these links when inviting new admins or when someone forgets their password. Koi renders the link in the UI; projects are responsible for delivering it (email, chat, etc.).

### Development Auto-login

With `Koi.config.authenticate_local_admins` (true by default in development), visiting `/admin` looks up `#{ENV['USER']}@katalyst.com.au` or `admin@katalyst.com.au`, sets `session[:admin_user_id]`, and skips the login form. Disable this behaviour by setting `authenticate_local_admins = false` in `config/initializers/koi.rb` when you need to rehearse the full login flow.

## Working With Admin Users in Code

- In controllers, rely on `current_admin_user` for the signed-in admin. The deprecated alias `current_admin` still exists but should be avoided for new code.
- `admin_signed_in?` tells you whether the helper is present; use it to guard navigation elements or to short-circuit actions that require authentication.
- Because `Koi::Controller` is included globally, view components and cells rendered inside admin controllers have access to the same helpers.
- For service objects or background jobs, accept an `Admin::User` (or its `id`) explicitly—there is no global singleton. Persist IDs if you need to audit actions later.
- Specs can include `Koi::Controller::HasAdminUsers::Test::ViewHelper` to stub `current_admin_user` in view specs.
- Remember that Koi only authenticates admins. Front-end customer accounts (if your app has them) must be implemented separately.

## Provisioning Admin Accounts

### Seeded Default Admin

Running `rails db:seed` in a project generated from `koi-template` invokes `Koi::Engine.load_seed`, which creates a single development admin:

- **Email**: `#{ENV['USER']}@katalyst.com.au`
- **Name**: output of `id -F`
- **Password**: `password`

Combined with development auto-login, this means you can usually load `/admin` immediately after seeding.

**Verify**

```sh
bin/rails runner 'puts Admin::User.pluck(:email, :sign_in_count)'
```

Expect to see at least one record with the shell-derived email and `sign_in_count` of 0 or 1.

### CLI Helpers

Projects bootstrapped from `koi-template` ship with helper scripts in `bin/`:

- `bin/admin-adduser [-n "Full Name"] [-e email@example.com]` creates or reuses an admin, printing a login URL. When no `-e` is supplied, the script defaults to `<unix-user>@katalyst.com.au`.
- `bin/admin-reset <email>` regenerates a login link for an existing admin without modifying passwords.

Copy these scripts into existing apps or implement equivalent Rake tasks so onboarding is reproducible.

**Verify**

```sh
bin/admin-adduser -n "Test Admin" -e "test-admin@example.com"
# paste the emitted /admin/session/token/... URL into a browser and confirm it signs you in
```

### Admin UI Workflows

Navigate to `/admin/admin_users` to manage accounts:

- **Create**: Click *New admin user*, supply name and email, and submit. Koi creates the record without a password; use *Generate login link* to send them an activation URL.
- **Edit**: Admins can update each other’s names/emails. When editing yourself (`request.variant = :self`), the form also exposes a password field so you can set or change a password.
- **Archive / Restore / Delete**: First archive an admin to revoke access (sets `archived_at`). Archived admins are hidden from default queries; use the *Archived* tab to restore or permanently delete them (hard delete only works from the archived list).
- **Audit**: The show view surfaces `last_sign_in_at`, passkey status, MFA enrolment, and whether the account is archived.

**Verify**

```sh
bin/rails runner 'admin = Admin::User.order(:created_at).first; puts({ email: admin.email, archived: admin.archived?, passkeys: admin.credentials.count })'
```

Expect `archived` to be `false` for active users and `passkeys` to reflect any registered credentials.

## Managing Passkeys and MFA

From an admin’s profile (accessible via the header avatar or `/admin/admin_users/:id`):

- Choose *New passkey* to open the WebAuthn registration dialog. The browser prompts for a device, and Koi stores the resulting credential in `admin_credentials`. You can name each credential to track which device it belongs to and remove stale ones individually.
- Choose *Add* under MFA to start enrolment. Koi pre-generates an `otp_secret`, renders a QR code (via `RQRCode`), and asks for a verification token. Once saved, future password logins require the 6-digit code. Removing MFA deletes the secret immediately.

Passkeys are the recommended option when available; MFA is a good fallback for browsers or devices that cannot store passkeys.

## Inviting Colleagues and Handling Approvals

There is no separate approval workflow. To onboard someone:

1. Create the admin via the CLI or `/admin/admin_users/new`.
2. On the admin’s show page, click *Generate login link*. This hits `Admin::TokensController#create` and renders a copyable `/admin/session/token/<token>` URL.
3. Share the link over a secure channel. The recipient visits the link, reviews their details, and clicks *Sign in* to consume the token.
4. Encourage them to add a passkey (preferred) or set a password and MFA once signed in.

Tokens expire 30 minutes after generation or immediately after use. If a token expires before it is consumed, issue a new one from the same page or by running `bin/admin-reset`.

## Automatic Login and Redirects in Development

With auto-login enabled, Koi tries to sign you in using the seeded email. If the admin record no longer matches, you will be redirected to `/admin/session/new` repeatedly.

### Avoiding the Redirect Loop

- **Add a matching account first**:
  ```sh
  bin/admin-adduser -n "Your Name" -e "#{ENV['USER']}@katalyst.com.au"
  ```
- **Or disable auto-login temporarily** by setting `Koi.configure { |config| config.authenticate_local_admins = false }` in `config/initializers/koi.rb` and restarting Rails. Re-enable it once emails are aligned.

### Recovering if You’re Already Stuck

1. Run `bin/admin-adduser -n "Your Name" -e "#{ENV['USER']}@katalyst.com.au"` to recreate the expected account.
2. Refresh `/admin`; auto-login should succeed again.
3. Archive or rename the extra account only after adjusting auto-login behaviour.

## Additional Gotchas

- **HTTPS for passkeys**: Browsers require HTTPS (or `localhost`) for WebAuthn. Use a reverse proxy such as `ngrok` when demonstrating passkeys over the public internet.
- **Token longevity**: Login links expire after 30 minutes or once used. Automations that email links should warn recipients about the short window.
- **Archiving keeps passkeys**: Archiving does not purge passkeys or MFA secrets. Restoring an admin reactivates those credentials; delete them explicitly if you need them revoked.

## Verification Checklist

Run these checkpoints before handing control to someone else:

- `bin/rails runner 'puts Admin::User.count'` shows at least one active admin.
- Visiting `/admin` in development signs you in automatically **or** prompts for credentials when auto-login is disabled.
- `/admin/admin_users` lists your account, and the show page offers *Generate login link*.
- Clicking *New passkey* prompts the browser for a device (on HTTPS or localhost).
- MFA enrolment succeeds by scanning the QR code and entering the generated token.
- `bin/admin-adduser -e alternate@example.com` prints a usable magic-link URL.
