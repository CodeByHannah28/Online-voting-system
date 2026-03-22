# Authentication System Implementation Plan

## Completed: 12/12

### Phase 1: Dependencies & Structure (1/1)
- [ ] 1. Update pom.xml: Add spring-security-crypto dependency

### Phase 2: Backend Creation (4/4)
- [ ] 2. Create src/main/java/com/bascode/auth/LoginServlet.java
- [ ] 3. Create src/main/java/com/bascode/auth/RegisterServlet.java  
- [ ] 4. Create src/main/java/com/bascode/auth/LogoutServlet.java
- [ ] 5. Create src/main/java/com/bascode/auth/EmailVerificationServlet.java
- [ ] 6. Create src/main/java/com/bascode/auth/AuthFilter.java

### Phase 3: Configuration (2/2)
- [ ] 7. Update src/main/webapp/WEB-INF/web.xml: Add AuthFilter mappings
- [ ] 8. Update pom.xml if needed post-compile

### Phase 4: Frontend Integration (3/3)
- [ ] 9. Update src/main/webapp/index.jsp: Add session checks for logged-in nav
- [ ] 10. Update src/main/webapp/auth.jsp: Add message display for success/error
- [ ] 11. Update other pages if needed (about.jsp, contact.jsp nav)

### Phase 5: Testing & Verification (2/2)
- [ ] 12. Test full flow: mvn compile, deploy, register/verify/login/logout/filter
- [ ] Mark complete, attempt_completion

**Next step: 1. pom.xml update**

