<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Dashboard | Go Voter</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <style>
        :root {
            --ink: #111827;
            --muted: #6b7280;
            --accent: #f97316;
            --accent-2: #f59e0b;
            --canvas: #f8fafc;
            --card: #ffffff;
            --border: #e5e7eb;
        }

        body {
            background: linear-gradient(135deg, #fff7ed 0%, #f8fafc 55%, #ffffff 100%);
            color: var(--ink);
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        }

        .brand {
            font-weight: 800;
            letter-spacing: -0.02em;
        }

        .hero {
            background: linear-gradient(120deg, #f97316, #f59e0b);
            color: #fff;
            border-radius: 18px;
            padding: 32px;
            box-shadow: 0 18px 40px rgba(120, 53, 15, 0.2);
        }

        .stat-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 10px 26px rgba(15, 23, 42, 0.08);
        }

        .stat-value {
            font-size: 1.9rem;
            font-weight: 800;
        }

        .section-title {
            font-size: 1.2rem;
            font-weight: 700;
        }

        .task-item {
            padding: 12px 0;
            border-bottom: 1px solid var(--border);
        }

        .task-item:last-child {
            border-bottom: none;
        }

        .nav-link {
            color: #fef3c7 !important;
        }

        .nav-link.active {
            color: #ffffff !important;
            font-weight: 600;
        }

        .badge-soft {
            background: #fff7ed;
            color: #c2410c;
            border-radius: 999px;
            font-weight: 600;
        }
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark" style="background:#7c2d12;">
    <div class="container">
        <a class="navbar-brand text-white brand" href="index.jsp">Go Voter</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="adminNav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link active" href="adminDashboard.jsp">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="#election-mgmt">Elections</a></li>
                <li class="nav-item"><a class="nav-link" href="#user-mgmt">Users</a></li>
                <li class="nav-item"><a class="nav-link" href="#reports">Reports</a></li>
                <li class="nav-item"><a class="nav-link" href="auth.jsp?mode=login">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<main class="container py-4">
    <section class="hero mb-4">
        <div class="d-flex flex-column flex-lg-row justify-content-between gap-4">
            <div>
                <span class="badge badge-soft">Role: ADMIN</span>
                <h1 class="mt-3">Election operations at a glance.</h1>
                <p class="mb-0">Monitor participation, manage candidates, and publish results.</p>
            </div>
            <div class="text-lg-end">
                <p class="mb-1">System health</p>
                <h2 class="fw-bold">All systems normal</h2>
                <small>Last audit: 2 hours ago</small>
            </div>
        </div>
    </section>

    <section class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="text-muted">Total Voters</div>
                <div class="stat-value">124,860</div>
                <small class="text-muted">+3.4% this week</small>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="text-muted">Active Elections</div>
                <div class="stat-value">5</div>
                <small class="text-muted">2 closing today</small>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="text-muted">Pending Approvals</div>
                <div class="stat-value">18</div>
                <small class="text-muted">Candidates awaiting review</small>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="text-muted">Support Tickets</div>
                <div class="stat-value">9</div>
                <small class="text-muted">5 high priority</small>
            </div>
        </div>
    </section>

    <section class="row g-4 mb-4" id="election-mgmt">
        <div class="col-lg-7">
            <div class="stat-card">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <span class="section-title">Election Queue</span>
                    <button class="btn btn-outline-dark btn-sm">Create election</button>
                </div>
                <div class="task-item">Presidential Election: Results publishing scheduled.</div>
                <div class="task-item">Local Council Election: Candidate verification pending.</div>
                <div class="task-item">State Assembly Election: Voting opens tomorrow.</div>
            </div>
        </div>
        <div class="col-lg-5" id="user-mgmt">
            <div class="stat-card">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <span class="section-title">User Management</span>
                    <button class="btn btn-outline-dark btn-sm">Invite admin</button>
                </div>
                <p class="text-muted mb-2">Flagged accounts: 3</p>
                <p class="text-muted mb-0">Verification backlog: 12</p>
            </div>
        </div>
    </section>

    <section class="stat-card" id="reports">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <span class="section-title">Reports & Compliance</span>
            <button class="btn btn-outline-dark btn-sm">Download report</button>
        </div>
        <div class="row">
            <div class="col-md-4 mb-2"><strong>Audit Logs:</strong> Updated hourly</div>
            <div class="col-md-4 mb-2"><strong>Fraud Checks:</strong> 2 alerts today</div>
            <div class="col-md-4 mb-2"><strong>System Backups:</strong> Last run 1 hour ago</div>
        </div>
    </section>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
