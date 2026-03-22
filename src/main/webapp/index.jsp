<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Go Voter - Secure Online Voting Platform</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html, body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            color: #1a1a1a;
            line-height: 1.6;
        }

        /* Navbar */
        nav {
            background: white;
            padding: 1rem 2rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            position: sticky;
            top: 0;
            z-index: 100;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .nav-brand {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
        }

        .nav-brand img {
            height: 40px;
            width: auto;
        }

        .nav-brand-text {
            font-size: 1.5rem;
            font-weight: 800;
            color: #1e40af;
            letter-spacing: -0.01em;
        }

        nav ul {
            list-style: none;
            display: flex;
            gap: 2rem;
            align-items: center;
        }

        nav a {
            color: #4b5563;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.95rem;
            transition: color 0.3s ease;
        }

        nav a:hover {
            color: #2563eb;
        }

        .nav-auth {
            display: flex;
            gap: 1rem;
            margin-left: 1rem;
        }

        .nav-login {
            color: #2563eb;
            border: 2px solid #2563eb;
            padding: 0.5rem 1.25rem;
            border-radius: 0.375rem;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .nav-login:hover {
            background: #2563eb;
            color: white;
        }

        .nav-register {
            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
            color: white;
            padding: 0.5rem 1.25rem;
            border-radius: 0.375rem;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }

        .nav-register:hover {
            box-shadow: 0 8px 20px rgba(37, 99, 235, 0.3);
            transform: translateY(-1px);
        }

        /* Hero Section */
        .hero {
            background: linear-gradient(rgba(15, 23, 42, 0.5), rgba(15, 23, 42, 0.5)), url('/public/voting-hero.jpg') center/cover no-repeat;
            padding: 5rem 2rem;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 650px;
            position: relative;
        }

        .hero-content {
            max-width: 800px;
            z-index: 10;
            position: relative;
        }

        .hero h1 {
            font-size: 3.5rem;
            font-weight: 900;
            margin-bottom: 1.5rem;
            color: #ffffff;
            line-height: 1.1;
            text-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
        }

        .hero p {
            font-size: 1.25rem;
            color: #f0f4f8;
            margin-bottom: 2.5rem;
            line-height: 1.8;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }

        .cta-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            padding: 0.75rem 2rem;
            border-radius: 0.5rem;
            font-size: 1rem;
            font-weight: 600;
            text-decoration: none;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-block;
        }

        .btn-primary {
            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(37, 99, 235, 0.3);
        }

        .btn-secondary {
            background: white;
            color: #2563eb;
            border: 2px solid #2563eb;
        }

        .btn-secondary:hover {
            background: #f0f4ff;
        }

        /* Features Section */
        .features {
            padding: 5rem 2rem;
            background: white;
        }

        .section-title {
            text-align: center;
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
            color: #0f172a;
        }

        .section-subtitle {
            text-align: center;
            font-size: 1.1rem;
            color: #4b5563;
            margin-bottom: 3rem;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .feature-card {
            padding: 2rem;
            background: #f9fafb;
            border-radius: 0.75rem;
            border: 1px solid #e5e7eb;
            transition: all 0.3s ease;
        }

        .feature-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.1);
            background: white;
        }

        .feature-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }

        .feature-card h3 {
            font-size: 1.25rem;
            margin-bottom: 0.75rem;
            color: #0f172a;
        }

        .feature-card p {
            color: #6b7280;
            line-height: 1.6;
        }

        /* How It Works Section */
        .how-it-works {
            padding: 5rem 2rem;
            background: #f9fafb;
        }

        .steps-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .step {
            text-align: center;
            padding: 2rem;
        }

        .step-number {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
            color: white;
            border-radius: 50%;
            font-size: 1.5rem;
            font-weight: 800;
            margin: 0 auto 1rem;
        }

        .step h3 {
            font-size: 1.1rem;
            margin-bottom: 0.75rem;
            color: #0f172a;
        }

        .step p {
            color: #6b7280;
            font-size: 0.95rem;
        }

        /* Stats Section */
        .stats {
            padding: 5rem 2rem;
            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
            color: white;
            text-align: center;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 2rem;
            max-width: 1000px;
            margin: 0 auto;
        }

        .stat-item h4 {
            font-size: 2.5rem;
            font-weight: 900;
            margin-bottom: 0.5rem;
        }

        .stat-item p {
            font-size: 1rem;
            opacity: 0.9;
        }

        /* Benefits Section */
        .benefits {
            padding: 5rem 2rem;
            background: white;
        }

        .benefits-content {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 3rem;
            align-items: center;
        }

        .benefits-list {
            list-style: none;
        }

        .benefits-list li {
            margin-bottom: 1.5rem;
            display: flex;
            gap: 1rem;
            align-items: flex-start;
        }

        .benefits-list li:before {
            content: "✓";
            font-size: 1.5rem;
            color: #22c55e;
            font-weight: 800;
            flex-shrink: 0;
            margin-top: -0.25rem;
        }

        .benefits-list li span {
            font-size: 1rem;
            color: #4b5563;
        }

        .benefits-image {
            text-align: center;
        }

        .benefits-image img {
            max-width: 100%;
            height: auto;
        }

        /* Testimonials Section */
        .testimonials {
            padding: 5rem 2rem;
            background: #f9fafb;
        }

        .testimonials-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .testimonial-card {
            background: white;
            padding: 2rem;
            border-radius: 0.75rem;
            border: 1px solid #e5e7eb;
        }

        .testimonial-stars {
            color: #fbbf24;
            margin-bottom: 1rem;
            font-size: 1.1rem;
        }

        .testimonial-text {
            color: #4b5563;
            margin-bottom: 1.5rem;
            font-style: italic;
        }

        .testimonial-author {
            font-weight: 600;
            color: #0f172a;
            margin-bottom: 0.25rem;
        }

        .testimonial-role {
            color: #9ca3af;
            font-size: 0.9rem;
        }

        /* CTA Section */
        .final-cta {
            padding: 4rem 2rem;
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
            text-align: center;
        }

        .final-cta h2 {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
        }

        .final-cta p {
            font-size: 1.1rem;
            margin-bottom: 2rem;
            opacity: 0.95;
        }

        /* Footer */
        footer {
            background: #1f2937;
            color: #d1d5db;
            padding: 3rem 2rem;
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .footer-section h4 {
            color: white;
            margin-bottom: 1rem;
            font-weight: 600;
        }

        .footer-section ul {
            list-style: none;
        }

        .footer-section li {
            margin-bottom: 0.5rem;
        }

        .footer-section a {
            color: #d1d5db;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .footer-section a:hover {
            color: white;
        }

        .footer-bottom {
            border-top: 1px solid #374151;
            padding-top: 2rem;
            text-align: center;
            color: #9ca3af;
        }

        /* Responsive */
        @media (max-width: 768px) {
            nav {
                flex-direction: column;
                gap: 1rem;
                padding: 1rem;
            }

            nav ul {
                flex-direction: column;
                gap: 0.5rem;
                width: 100%;
            }

            nav a {
                display: block;
                text-align: center;
            }

            nav .nav-auth {
                width: 100%;
                justify-content: center;
            }

            .hero {
                min-height: 500px;
                padding: 2rem 1rem;
            }

            .hero h1 {
                font-size: 2rem;
            }

            .hero p {
                font-size: 1rem;
            }

            .cta-buttons {
                flex-direction: column;
                align-items: center;
            }

            .btn {
                width: 100%;
            }

            .benefits-content {
                grid-template-columns: 1fr;
            }

            .section-title {
                font-size: 1.75rem;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .final-cta h2 {
                font-size: 1.75rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav>
        <a href="#" class="nav-brand">
            <img src="${pageContext.request.contextPath}/Logo.jpeg" alt="Go Voter Logo" style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.1));">
            <span class="nav-brand-text">Go Voter</span>
        </a>
        <ul>
    <li><a href="index.jsp">Home</a></li>
    <li><a href="about.jsp">About</a></li>
    <li><a href="contact.jsp">Contact</a></li>
<li class="nav-auth">
<%
if (session.getAttribute("userId") == null) {
%>
       <a href="login.jsp" class="nav-login">Login</a>
<a href="register.jsp" class="nav-register">Register</a>
<%
} else {
%>
       <span>Welcome, <%=session.getAttribute("userName")%>!</span>
       <a href="logout" class="nav-login">Logout</a>
<%
}
%>
    </li>
</ul>
    </nav>

    <!-- Hero Section -->
    <section class="hero"
    style="
        min-height: 100vh;
        background-image:
            linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.45)),
            url('${pageContext.request.contextPath}/Home-background.jpeg');
        background-size: cover;
        background-position: center;
        background-repeat: no-repeat;
        display: flex;
        align-items: center;
        justify-content: center;
        text-align: center;
        color: #ffffff;
    "
>
    <div class="hero-content" style="max-width: 700px; padding: 20px;">
        <h1>Your Vote, Your Voice, Your Future</h1>
        <p>
            Secure, transparent, and accessible voting for everyone.
            Join millions casting their votes with confidence on Go Voter.
        </p>
        <div class="cta-buttons">
            <a href="#" class="btn btn-primary">Start Voting Today</a>
            <a href="#" class="btn btn-secondary">Learn More</a>
        </div>
    </div>
</section>

    <!-- Features Section -->
    <section class="features">
        <h2 class="section-title">Why Choose Go Voter?</h2>
        <p class="section-subtitle">Experience the future of voting with cutting-edge security and unprecedented accessibility.</p>
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">🔒</div>
                <h3>Bank-Level Security</h3>
                <p>Your vote is protected with military-grade encryption and multi-factor authentication to ensure complete security.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">✓</div>
                <h3>Transparent Results</h3>
                <p>Real-time election tracking with blockchain-verified tallies for complete transparency and trust.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🌍</div>
                <h3>Vote Anywhere</h3>
                <p>Vote from home, work, or on the go. Access our platform 24/7 from any device, anywhere in the world.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">⚡</div>
                <h3>Instant Verification</h3>
                <p>Receive immediate confirmation of your vote with a unique verification code for complete peace of mind.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">♿</div>
                <h3>Fully Accessible</h3>
                <p>Our platform meets WCAG accessibility standards, ensuring every citizen can participate in democracy.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">📱</div>
                <h3>Mobile Optimized</h3>
                <p>Seamless experience on smartphones, tablets, and desktops with intuitive navigation and fast loading.</p>
            </div>
        </div>
    </section>

    <!-- How It Works Section -->
    <section class="how-it-works">
        <h2 class="section-title">How It Works</h2>
        <p class="section-subtitle">Simple, secure, and straightforward. Vote in just 3 easy steps.</p>
        <div class="steps-grid">
            <div class="step">
                <div class="step-number">1</div>
                <h3>Register & Verify</h3>
                <p>Create your account and complete identity verification to confirm your eligibility to vote.</p>
            </div>
            <div class="step">
                <div class="step-number">2</div>
                <h3>Review Candidates</h3>
                <p>Explore detailed candidate information, positions, and voting records to make informed decisions.</p>
            </div>
            <div class="step">
                <div class="step-number">3</div>
                <h3>Cast & Confirm</h3>
                <p>Cast your vote securely and receive instant confirmation with a unique verification code.</p>
            </div>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="stats">
        <h2 class="section-title" style="color: white; margin-bottom: 2rem;">Go Voter by the Numbers</h2>
        <div class="stats-grid">
            <div class="stat-item">
                <h4>2.5M+</h4>
                <p>Active Voters</p>
            </div>
            <div class="stat-item">
                <h4>50+</h4>
                <p>Countries</p>
            </div>
            <div class="stat-item">
                <h4>99.9%</h4>
                <p>Uptime</p>
            </div>
            <div class="stat-item">
                <h4>100%</h4>
                <p>Encrypted</p>
            </div>
        </div>
    </section>

    <!-- Benefits Section -->
    <section class="benefits">
        <h2 class="section-title">Designed for Democracy</h2>
        <div class="benefits-content">
            <div>
                <ul class="benefits-list">
                    <li><span><strong>Secure Authentication:</strong> Multi-factor verification prevents unauthorized access</span></li>
                    <li><span><strong>Vote Anonymously:</strong> Your identity is protected while your vote is verified</span></li>
                    <li><span><strong>Live Results:</strong> Watch results update in real-time as votes are counted</span></li>
                    <li><span><strong>Audit Trail:</strong> Complete voting history for administrators and observers</span></li>
                    <li><span><strong>24/7 Support:</strong> Dedicated customer support throughout the voting period</span></li>
                    <li><span><strong>Compliance Ready:</strong> Meets all federal and international election standards</span></li>
                </ul>
            </div>
            <div class="benefits-image">
                <img src="Box.jpeg" alt="Go Voter Benefits" style="opacity: 0.9; max-width: 300px;">
            </div>
        </div>
    </section>

    <!-- Testimonials Section -->
    <section class="testimonials">
        <h2 class="section-title">What Voters Say</h2>
        <p class="section-subtitle">Trusted by millions of voters worldwide</p>
        <div class="testimonials-grid">
            <div class="testimonial-card">
                <div class="testimonial-stars">★★★★★</div>
                <p class="testimonial-text">"Go Voter made it so easy to participate in the election. I voted from home and got instant confirmation. Highly recommended!"</p>
                <div class="testimonial-author">Maria Rodriguez</div>
                <div class="testimonial-role">Registered Voter</div>
            </div>
            <div class="testimonial-card">
                <div class="testimonial-stars">★★★★★</div>
                <p class="testimonial-text">"The transparency and security features are outstanding. I trust Go Voter with my vote. This is the future of voting."</p>
                <div class="testimonial-author">James Mitchell</div>
                <div class="testimonial-role">Election Observer</div>
            </div>
            <div class="testimonial-card">
                <div class="testimonial-stars">★★★★★</div>
                <p class="testimonial-text">"Finally, a voting platform that's accessible for everyone. The interface is intuitive and the support team is fantastic!"</p>
                <div class="testimonial-author">Sarah Chen</div>
                <div class="testimonial-role">Accessibility Advocate</div>
            </div>
        </div>
    </section>

    <!-- Final CTA Section -->
    <section class="final-cta">
        <h2>Ready to Make Your Voice Heard?</h2>
        <p>Join millions of voters using Go Voter for a secure and transparent voting experience.</p>
        <div class="cta-buttons">
            <a href="#" class="btn btn-primary" style="background: white; color: rgb(217, 119, 6);">Register Now</a>
            <a href="#" class="btn btn-secondary" style="border-color: white; color:rgb(217, 119, 6);">Schedule a Demo</a>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <div class="footer-content">
            <div class="footer-section">
                <h4>Product</h4>
                <ul>
                    <li><a href="#">Features</a></li>
                    <li><a href="#">Security</a></li>
                    <li><a href="#">Pricing</a></li>
                    <li><a href="#">FAQ</a></li>
                </ul>
            </div>
            <div class="footer-section">
                <h4>Company</h4>
                <ul>
                    <li><a href="#">About Us</a></li>
                    <li><a href="#">Contact</a></li>
                    <li><a href="#">Blog</a></li>
                    <li><a href="#">Careers</a></li>
                </ul>
            </div>
            <div class="footer-section">
                <h4>Legal</h4>
                <ul>
                    <li><a href="#">Privacy Policy</a></li>
                    <li><a href="#">Terms of Service</a></li>
                    <li><a href="#">Cookie Policy</a></li>
                    <li><a href="#">Compliance</a></li>
                </ul>
            </div>
            <div class="footer-section">
                <h4>Social</h4>
                <ul>
                    <li><a href="#">Twitter</a></li>
                    <li><a href="#">LinkedIn</a></li>
                    <li><a href="#">Facebook</a></li>
                    <li><a href="#">Instagram</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2026 Go Voter. All rights reserved. Empowering democracy through technology.</p>
        </div>
    </footer>
</body>
</html>