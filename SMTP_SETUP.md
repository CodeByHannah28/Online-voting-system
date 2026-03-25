Mailtrap Email API Setup for Go Voter

This document explains how to configure Mailtrap's HTTP API so the application can send verification and password-reset emails.

Overview
- The app loads Mailtrap API settings from `src/main/resources/email.properties`.
- Environment variables supported:
  - `MAILTRAP_API_URL`
  - `MAILTRAP_API_TOKEN`
  - `MAILTRAP_FROM_EMAIL`
  - `MAILTRAP_FROM_NAME`
  - `MAILTRAP_CATEGORY`

Recommended: Use Mailtrap Email API
1. Copy your Mailtrap API token from the Mailtrap dashboard.
2. Choose a sender email that Mailtrap allows for your workspace or verified sending domain.
3. Put the values into `email.properties` or set them as environment variables.

Required config
- `mailtrap.api.url=https://send.api.mailtrap.io/api/send`
- `mailtrap.api.token=<your Mailtrap API token>`
- `mailtrap.from.email=hello@onlinevoting.com`
- `mailtrap.from.name=Go Voter`

Windows quick setup (CMD)
- Open an Administrator cmd and run these commands with your Mailtrap values:

  `setx MAILTRAP_API_URL "https://send.api.mailtrap.io/api/send"`
  `setx MAILTRAP_API_TOKEN "<your-mailtrap-api-token>"`
  `setx MAILTRAP_FROM_EMAIL "hello@onlinevoting.com"`
  `setx MAILTRAP_FROM_NAME "Go Voter"`
  `setx MAILTRAP_CATEGORY "Verification"`

- After setting environment variables with `setx`, restart Tomcat and any open shell so the process picks them up.

Troubleshooting
- If delivery fails, inspect the Tomcat console or server logs for the exact `MessagingException`.
- Make sure the bearer token is correct and active.
- Make sure the sender email is accepted by your Mailtrap setup.
