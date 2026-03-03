<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>About Us | Go Voter</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{font-family:Segoe UI,Arial,sans-serif;background:#f3f4f6;color:#1f2937}

        /* NAVBAR (EXACT SAME AS CONTACT) */
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

        /* ABOUT HERO */
        .about-hero{
            background:linear-gradient(135deg,#2563eb,#1e40af);
            padding:4rem 2rem;
            color:white;
            text-align:center;
        }

        .about-hero h1{
            font-size:3rem;
            margin-bottom:1rem;
        }

        .about-hero p{
            font-size:1.1rem;
            opacity:.95;
            max-width:700px;
            margin:auto;
            line-height:1.7;
        }

        /* ABOUT CONTENT */
        .about-container{
            max-width:1100px;
            margin:4rem auto;
            padding:0 2rem;
            display:grid;
            grid-template-columns:repeat(auto-fit,minmax(280px,1fr));
            gap:2.5rem;
        }

        .about-card{
            background:white;
            padding:2rem;
            border-radius:16px;
            box-shadow:0 20px 40px rgba(0,0,0,.08);
            transition:.3s;
        }

        .about-card:hover{
            transform:translateY(-5px);
        }

        .about-card h3{
            color:#2563eb;
            margin-bottom:1rem;
            font-size:1.3rem;
        }

        .about-card p{
            font-size:.95rem;
            line-height:1.7;
            color:#4b5563;
        }

        /* FOOTER (SAME STYLE AS CONTACT) */
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
            .about-hero h1{font-size:2.2rem}
        }

    </style>
</head>

<body>

<!-- NAVBAR (IDENTICAL TO CONTACT PAGE) -->
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

<!-- ABOUT HERO -->
<section class="about-hero">
    <h1>About Go Voter</h1>
    <p>
        Go Voter is a secure and modern digital voting platform designed to
        ensure transparency, fairness, and accessibility in elections for
        organizations, institutions, and communities.
    </p>
</section>

<!-- ABOUT CONTENT -->
<section class="about-container">

    <div class="about-card">
        <h3>Our Mission</h3>
        <p>
            To modernize the voting process through technology while ensuring
            security, integrity, and ease of use for every voter.
        </p>
    </div>

    <div class="about-card">
        <h3>Our Vision</h3>
        <p>
            To become a trusted digital voting solution that empowers
            institutions with reliable and transparent election systems.
        </p>
    </div>

    <div class="about-card">
        <h3>Security First</h3>
        <p>
            We implement strong authentication systems and encrypted processes
            to ensure every vote remains confidential and tamper-proof.
        </p>
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