<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Voter Dashboard | Go Voter</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <style>
        :root {
            --ink: #0f172a;
            --slate: #334155;
            --muted: #64748b;
            --accent: #1d4ed8;
            --accent-2: #0ea5e9;
            --canvas: #f8fafc;
            --card: #ffffff;
            --border: #e2e8f0;
        }

        body {
            background: radial-gradient(circle at top, #e0f2fe 0%, #f8fafc 45%, #ffffff 100%);
            color: var(--ink);
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        }

        .brand {
            font-weight: 800;
            letter-spacing: -0.02em;
        }

        .hero {
            background: linear-gradient(120deg, #1d4ed8, #0ea5e9);
            color: #fff;
            border-radius: 18px;
            padding: 32px;
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.2);
        }

        .pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.18);
            font-size: 0.85rem;
        }

        .card-grid {
            display: grid;
            gap: 24px;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        }

        .dash-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 10px 26px rgba(15, 23, 42, 0.08);
        }

        .dash-card h5 {
            margin-bottom: 10px;
            font-weight: 700;
        }

        .progress {
            height: 8px;
            border-radius: 999px;
        }

        .section-title {
            font-size: 1.2rem;
            font-weight: 700;
        }

        .activity-item {
            padding: 12px 0;
            border-bottom: 1px solid var(--border);
            color: var(--slate);
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .nav-link {
            color: #e2e8f0 !important;
        }

        .nav-link.active {
            color: #ffffff !important;
            font-weight: 600;
        }

        .quick-action {
            border: 1px dashed var(--border);
            border-radius: 14px;
            padding: 16px;
            text-align: center;
            color: var(--muted);
        }

        .badge-soft {
            background: #e0f2fe;
            color: #0369a1;
            border-radius: 999px;
            font-weight: 600;
        }
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark" style="background:#0f172a;">
    <div class="container">
        <a class="navbar-brand text-white brand" href="index.jsp">Go Voter</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#voterNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="voterNav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link active" href="voterDashboard.jsp">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="#elections">Elections</a></li>
                <li class="nav-item"><a class="nav-link" href="#results">Results</a></li>
                <li class="nav-item"><a class="nav-link" href="#profile">Profile</a></li>
                <li class="nav-item"><a class="nav-link" href="auth.jsp?mode=login">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<main class="container py-4">
    <section class="hero mb-4">
        <div class="d-flex flex-column flex-lg-row justify-content-between gap-4">
            <div>
                <span class="pill">Role: VOTER</span>
                <h1 class="mt-3">Welcome back, voter.</h1>
                <p class="mb-0">Track live elections, review candidates, and cast your vote securely.</p>
            </div>
            <div class="text-lg-end">
                <p class="mb-1">Next election opens in</p>
                <h2 class="fw-bold">3 days</h2>
                <span class="badge badge-soft">Verification complete</span>
            </div>
        </div>
    </section>

    <section class="card-grid mb-4" id="elections">
        <div class="dash-card">
            <h5>Active Elections</h5>
            <p class="text-muted mb-3">2 national elections currently open.</p>
            <div class="progress mb-2">
                <div class="progress-bar" style="width: 62%"></div>
            </div>
            <small class="text-muted">62% of voters have participated.</small>
        </div>
        <div class="dash-card">
            <h5>Upcoming Elections</h5>
            <p class="text-muted mb-3">Local council voting begins soon.</p>
            <button class="btn btn-outline-primary btn-sm">Set reminder</button>
        </div>
        <div class="dash-card">
            <h5>Your Voting Status</h5>
            <p class="text-muted mb-2">You have 1 pending ballot.</p>
            <button class="btn btn-primary btn-sm">Cast vote</button>
        </div>
    </section>

    <section class="row g-4 mb-4" id="results">
        <div class="col-lg-8">
            <div class="dash-card">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <span class="section-title">Recent Activity</span>
                    <button class="btn btn-outline-secondary btn-sm">View all</button>
                </div>
                <div class="activity-item">Verified your email address.</div>
                <div class="activity-item">Reviewed candidates for Presidential Election.</div>
                <div class="activity-item">Saved reminder for Local Council Election.</div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="dash-card">
                <span class="section-title">Quick Actions</span>
                <div class="mt-3 d-grid gap-3">
                    <div class="quick-action">Download voter receipt</div>
                    <div class="quick-action">Update profile</div>
                    <div class="quick-action">Support center</div>
                </div>
            </div>
        </div>
    </section>

    <section class="dash-card" id="profile">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <span class="section-title">Profile Snapshot</span>
            <button class="btn btn-outline-primary btn-sm">Edit profile</button>
        </div>
        <div class="row">
            <div class="col-md-4 mb-2"><strong>Name:</strong> Jane Voter</div>
            <div class="col-md-4 mb-2"><strong>Email:</strong> voter@example.com</div>
            <div class="col-md-4 mb-2"><strong>Location:</strong> Lagos, NG</div>
        </div>
    </section>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
