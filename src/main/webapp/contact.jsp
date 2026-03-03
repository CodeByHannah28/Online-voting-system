<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Contact Us | Go Voter</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{font-family:Segoe UI,Arial,sans-serif;background:#f3f4f6;color:#1f2937}

        /* NAVBAR (same as Home) */
        nav{
            background:white;
            padding:1rem 2rem;
            box-shadow:0 2px 8px rgba(0,0,0,.08);
            display:flex;
            justify-content:space-between;
            align-items:center;
            position:sticky;
            top:0;
            z-index:100;
        }
        .nav-brand{display:flex;align-items:center;gap:.75rem;text-decoration:none}
        .nav-brand img{height:40px}
        .nav-brand span{font-size:1.5rem;font-weight:800;color:#1e40af}
        nav ul{list-style:none;display:flex;gap:2rem;align-items:center}
        nav a{text-decoration:none;color:#4b5563;font-weight:500}
        nav a:hover{color:#2563eb}
        .nav-login{border:2px solid #2563eb;padding:.5rem 1.25rem;border-radius:6px;color:#2563eb;font-weight:600}
        .nav-register{background:#2563eb;color:white;padding:.5rem 1.25rem;border-radius:6px;font-weight:600}

        /* CONTACT HERO */
        .contact-hero{
            background:linear-gradient(135deg,#2563eb,#1e40af);
            padding:4rem 2rem;
            color:white;
        }

        .contact-container{
            max-width:1200px;
            margin:auto;
            display:grid;
            grid-template-columns:1.1fr .9fr;
            gap:3rem;
            align-items:flex-start;
        }

        /* LEFT SIDE */
        .contact-left h1{
            font-size:3rem;
            margin-bottom:1rem;
        }
        .contact-left p{
            font-size:1.1rem;
            opacity:.95;
            line-height:1.7;
            margin-bottom:2rem;
        }

        .contact-info{
            background:rgba(255,255,255,.1);
            padding:1.5rem;
            border-radius:12px;
        }

        .info-item{
            display:flex;
            gap:1rem;
            align-items:flex-start;
            margin-bottom:1.25rem;
        }

        .info-icon{
            width:36px;
            height:36px;
            background:white;
            color:#2563eb;
            border-radius:50%;
            display:flex;
            align-items:center;
            justify-content:center;
            font-weight:800;
        }

        .info-text span{
            display:block;
            font-size:.85rem;
            opacity:.85;
        }
        .info-text strong{
            font-size:1rem;
        }

        /* RIGHT FORM */
        .contact-form{
            background:white;
            padding:2.5rem;
            border-radius:16px;
            box-shadow:0 20px 40px rgba(0,0,0,.15);
            color:#1f2937;
        }

        .contact-form h2{
            margin-bottom:1.5rem;
            font-size:1.75rem;
        }

        label{
            font-size:.85rem;
            font-weight:600;
            display:block;
            margin-bottom:.25rem;
        }

        input,select,textarea{
            width:100%;
            padding:.75rem;
            border-radius:8px;
            border:1px solid #d1d5db;
            margin-bottom:1rem;
            font-size:.95rem;
        }

        textarea{resize:none}

        button{
            width:100%;
            padding:.9rem;
            background:#2563eb;
            color:white;
            border:none;
            border-radius:8px;
            font-size:1rem;
            font-weight:600;
            cursor:pointer;
        }

        button:hover{background:#1e40af}

        /* FOOTER (same as Home) */
        footer{
            background:#1f2937;
            color:#d1d5db;
            padding:3rem 2rem;
            margin-top:4rem;
        }
        .footer-bottom{
            border-top:1px solid #374151;
            margin-top:2rem;
            padding-top:1.5rem;
            text-align:center;
            color:#9ca3af;
        }

        /* RESPONSIVE */
        @media(max-width:900px){
            .contact-container{grid-template-columns:1fr}
            .contact-left h1{font-size:2.2rem}
        }
    </style>
</head>

<body>

<!-- NAVBAR -->
<nav>
    <a href="index.jsp" class="nav-brand">
        <img src="${pageContext.request.contextPath}/Logo.jpeg">
        <span>Go Voter</span>
    </a>
    <ul>
        <li><a href="index.jsp">Home</a></li>
        <li><a href="about.jsp">About</a></li>
        <li><a href="contact.jsp">Contact</a></li>
        <li class="nav-auth">
            <a href="auth.jsp" class="nav-login">Login</a>
            <a href="auth.jsp?mode=signup" class="nav-register">Register</a>
        </li>
    </ul>
</nav>

<!-- CONTACT SECTION -->
<section class="contact-hero">
    <div class="contact-container">

        <!-- LEFT -->
        <div class="contact-left">
            <h1>Get in Touch</h1>
            <p>
                Please call us now or submit the form and one of our representatives
                will contact you shortly.
            </p>

            <div class="contact-info">
                <div class="info-item">
                    <div class="info-icon">✓</div>
                    <div class="info-text">
                        <span>USA & Canada</span>
                        <strong>+1 (800) 585-9694</strong>
                    </div>
                </div>

                <div class="info-item">
                    <div class="info-icon">✓</div>
                    <div class="info-text">
                        <span>International</span>
                        <strong>+1 (514) 762-0555</strong>
                    </div>
                </div>

                <div class="info-item">
                    <div class="info-icon">✓</div>
                    <div class="info-text">
                        <span>Email</span>
                        <strong>support@govoter.com</strong>
                    </div>
                </div>
            </div>
        </div>

        <!-- RIGHT FORM -->
        <div class="contact-form">
            <h2>Let’s chat!</h2>

            <form>
                <label>Department</label>
                <select>
                    <option>Sales</option>
                    <option>Support</option>
                    <option>Partnerships</option>
                </select>

                <label>Your Organization</label>
                <input type="text" placeholder="Organization name">

                <label>Your Name</label>
                <input type="text" placeholder="Full name">

                <label>Email</label>
                <input type="email" placeholder="Email address">

                <label>Message</label>
                <textarea rows="4" placeholder="How can we help you?"></textarea>

                <button type="submit">Send Message</button>
            </form>
        </div>

    </div>
</section>

<!-- FOOTER -->
<footer>
    <div class="footer-bottom">
        &copy; 2026 Go Voter. All rights reserved.
    </div>
</footer>

</body>
</html>