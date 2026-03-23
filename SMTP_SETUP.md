SMTP Setup for Go Voter

This document explains how to configure SMTP so the application can send verification and password-reset emails.

Overview
- The app loads SMTP settings from `src/main/resources/email.properties` and allows overrides via environment variables (recommended for passwords and deployment).
- Environment variables supported:
  - MAIL_SMTP_HOST (e.g. smtp.gmail.com)
  - MAIL_SMTP_PORT (e.g. 587)
  - MAIL_SMTP_AUTH (true/false)
  - MAIL_SMTP_STARTTLS (true/false)
  - MAIL_SMTP_USER (SMTP username/email)
  - MAIL_SMTP_PASSWORD (SMTP password or app password)
  - MAIL_FROM (From header such as "Go Voter <no-reply@example.com>")

Recommended: Use Gmail with an App Password
1. If you use a Gmail account as the SMTP user, enable 2-Step Verification in the Google account.
2. Create an App Password for "Mail" and your device. Google will display a 16-character password — copy it.
3. Do NOT commit that password into source control. Use the environment variable `MAIL_SMTP_PASSWORD`.

Windows quick setup (CMD)
- Open an Administrator cmd and run the helper script `scripts\\set_smtp_env.cmd` (below) or manually run these commands replacing values:

  setx MAIL_SMTP_HOST "smtp.gmail.com"
  setx MAIL_SMTP_PORT "587"
  setx MAIL_SMTP_AUTH "true"
  setx MAIL_SMTP_STARTTLS "true"
  setx MAIL_SMTP_USER "youremail@gmail.com"
  setx MAIL_SMTP_PASSWORD "<your-gmail-app-password>"
  setx MAIL_FROM "Go Voter <youremail@gmail.com>"

- After setting environment variables with setx, you must restart the Tomcat server process (and any shell) so the process picks up new env vars.

Alternative: local development (not secure)
- You can fill `src/main/resources/email.properties` for convenience during local development, but NEVER commit a plaintext password to git.
- A safe pattern is to create `src/main/resources/email.properties.template` in your repo and copy it to `email.properties` locally.

Troubleshooting
- If you see MessagingExceptions in server logs, check the full stack trace in the Tomcat console or log files.
- Common Gmail errors:
  - Authentication failed: either username/password incorrect, or app password not used when 2-step verification is enabled.
  - Connection timed out: network/firewall blocking port 587.

If you want, I can:
- Provide a small `scripts\\set_smtp_env.cmd` to set your environment variables quickly on Windows.
- Add a "Resend verification" servlet (rate-limited) so users can request the code again.
- Help you set the env vars and restart Tomcat from your environment.

