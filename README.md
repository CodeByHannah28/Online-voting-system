# Online Voting System — Auth Contribution

This repository includes an authentication system (register, login, logout, email verification) wired into the existing JSP pages.

What I changed and implemented
- Ensured `RegisterServlet`, `LoginServlet`, `LogoutServlet`, and `EmailVerificationServlet` are present and use BCrypt for password hashing.
- `AuthFilter` enforces authentication for protected pages and redirects unauthenticated users to `login.jsp`.
- `register.jsp` and `login.jsp` are used for register/login flows and use the same visual style as `index.jsp`.

Quick dev build & run
1. Prerequisites
   - Java 21 (project uses `maven.compiler.source` 21)
   - Maven (mvn) on PATH
   - Tomcat 10.x (or use the included Tomcat Maven plugin configured in `pom.xml`)
   - MySQL (or adjust `persistence.xml`) and a configured `persistence.xml` for the `VotingPU` persistence unit.

2. Build

```bash
cd C:\Users\tjayt\git\Online-voting-system
mvn package
```

3. Run using Tomcat Maven plugin (optional)

```bash
mvn com.github.bdemers:tomcat10-maven-plugin:run
```

Manual quick test (dev flow)
- Open `http://localhost:8080/online-voting-system/` and click Register.
- After creating an account you'll be redirected to `verify.jsp?code=...` which displays the verification status. (In dev mode the verification code is shown in the URL/page.)
- Click verify then login at `login.jsp`. After successful login you will be redirected to the originally requested page (if any) or `index.jsp`.

Notes
- Email sending is not configured; the verification flow stores a verification code in the DB and returns it in the redirect for manual verification.
- The project already depends on `org.mindrot:jbcrypt` in the `pom.xml`.

If you'd like, I can:
- Add an integration test that uses an in-memory DB (H2) to exercise the register/login/verify flows.
- Configure real email sending using Jakarta Mail.
- Protect additional URLs or categorize public routes more strictly.
