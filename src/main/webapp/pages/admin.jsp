<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.model.*, java.util.*" %>
<%
    List<Movie> movies = (List<Movie>) request.getAttribute("movies");
    List<User> users = (List<User>) request.getAttribute("users");
    List<RentalRequest> queue = (List<RentalRequest>) request.getAttribute("queue");
    List<Rental> rentals = (List<Rental>) request.getAttribute("rentals");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");

    long totalMovies = 0;
    long totalUsers = 0;
    long activeRentals = 0;
    int queueSize = 0;
    double totalRevenue = 0.0;
    String topMovie = "N/A";
    long totalReviews = 0;

    Object attrTotalMovies = request.getAttribute("totalMovies");
    if (attrTotalMovies instanceof Number) totalMovies = ((Number) attrTotalMovies).longValue();

    Object attrTotalUsers = request.getAttribute("totalUsers");
    if (attrTotalUsers instanceof Number) totalUsers = ((Number) attrTotalUsers).longValue();

    Object attrActiveRentals = request.getAttribute("activeRentals");
    if (attrActiveRentals instanceof Number) activeRentals = ((Number) attrActiveRentals).longValue();

    Object attrQueueSize = request.getAttribute("queueSize");
    if (attrQueueSize instanceof Number) queueSize = ((Number) attrQueueSize).intValue();

    Object attrTotalRevenue = request.getAttribute("totalRevenue");
    if (attrTotalRevenue instanceof Number) totalRevenue = ((Number) attrTotalRevenue).doubleValue();

    Object attrTopMovie = request.getAttribute("topMovie");
    if (attrTopMovie != null) topMovie = attrTopMovie.toString();

    Object attrTotalReviews = request.getAttribute("totalReviews");
    if (attrTotalReviews instanceof Number) totalReviews = ((Number) attrTotalReviews).longValue();

    if (movies == null) movies = new ArrayList<>();
    if (users == null) users = new ArrayList<>();
    if (queue == null) queue = new ArrayList<>();
    if (rentals == null) rentals = new ArrayList<>();
    if (reviews == null) reviews = new ArrayList<>();

    HttpSession adminSession = request.getSession(false);
    if (adminSession == null || !"ADMIN".equals(adminSession.getAttribute("userType"))) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    String successMsg = (String) session.getAttribute("success");
    String errorMsg = (String) session.getAttribute("error");
    if (successMsg != null) session.removeAttribute("success");
    if (errorMsg != null) session.removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Command Center — CineVault Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;0,700;1,300;1,400&family=Syne:wght@400;500;600;700;800&family=JetBrains+Mono:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root {
            --obsidian: #080808;
            --void: #0d0d0d;
            --charcoal: #141414;
            --slate: #1a1a1a;
            --panel: #1e1e1e;
            --surface: #242424;
            --border: rgba(255,255,255,0.06);
            --border-bright: rgba(255,255,255,0.12);
            --gold: #c9a84c;
            --gold-bright: #e8c96a;
            --gold-dim: rgba(201,168,76,0.15);
            --gold-glow: rgba(201,168,76,0.08);
            --crimson: #c0392b;
            --emerald: #1a9e6e;
            --sapphire: #2563eb;
            --amber: #d97706;
            --text-primary: #f0ece3;
            --text-secondary: #9e9a91;
            --text-muted: #5a5650;
            --sidebar-w: 270px;
            --radius: 4px;
            --radius-lg: 8px;
        }

        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        html { scroll-behavior: smooth; }

        body {
            font-family: 'Syne', sans-serif;
            background: var(--obsidian);
            color: var(--text-primary);
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* ─── NOISE TEXTURE OVERLAY ─── */
        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.03'/%3E%3C/svg%3E");
            pointer-events: none;
            z-index: 9999;
            opacity: 0.4;
        }

        /* ─── SIDEBAR ─── */
        .sidebar {
            position: fixed;
            left: 0; top: 0; bottom: 0;
            width: var(--sidebar-w);
            background: var(--void);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            z-index: 100;
            overflow: hidden;
        }

        .sidebar::after {
            content: '';
            position: absolute;
            top: 0; right: 0;
            width: 1px; height: 100%;
            background: linear-gradient(to bottom, transparent, var(--gold), transparent);
            opacity: 0.3;
        }

        .sidebar-brand {
            padding: 32px 28px 28px;
            border-bottom: 1px solid var(--border);
        }

        .brand-icon {
            width: 36px; height: 36px;
            background: var(--gold);
            border-radius: 2px;
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 12px;
            position: relative;
        }

        .brand-icon::before {
            content: '';
            position: absolute;
            inset: -2px;
            border: 1px solid rgba(201,168,76,0.3);
            border-radius: 3px;
        }

        .brand-icon i {
            font-size: 16px;
            color: var(--obsidian);
        }

        .brand-name {
            font-family: 'Cormorant Garamond', serif;
            font-size: 20px;
            font-weight: 600;
            letter-spacing: 0.08em;
            color: var(--text-primary);
            line-height: 1;
        }

        .brand-sub {
            font-size: 9px;
            letter-spacing: 0.3em;
            text-transform: uppercase;
            color: var(--gold);
            margin-top: 4px;
            font-weight: 500;
        }

        .sidebar-nav {
            flex: 1;
            padding: 20px 16px;
            overflow-y: auto;
        }

        .nav-section-label {
            font-size: 8px;
            letter-spacing: 0.35em;
            text-transform: uppercase;
            color: var(--text-muted);
            padding: 16px 12px 8px;
            font-weight: 600;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 11px 14px;
            margin: 2px 0;
            border-radius: var(--radius);
            cursor: pointer;
            transition: all 0.2s ease;
            color: var(--text-secondary);
            font-size: 13px;
            font-weight: 500;
            letter-spacing: 0.02em;
            text-decoration: none;
            position: relative;
        }

        .nav-item:hover {
            background: rgba(255,255,255,0.04);
            color: var(--text-primary);
        }

        .nav-item.active {
            background: var(--gold-dim);
            color: var(--gold-bright);
            border-left: 2px solid var(--gold);
            padding-left: 12px;
        }

        .nav-item .nav-icon {
            width: 18px;
            text-align: center;
            font-size: 13px;
            opacity: 0.8;
        }

        .nav-badge {
            margin-left: auto;
            background: var(--gold);
            color: var(--obsidian);
            font-size: 9px;
            font-weight: 700;
            padding: 2px 6px;
            border-radius: 10px;
            font-family: 'JetBrains Mono', monospace;
        }

        .sidebar-footer {
            padding: 16px;
            border-top: 1px solid var(--border);
            display: flex; flex-direction: column; gap: 4px;
        }

        /* ─── MAIN CONTENT ─── */
        .main {
            margin-left: var(--sidebar-w);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* ─── TOP BAR ─── */
        .topbar {
            background: var(--void);
            border-bottom: 1px solid var(--border);
            padding: 0 36px;
            height: 64px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 50;
        }

        .topbar-left {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .page-breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;
            color: var(--text-muted);
            letter-spacing: 0.05em;
        }

        .page-breadcrumb .current {
            color: var(--text-primary);
            font-weight: 600;
            font-size: 13px;
        }

        .topbar-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .topbar-time {
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            color: var(--text-muted);
            letter-spacing: 0.1em;
        }

        .admin-avatar {
            width: 34px; height: 34px;
            background: linear-gradient(135deg, var(--gold-dim), rgba(201,168,76,0.3));
            border: 1px solid rgba(201,168,76,0.4);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 12px;
            color: var(--gold);
            font-weight: 700;
        }

        /* ─── CONTENT AREA ─── */
        .content {
            flex: 1;
            padding: 36px;
        }

        /* ─── SECTION HEADERS ─── */
        .section-header {
            margin-bottom: 32px;
        }

        .section-eyebrow {
            font-size: 9px;
            letter-spacing: 0.4em;
            text-transform: uppercase;
            color: var(--gold);
            margin-bottom: 8px;
            font-weight: 600;
        }

        .section-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 36px;
            font-weight: 300;
            color: var(--text-primary);
            line-height: 1;
            letter-spacing: -0.01em;
        }

        .section-title em {
            font-style: italic;
            color: var(--gold);
        }

        /* ─── STAT CARDS ─── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 32px;
        }

        .stats-grid-2 {
            grid-template-columns: repeat(2, 1fr);
            margin-top: 0;
        }

        .stat-card {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 24px;
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, var(--gold), transparent);
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .stat-card:hover {
            border-color: var(--border-bright);
            transform: translateY(-2px);
        }

        .stat-card:hover::before {
            opacity: 0.6;
        }

        .stat-label {
            font-size: 9px;
            letter-spacing: 0.35em;
            text-transform: uppercase;
            color: var(--text-muted);
            font-weight: 600;
            margin-bottom: 12px;
        }

        .stat-value {
            font-family: 'Cormorant Garamond', serif;
            font-size: 42px;
            font-weight: 600;
            color: var(--text-primary);
            line-height: 1;
            letter-spacing: -0.02em;
        }

        .stat-value.gold { color: var(--gold-bright); }
        .stat-value.small { font-size: 28px; }

        .stat-icon {
            position: absolute;
            right: 20px; top: 20px;
            font-size: 28px;
            opacity: 0.06;
        }

        .stat-trend {
            margin-top: 8px;
            font-size: 11px;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .trend-up { color: var(--emerald); }
        .trend-dot {
            width: 4px; height: 4px;
            border-radius: 50%;
            background: var(--gold);
            opacity: 0.6;
        }

        /* ─── PANELS / DATA CARDS ─── */
        .panel {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            overflow: hidden;
            margin-bottom: 24px;
        }

        .panel-header {
            padding: 20px 24px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }

        .panel-title {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-primary);
            letter-spacing: 0.03em;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .panel-title i {
            color: var(--gold);
            font-size: 14px;
        }

        .panel-count {
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            color: var(--text-muted);
            background: var(--surface);
            padding: 3px 10px;
            border-radius: 20px;
            border: 1px solid var(--border);
        }

        .panel-body {
            padding: 24px;
        }

        /* ─── SEARCH BAR ─── */
        .search-row {
            padding: 16px 24px;
            border-bottom: 1px solid var(--border);
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .search-input-wrap {
            flex: 1;
            position: relative;
        }

        .search-input-wrap i {
            position: absolute;
            left: 14px; top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            font-size: 12px;
        }

        .search-input {
            width: 100%;
            background: var(--slate);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 9px 14px 9px 38px;
            color: var(--text-primary);
            font-family: 'Syne', sans-serif;
            font-size: 13px;
            transition: border-color 0.2s;
            outline: none;
        }

        .search-input::placeholder { color: var(--text-muted); }

        .search-input:focus {
            border-color: rgba(201,168,76,0.4);
            background: var(--void);
        }

        /* ─── TABLES ─── */
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }

        .data-table thead th {
            padding: 12px 20px;
            font-size: 9px;
            letter-spacing: 0.3em;
            text-transform: uppercase;
            color: var(--text-muted);
            font-weight: 600;
            text-align: left;
            background: var(--void);
            border-bottom: 1px solid var(--border);
            white-space: nowrap;
        }

        .data-table tbody tr {
            border-bottom: 1px solid rgba(255,255,255,0.03);
            transition: background 0.15s;
        }

        .data-table tbody tr:hover {
            background: rgba(255,255,255,0.025);
        }

        .data-table tbody tr:last-child {
            border-bottom: none;
        }

        .data-table td {
            padding: 14px 20px;
            font-size: 13px;
            color: var(--text-secondary);
            vertical-align: middle;
        }

        .data-table td strong {
            color: var(--text-primary);
            font-weight: 500;
        }

        .cell-mono {
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            color: var(--text-muted);
        }

        /* ─── BADGES ─── */
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 3px 10px;
            border-radius: 2px;
            font-size: 10px;
            font-weight: 600;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .badge::before {
            content: '';
            width: 4px; height: 4px;
            border-radius: 50%;
            background: currentColor;
        }

        .badge-admin { background: rgba(192,57,43,0.15); color: #e74c3c; border: 1px solid rgba(192,57,43,0.25); }
        .badge-customer { background: rgba(26,158,110,0.12); color: #2ecc71; border: 1px solid rgba(26,158,110,0.25); }
        .badge-active { background: rgba(217,119,6,0.12); color: #f59e0b; border: 1px solid rgba(217,119,6,0.25); }
        .badge-returned { background: rgba(26,158,110,0.12); color: #2ecc71; border: 1px solid rgba(26,158,110,0.25); }
        .badge-inactive { background: rgba(90,86,80,0.2); color: var(--text-muted); border: 1px solid var(--border); }

        /* ─── BUTTONS ─── */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 9px 18px;
            border-radius: var(--radius);
            font-family: 'Syne', sans-serif;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.05em;
            cursor: pointer;
            transition: all 0.2s ease;
            border: none;
            text-decoration: none;
            white-space: nowrap;
        }

        .btn-primary {
            background: var(--gold);
            color: var(--obsidian);
        }

        .btn-primary:hover {
            background: var(--gold-bright);
            transform: translateY(-1px);
            box-shadow: 0 4px 20px rgba(201,168,76,0.3);
        }

        .btn-ghost {
            background: transparent;
            color: var(--text-secondary);
            border: 1px solid var(--border);
        }

        .btn-ghost:hover {
            background: rgba(255,255,255,0.04);
            color: var(--text-primary);
            border-color: var(--border-bright);
        }

        .btn-danger {
            background: rgba(192,57,43,0.15);
            color: #e74c3c;
            border: 1px solid rgba(192,57,43,0.25);
        }

        .btn-danger:hover {
            background: rgba(192,57,43,0.25);
        }

        .btn-success {
            background: rgba(26,158,110,0.15);
            color: #2ecc71;
            border: 1px solid rgba(26,158,110,0.25);
        }

        .btn-success:hover { background: rgba(26,158,110,0.25); }

        .btn-sm {
            padding: 5px 12px;
            font-size: 11px;
        }

        .btn-icon {
            width: 30px; height: 30px;
            padding: 0;
            justify-content: center;
            border-radius: var(--radius);
            font-size: 11px;
        }

        .btn-icon.edit {
            background: rgba(37,99,235,0.12);
            color: #60a5fa;
            border: 1px solid rgba(37,99,235,0.2);
        }

        .btn-icon.edit:hover { background: rgba(37,99,235,0.22); }

        .btn-icon.delete {
            background: rgba(192,57,43,0.12);
            color: #f87171;
            border: 1px solid rgba(192,57,43,0.2);
        }

        .btn-icon.delete:hover { background: rgba(192,57,43,0.22); }

        .btn-actions {
            display: flex; gap: 6px;
        }

        /* ─── MOVIE POSTER ─── */
        .movie-thumb {
            width: 36px; height: 50px;
            object-fit: cover;
            border-radius: 2px;
            border: 1px solid var(--border);
        }

        .movie-thumb-placeholder {
            width: 36px; height: 50px;
            background: var(--slate);
            border: 1px solid var(--border);
            border-radius: 2px;
            display: flex; align-items: center; justify-content: center;
            color: var(--text-muted);
            font-size: 12px;
        }

        /* ─── STAR RATING ─── */
        .stars {
            color: var(--gold);
            font-size: 12px;
            letter-spacing: 1px;
        }

        .stars .empty { color: var(--surface); }

        /* ─── QUEUE ITEMS ─── */
        .queue-list { padding: 20px; display: flex; flex-direction: column; gap: 12px; }

        .queue-card {
            background: var(--slate);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            transition: border-color 0.2s;
            border-left: 2px solid var(--gold);
        }

        .queue-card:hover { border-color: rgba(201,168,76,0.4); }

        .queue-pos {
            font-family: 'Cormorant Garamond', serif;
            font-size: 24px;
            font-weight: 600;
            color: var(--gold);
            opacity: 0.5;
            min-width: 32px;
        }

        .queue-info { flex: 1; }

        .queue-movie {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 3px;
        }

        .queue-meta {
            font-size: 11px;
            color: var(--text-muted);
            font-family: 'JetBrains Mono', monospace;
        }

        /* ─── ALERTS ─── */
        .alert {
            padding: 14px 20px;
            border-radius: var(--radius);
            font-size: 13px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-success {
            background: rgba(26,158,110,0.12);
            border: 1px solid rgba(26,158,110,0.25);
            color: #2ecc71;
        }

        .alert-danger {
            background: rgba(192,57,43,0.12);
            border: 1px solid rgba(192,57,43,0.25);
            color: #e74c3c;
        }

        /* ─── MODALS ─── */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.85);
            backdrop-filter: blur(8px);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .modal-overlay.open { display: flex; }

        .modal-box {
            background: var(--charcoal);
            border: 1px solid var(--border-bright);
            border-radius: var(--radius-lg);
            width: 100%;
            max-width: 480px;
            max-height: 90vh;
            overflow-y: auto;
            animation: modalIn 0.25s ease;
        }

        @keyframes modalIn {
            from { opacity: 0; transform: translateY(16px) scale(0.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        .modal-head {
            padding: 24px 28px 20px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .modal-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 22px;
            font-weight: 600;
            color: var(--text-primary);
        }

        .modal-close {
            width: 30px; height: 30px;
            background: var(--slate);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            color: var(--text-muted);
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 13px;
            transition: all 0.15s;
        }

        .modal-close:hover { background: var(--surface); color: var(--text-primary); }

        .modal-body { padding: 24px 28px; }

        .modal-foot {
            padding: 20px 28px;
            border-top: 1px solid var(--border);
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }

        /* ─── FORM ELEMENTS ─── */
        .form-group { margin-bottom: 16px; }

        .form-label {
            display: block;
            font-size: 10px;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--text-muted);
            font-weight: 600;
            margin-bottom: 7px;
        }

        .form-control, .form-select {
            width: 100%;
            background: var(--slate);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 10px 14px;
            color: var(--text-primary);
            font-family: 'Syne', sans-serif;
            font-size: 13px;
            outline: none;
            transition: border-color 0.2s;
            appearance: none;
        }

        .form-control::placeholder { color: var(--text-muted); }

        .form-control:focus, .form-select:focus {
            border-color: rgba(201,168,76,0.5);
            background: var(--void);
        }

        textarea.form-control { resize: vertical; min-height: 80px; }

        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }

        /* ─── EMPTY STATE ─── */
        .empty-state {
            padding: 60px 20px;
            text-align: center;
            color: var(--text-muted);
        }

        .empty-state i {
            font-size: 36px;
            margin-bottom: 16px;
            opacity: 0.3;
            display: block;
        }

        .empty-state p { font-size: 13px; }

        /* ─── DIVIDER ─── */
        .divider {
            height: 1px;
            background: var(--border);
            margin: 24px 0;
        }

        /* ─── TABS ─── */
        .tab-pane { display: none; }
        .tab-pane.active { display: block; }

        /* ─── RESPONSIVE TABLE WRAP ─── */
        .table-wrap { overflow-x: auto; }

        /* ─── SCROLLBAR ─── */
        ::-webkit-scrollbar { width: 4px; height: 4px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: var(--surface); border-radius: 2px; }
        ::-webkit-scrollbar-thumb:hover { background: var(--border-bright); }

        /* ─── REVENUE HIGHLIGHT ─── */
        .revenue-val {
            font-family: 'Cormorant Garamond', serif;
            font-size: 42px;
            font-weight: 600;
            background: linear-gradient(135deg, var(--gold-bright), var(--gold));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            line-height: 1;
        }

        /* ─── COPY ROWS IN TOP MOVIE ─── */
        .top-movie-card {
            background: var(--slate);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 20px 24px;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .top-movie-icon {
            width: 48px; height: 48px;
            background: var(--gold-dim);
            border-radius: var(--radius);
            display: flex; align-items: center; justify-content: center;
            color: var(--gold);
            font-size: 20px;
        }

        /* ─── EXPORT BUTTONS ─── */
        .export-grid {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        /* ─── PAGE LOAD ANIMATION ─── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(12px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .fade-up {
            animation: fadeUp 0.4s ease forwards;
        }

        .fade-up-1 { animation-delay: 0.05s; opacity: 0; }
        .fade-up-2 { animation-delay: 0.10s; opacity: 0; }
        .fade-up-3 { animation-delay: 0.15s; opacity: 0; }
        .fade-up-4 { animation-delay: 0.20s; opacity: 0; }
        .fade-up-5 { animation-delay: 0.25s; opacity: 0; }

        /* ─── PROGRESS BAR ─── */
        .progress-bar {
            height: 3px;
            background: var(--slate);
            border-radius: 2px;
            overflow: hidden;
            margin-top: 10px;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--gold), var(--gold-bright));
            border-radius: 2px;
        }

        /* ─── COPIES DISPLAY ─── */
        .copies-wrap { display: flex; align-items: center; gap: 8px; }
        .copies-avail { color: var(--gold); font-weight: 600; font-size: 13px; }
        .copies-total { color: var(--text-muted); font-size: 11px; }

    </style>
</head>
<body>

<!-- SIDEBAR -->
<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="brand-icon"><i class="fas fa-film"></i></div>
        <div class="brand-name">CineVault</div>
        <div class="brand-sub">Admin Command Center</div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Overview</div>
        <a class="nav-item active" href="#" onclick="showSection('dashboard', this)">
            <span class="nav-icon"><i class="fas fa-chart-line"></i></span>
            Dashboard
        </a>
        <a class="nav-item" href="#" onclick="showSection('reports', this)">
            <span class="nav-icon"><i class="fas fa-chart-bar"></i></span>
            Reports
        </a>

        <div class="nav-section-label">Manage</div>
        <a class="nav-item" href="#" onclick="showSection('movies', this)">
            <span class="nav-icon"><i class="fas fa-clapperboard"></i></span>
            Movies
            <span class="nav-badge"><%= totalMovies %></span>
        </a>
        <a class="nav-item" href="#" onclick="showSection('users', this)">
            <span class="nav-icon"><i class="fas fa-users"></i></span>
            Members
            <span class="nav-badge"><%= totalUsers %></span>
        </a>
        <a class="nav-item" href="#" onclick="showSection('rentals', this)">
            <span class="nav-icon"><i class="fas fa-ticket"></i></span>
            Rentals
            <% if (activeRentals > 0) { %><span class="nav-badge"><%= activeRentals %></span><% } %>
        </a>
        <a class="nav-item" href="#" onclick="showSection('queue', this)">
            <span class="nav-icon"><i class="fas fa-clock-rotate-left"></i></span>
            Queue
            <% if (queueSize > 0) { %><span class="nav-badge"><%= queueSize %></span><% } %>
        </a>
        <a class="nav-item" href="#" onclick="showSection('reviews', this)">
            <span class="nav-icon"><i class="fas fa-star-half-stroke"></i></span>
            Reviews
            <% if (totalReviews > 0) { %><span class="nav-badge"><%= totalReviews %></span><% } %>
        </a>
    </nav>

    <div class="sidebar-footer">
        <a class="nav-item" href="${pageContext.request.contextPath}/" style="text-decoration:none;">
            <span class="nav-icon"><i class="fas fa-arrow-left"></i></span>
            Back to Site
        </a>
        <a class="nav-item" href="${pageContext.request.contextPath}/logout" style="text-decoration:none; color: #f87171;">
            <span class="nav-icon"><i class="fas fa-right-from-bracket"></i></span>
            Sign Out
        </a>
    </div>
</aside>

<!-- MAIN -->
<div class="main">

    <!-- TOP BAR -->
    <header class="topbar">
        <div class="topbar-left">
            <div class="page-breadcrumb">
                <span>CineVault</span>
                <i class="fas fa-chevron-right" style="font-size:9px;opacity:0.4;"></i>
                <span class="current" id="topbarSection">Dashboard</span>
            </div>
        </div>
        <div class="topbar-right">
            <div class="topbar-time" id="topbarClock"></div>
            <div class="admin-avatar">A</div>
        </div>
    </header>

    <!-- CONTENT -->
    <div class="content">

        <% if (successMsg != null) { %>
        <div class="alert alert-success fade-up fade-up-1">
            <i class="fas fa-circle-check"></i> <%= successMsg %>
        </div>
        <% } %>
        <% if (errorMsg != null) { %>
        <div class="alert alert-danger fade-up fade-up-1">
            <i class="fas fa-circle-exclamation"></i> <%= errorMsg %>
        </div>
        <% } %>

        <!-- ═══════════════════════════════════════════════
             DASHBOARD SECTION
        ═══════════════════════════════════════════════ -->
        <div id="dashboardSection" class="tab-pane active">
            <div class="section-header fade-up fade-up-1">
                <div class="section-eyebrow">Overview</div>
                <h1 class="section-title">Platform <em>Intelligence</em></h1>
            </div>

            <div class="stats-grid fade-up fade-up-2">
                <div class="stat-card">
                    <div class="stat-label">Total Films</div>
                    <div class="stat-value"><%= totalMovies %></div>
                    <i class="fas fa-clapperboard stat-icon"></i>
                    <div class="stat-trend"><span class="trend-dot"></span>In catalogue</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Members</div>
                    <div class="stat-value"><%= totalUsers %></div>
                    <i class="fas fa-users stat-icon"></i>
                    <div class="stat-trend"><span class="trend-dot"></span>Registered accounts</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Active Rentals</div>
                    <div class="stat-value gold"><%= activeRentals %></div>
                    <i class="fas fa-ticket stat-icon"></i>
                    <div class="stat-trend trend-up"><i class="fas fa-arrow-up" style="font-size:9px;"></i> Currently out</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Total Revenue</div>
                    <div class="revenue-val">$<%= String.format("%.0f", totalRevenue) %></div>
                    <i class="fas fa-coins stat-icon"></i>
                    <div class="stat-trend" style="margin-top:12px;"><span class="trend-dot"></span>$<%= String.format("%.2f", totalRevenue) %></div>
                </div>
            </div>

            <div class="stats-grid stats-grid-2 fade-up fade-up-3" style="max-width:560px;">
                <div class="stat-card">
                    <div class="stat-label">Queue Pending</div>
                    <div class="stat-value small"><%= queueSize %></div>
                    <i class="fas fa-clock stat-icon"></i>
                    <div class="stat-trend"><span class="trend-dot"></span>Awaiting processing</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Total Reviews</div>
                    <div class="stat-value small"><%= totalReviews %></div>
                    <i class="fas fa-star stat-icon"></i>
                    <div class="stat-trend"><span class="trend-dot"></span>Community feedback</div>
                </div>
            </div>

            <% if (!topMovie.equals("N/A")) { %>
            <div class="fade-up fade-up-4">
                <div class="top-movie-card" style="max-width:560px; margin-top:4px;">
                    <div class="top-movie-icon"><i class="fas fa-trophy"></i></div>
                    <div>
                        <div style="font-size:9px;letter-spacing:0.3em;text-transform:uppercase;color:var(--gold);font-weight:600;margin-bottom:5px;">Most Rented Film</div>
                        <div style="font-family:'Cormorant Garamond',serif;font-size:22px;font-weight:600;color:var(--text-primary);"><%= topMovie %></div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>

        <!-- ═══════════════════════════════════════════════
             MOVIES SECTION
        ═══════════════════════════════════════════════ -->
        <div id="moviesSection" class="tab-pane">
            <div class="section-header fade-up fade-up-1">
                <div class="section-eyebrow">Catalogue</div>
                <h1 class="section-title">Film <em>Library</em></h1>
            </div>

            <div class="panel fade-up fade-up-2">
                <div class="panel-header">
                    <div class="panel-title">
                        <i class="fas fa-clapperboard"></i>
                        All Films
                        <span class="panel-count"><%= movies.size() %> titles</span>
                    </div>
                    <button class="btn btn-primary" onclick="openModal('addMovieModal')">
                        <i class="fas fa-plus"></i> Add Film
                    </button>
                </div>

                <div class="search-row">
                    <div class="search-input-wrap">
                        <i class="fas fa-magnifying-glass"></i>
                        <input type="text" class="search-input" id="movieSearch" placeholder="Search by title, director, genre…" onkeyup="filterTable('movie')">
                    </div>
                </div>

                <div class="table-wrap">
                    <table class="data-table" id="moviesTable">
                        <thead>
                            <tr>
                                <th>Poster</th>
                                <th>Title</th>
                                <th>Director</th>
                                <th>Genre</th>
                                <th>Year</th>
                                <th>Copies</th>
                                <th>Price</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Movie m : movies) {
                                String posterUrl = m.getPosterUrlOrDefault();
                            %>
                            <tr data-title="<%= m.getTitle().toLowerCase() %>">
                                <td>
                                    <% if (posterUrl != null && !posterUrl.isEmpty()) { %>
                                        <img src="<%= posterUrl %>" class="movie-thumb" alt="<%= m.getTitle() %>">
                                    <% } else { %>
                                        <div class="movie-thumb-placeholder"><i class="fas fa-film"></i></div>
                                    <% } %>
                                </td>
                                <td><strong><%= m.getTitle() %></strong></td>
                                <td><%= m.getDirector() %></td>
                                <td>
                                    <span class="badge badge-customer" style="font-size:9px;"><%= m.getGenre() %></span>
                                </td>
                                <td><span class="cell-mono"><%= m.getReleaseYear() %></span></td>
                                <td>
                                    <div class="copies-wrap">
                                        <span class="copies-avail"><%= m.getAvailableCopies() %></span>
                                        <span class="copies-total">/ <%= m.getTotalCopies() %></span>
                                    </div>
                                    <div class="progress-bar" style="width:60px;">
                                        <div class="progress-fill" style="width:<%= m.getTotalCopies() > 0 ? (m.getAvailableCopies() * 100 / m.getTotalCopies()) : 0 %>%;"></div>
                                    </div>
                                </td>
                                <td><span class="cell-mono">$<%= m.getRentalPrice() %></span></td>
                                <td>
                                    <div class="btn-actions">
                                        <button class="btn btn-icon edit" onclick="editMovie('<%= m.getMovieId() %>')" title="Edit"><i class="fas fa-pen"></i></button>
                                        <button class="btn btn-icon delete" onclick="deleteMovie('<%= m.getMovieId() %>')" title="Delete"><i class="fas fa-trash-can"></i></button>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ═══════════════════════════════════════════════
             USERS SECTION
        ═══════════════════════════════════════════════ -->
        <div id="usersSection" class="tab-pane">
            <div class="section-header fade-up fade-up-1">
                <div class="section-eyebrow">Members</div>
                <h1 class="section-title">User <em>Registry</em></h1>
            </div>

            <div class="panel fade-up fade-up-2">
                <div class="panel-header">
                    <div class="panel-title">
                        <i class="fas fa-users"></i>
                        All Members
                        <span class="panel-count"><%= users.size() %> accounts</span>
                    </div>
                    <button class="btn btn-primary" onclick="openModal('addUserModal')">
                        <i class="fas fa-user-plus"></i> Add Member
                    </button>
                </div>

                <div class="search-row">
                    <div class="search-input-wrap">
                        <i class="fas fa-magnifying-glass"></i>
                        <input type="text" class="search-input" id="userSearch" placeholder="Search by name, email, username…" onkeyup="filterTable('user')">
                    </div>
                </div>

                <div class="table-wrap">
                    <table class="data-table" id="usersTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Username</th>
                                <th>Full Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User u : users) { %>
                            <tr data-username="<%= u.getUsername().toLowerCase() %>">
                                <td><span class="cell-mono"><%= u.getUserId() %></span></td>
                                <td><strong><%= u.getUsername() %></strong></td>
                                <td><%= u.getFullName() %></td>
                                <td><span style="color:var(--text-secondary);font-size:12px;"><%= u.getEmail() %></span></td>
                                <td>
                                    <span class="badge <%= u.getUserType().equals("ADMIN") ? "badge-admin" : "badge-customer" %>">
                                        <%= u.getUserType() %>
                                    </span>
                                </td>
                                <td>
                                    <span class="badge <%= u.isActive() ? "badge-returned" : "badge-inactive" %>">
                                        <%= u.isActive() ? "Active" : "Inactive" %>
                                    </span>
                                </td>
                                <td>
                                    <div class="btn-actions">
                                        <button class="btn btn-icon edit" onclick="editUser('<%= u.getUserId() %>')" title="Edit"><i class="fas fa-pen"></i></button>
                                        <button class="btn btn-icon delete" onclick="deleteUser('<%= u.getUserId() %>')" title="Delete"><i class="fas fa-trash-can"></i></button>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ═══════════════════════════════════════════════
             RENTALS SECTION
        ═══════════════════════════════════════════════ -->
        <div id="rentalsSection" class="tab-pane">
            <div class="section-header fade-up fade-up-1">
                <div class="section-eyebrow">Transactions</div>
                <h1 class="section-title">Rental <em>History</em></h1>
            </div>

            <div class="panel fade-up fade-up-2">
                <div class="panel-header">
                    <div class="panel-title">
                        <i class="fas fa-ticket"></i>
                        All Rentals
                        <span class="panel-count"><%= rentals.size() %> records</span>
                    </div>
                    <span class="badge badge-active"><%= activeRentals %> active</span>
                </div>

                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Film</th>
                                <th>Member ID</th>
                                <th>Rented</th>
                                <th>Due</th>
                                <th>Price</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Rental r : rentals) { %>
                            <tr>
                                <td><strong><%= r.getMovieTitle() %></strong></td>
                                <td><span class="cell-mono"><%= r.getUserId() %></span></td>
                                <td><span class="cell-mono" style="font-size:11px;"><%= r.getFormattedRentDate() %></span></td>
                                <td><span class="cell-mono" style="font-size:11px;"><%= r.getFormattedDueDate() %></span></td>
                                <td><span class="cell-mono">$<%= r.getRentalPrice() %></span></td>
                                <td>
                                    <span class="badge <%= r.getStatus().equals("ACTIVE") ? "badge-active" : "badge-returned" %>">
                                        <%= r.getStatus() %>
                                    </span>
                                </td>
                                <td>
                                    <% if (r.getStatus().equals("ACTIVE")) { %>
                                    <button class="btn btn-success btn-sm" onclick="returnRental('<%= r.getRentalId() %>')">
                                        <i class="fas fa-rotate-left"></i> Return
                                    </button>
                                    <% } else { %>
                                    <span style="color:var(--text-muted);font-size:11px;">—</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ═══════════════════════════════════════════════
             QUEUE SECTION
        ═══════════════════════════════════════════════ -->
        <div id="queueSection" class="tab-pane">
            <div class="section-header fade-up fade-up-1">
                <div class="section-eyebrow">FIFO Queue</div>
                <h1 class="section-title">Rental <em>Queue</em></h1>
            </div>

            <div class="panel fade-up fade-up-2">
                <div class="panel-header">
                    <div class="panel-title">
                        <i class="fas fa-clock-rotate-left"></i>
                        Pending Requests
                        <span class="panel-count"><%= queueSize %> waiting</span>
                    </div>
                    <% if (!queue.isEmpty()) { %>
                    <form action="${pageContext.request.contextPath}/admin" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="processAllQueue">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-bolt"></i> Process All
                        </button>
                    </form>
                    <% } %>
                </div>

                <% if (queue.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-inbox"></i>
                    <p>The queue is clear — no pending requests.</p>
                </div>
                <% } else { %>
                <div class="queue-list">
                    <% for (int i = 0; i < queue.size(); i++) {
                        RentalRequest req = queue.get(i);
                    %>
                    <div class="queue-card">
                        <div class="queue-pos">#<%= i+1 %></div>
                        <div class="queue-info">
                            <div class="queue-movie"><%= req.getMovieTitle() %></div>
                            <div class="queue-meta">User <%= req.getUserId() %> &nbsp;·&nbsp; <%= req.getRentalDays() %> days &nbsp;·&nbsp; <i class="fas fa-clock"></i> <%= req.getFormattedTime() %></div>
                        </div>
                        <div class="btn-actions">
                            <form action="${pageContext.request.contextPath}/admin" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="processQueue">
                                <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                <button type="submit" class="btn btn-success btn-sm">
                                    <i class="fas fa-check"></i> Process
                                </button>
                            </form>
                            <form action="${pageContext.request.contextPath}/admin" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="rejectQueue">
                                <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                <button type="submit" class="btn btn-danger btn-sm">
                                    <i class="fas fa-xmark"></i> Reject
                                </button>
                            </form>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>

        <!-- ═══════════════════════════════════════════════
             REVIEWS SECTION
        ═══════════════════════════════════════════════ -->
        <div id="reviewsSection" class="tab-pane">
            <div class="section-header fade-up fade-up-1">
                <div class="section-eyebrow">Community</div>
                <h1 class="section-title">Member <em>Reviews</em></h1>
            </div>

            <div class="panel fade-up fade-up-2">
                <div class="panel-header">
                    <div class="panel-title">
                        <i class="fas fa-star-half-stroke"></i>
                        All Reviews
                        <span class="panel-count"><%= reviews.size() %> reviews</span>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="deleteOldReviews">
                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Permanently delete all reviews older than 5 years?')">
                            <i class="fas fa-clock"></i> Clear Old Reviews
                        </button>
                    </form>
                </div>

                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Film ID</th>
                                <th>Member</th>
                                <th>Rating</th>
                                <th>Comment</th>
                                <th>Date</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Review rev : reviews) { %>
                            <tr>
                                <td><span class="cell-mono"><%= rev.getMovieId() %></span></td>
                                <td><strong><%= rev.getUsername() %></strong></td>
                                <td>
                                    <div class="stars">
                                        <% for(int s=0; s<rev.getRating(); s++) { %>★<% } %>
                                        <% for(int s=rev.getRating(); s<5; s++) { %><span class="empty">★</span><% } %>
                                    </div>
                                </td>
                                <td style="max-width:280px;color:var(--text-secondary);font-size:12px;">
                                    <%= rev.getComment().length() > 60 ? rev.getComment().substring(0,60) + "…" : rev.getComment() %>
                                </td>
                                <td><span class="cell-mono" style="font-size:11px;"><%= rev.getFormattedDate() %></span></td>
                                <td>
                                    <button class="btn btn-icon delete" onclick="deleteReview('<%= rev.getReviewId() %>')" title="Delete review">
                                        <i class="fas fa-trash-can"></i>
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ═══════════════════════════════════════════════
             REPORTS SECTION
        ═══════════════════════════════════════════════ -->
        <div id="reportsSection" class="tab-pane">
            <div class="section-header fade-up fade-up-1">
                <div class="section-eyebrow">Analytics</div>
                <h1 class="section-title">System <em>Reports</em></h1>
            </div>

            <div class="stats-grid fade-up fade-up-2">
                <div class="stat-card">
                    <div class="stat-label">Total Films</div>
                    <div class="stat-value"><%= totalMovies %></div>
                    <i class="fas fa-clapperboard stat-icon"></i>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Registered Members</div>
                    <div class="stat-value"><%= totalUsers %></div>
                    <i class="fas fa-users stat-icon"></i>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Active Rentals</div>
                    <div class="stat-value gold"><%= activeRentals %></div>
                    <i class="fas fa-ticket stat-icon"></i>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Total Revenue</div>
                    <div class="revenue-val" style="font-size:34px;margin-top:2px;">$<%= String.format("%.2f", totalRevenue) %></div>
                    <i class="fas fa-coins stat-icon"></i>
                </div>
            </div>

            <!-- Active Rentals Summary -->
            <div class="panel fade-up fade-up-3" style="margin-top:8px;">
                <div class="panel-header">
                    <div class="panel-title">
                        <i class="fas fa-ticket"></i>
                        Active Rentals Breakdown
                    </div>
                    <span class="badge badge-active"><%= activeRentals %> active</span>
                </div>

                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr><th>Film</th><th>Member ID</th><th>Rented</th><th>Due Date</th><th>Price</th><th>Status</th></tr>
                        </thead>
                        <tbody>
                            <% for (Rental r : rentals) { if (!"ACTIVE".equals(r.getStatus())) continue; %>
                            <tr>
                                <td><strong><%= r.getMovieTitle() %></strong></td>
                                <td><span class="cell-mono"><%= r.getUserId() %></span></td>
                                <td><span class="cell-mono" style="font-size:11px;"><%= r.getFormattedRentDate() %></span></td>
                                <td><span class="cell-mono" style="font-size:11px;"><%= r.getFormattedDueDate() %></span></td>
                                <td><span class="cell-mono">$<%= r.getRentalPrice() %></span></td>
                                <td><span class="badge badge-active">Active</span></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Export -->
            <div class="panel fade-up fade-up-4" style="margin-top:8px;">
                <div class="panel-header">
                    <div class="panel-title">
                        <i class="fas fa-download"></i>
                        Export Data
                    </div>
                </div>
                <div class="panel-body">
                    <div class="export-grid">
                        <a href="${pageContext.request.contextPath}/admin?export=movies" class="btn btn-ghost">
                            <i class="fas fa-film"></i> Export Films CSV
                        </a>
                        <a href="${pageContext.request.contextPath}/admin?export=users" class="btn btn-ghost">
                            <i class="fas fa-users"></i> Export Members CSV
                        </a>
                    </div>
                </div>
            </div>
        </div>

    </div><!-- /content -->
</div><!-- /main -->


<!-- ═══════════════════════════════════════════════════════
     MODALS
════════════════════════════════════════════════════════ -->

<!-- ADD MOVIE MODAL -->
<div class="modal-overlay" id="addMovieModal">
    <div class="modal-box">
        <div class="modal-head">
            <div class="modal-title">Add New Film</div>
            <button class="modal-close" onclick="closeModal('addMovieModal')"><i class="fas fa-xmark"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/admin" method="post">
            <input type="hidden" name="action" value="addMovie">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Title</label>
                    <input type="text" name="title" class="form-control" placeholder="Film title" required>
                </div>
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Director</label>
                        <input type="text" name="director" class="form-control" placeholder="Director name" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Genre</label>
                        <select name="genre" class="form-select">
                            <option>Action</option><option>Sci-Fi</option><option>Drama</option>
                            <option>Comedy</option><option>Thriller</option><option>Crime</option>
                            <option>Horror</option><option>Romance</option>
                        </select>
                    </div>
                </div>
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Release Year</label>
                        <input type="number" name="year" class="form-control" placeholder="e.g. 2024" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Total Copies</label>
                        <input type="number" name="copies" class="form-control" placeholder="e.g. 5" required>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Rental Price ($)</label>
                    <input type="number" step="0.01" name="price" class="form-control" placeholder="e.g. 4.99" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Poster URL</label>
                    <input type="text" name="posterUrl" class="form-control" placeholder="https://image.tmdb.org/…">
                </div>
            </div>
            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addMovieModal')">Cancel</button>
                <button type="submit" class="btn btn-primary"><i class="fas fa-plus"></i> Add Film</button>
            </div>
        </form>
    </div>
</div>

<!-- ADD USER MODAL -->
<div class="modal-overlay" id="addUserModal">
    <div class="modal-box">
        <div class="modal-head">
            <div class="modal-title">Add New Member</div>
            <button class="modal-close" onclick="closeModal('addUserModal')"><i class="fas fa-xmark"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/admin" method="post">
            <input type="hidden" name="action" value="addUser">
            <div class="modal-body">
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Username</label>
                        <input type="text" name="username" class="form-control" placeholder="username" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Full Name</label>
                    <input type="text" name="fullName" class="form-control" placeholder="First & last name" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <input type="email" name="email" class="form-control" placeholder="name@email.com" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Role</label>
                    <select name="userType" class="form-select">
                        <option value="CUSTOMER">Customer</option>
                        <option value="ADMIN">Admin</option>
                    </select>
                </div>
            </div>
            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addUserModal')">Cancel</button>
                <button type="submit" class="btn btn-primary"><i class="fas fa-user-plus"></i> Create Member</button>
            </div>
        </form>
    </div>
</div>

<!-- EDIT MOVIE MODAL -->
<div class="modal-overlay" id="editMovieModal">
    <div class="modal-box">
        <div class="modal-head">
            <div class="modal-title">Edit Film</div>
            <button class="modal-close" onclick="closeModal('editMovieModal')"><i class="fas fa-xmark"></i></button>
        </div>
        <div class="modal-body">
            <div class="form-group">
                <label class="form-label">Title</label>
                <input type="text" id="editTitle" class="form-control" required>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Director</label>
                    <input type="text" id="editDirector" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Genre</label>
                    <select id="editGenre" class="form-select">
                        <option>Action</option><option>Sci-Fi</option><option>Drama</option>
                        <option>Comedy</option><option>Thriller</option><option>Crime</option>
                        <option>Horror</option><option>Romance</option>
                    </select>
                </div>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Year</label>
                    <input type="number" id="editYear" class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">Copies</label>
                    <input type="number" id="editCopies" class="form-control">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Price ($)</label>
                <input type="number" step="0.01" id="editPrice" class="form-control">
            </div>
            <div class="form-group">
                <label class="form-label">Poster URL</label>
                <input type="text" id="editPosterUrl" class="form-control">
            </div>
            <input type="hidden" id="editMovieId">
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-ghost" onclick="closeModal('editMovieModal')">Cancel</button>
            <button type="button" class="btn btn-primary" onclick="saveMovieEdit()"><i class="fas fa-floppy-disk"></i> Save Changes</button>
        </div>
    </div>
</div>

<!-- EDIT USER MODAL -->
<div class="modal-overlay" id="editUserModal">
    <div class="modal-box">
        <div class="modal-head">
            <div class="modal-title">Edit Member</div>
            <button class="modal-close" onclick="closeModal('editUserModal')"><i class="fas fa-xmark"></i></button>
        </div>
        <div class="modal-body">
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Username</label>
                    <input type="text" id="editUsername" class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">Full Name</label>
                    <input type="text" id="editFullName" class="form-control">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Email</label>
                <input type="email" id="editEmail" class="form-control">
            </div>
            <div class="form-group">
                <label class="form-label">Phone</label>
                <input type="text" id="editPhone" class="form-control">
            </div>
            <div class="form-group">
                <label class="form-label">Address</label>
                <textarea id="editAddress" class="form-control" rows="2"></textarea>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Role</label>
                    <select id="editUserType" class="form-select">
                        <option value="CUSTOMER">Customer</option>
                        <option value="ADMIN">Admin</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select id="editStatus" class="form-select">
                        <option value="true">Active</option>
                        <option value="false">Inactive</option>
                    </select>
                </div>
            </div>
            <input type="hidden" id="editUserId">
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-ghost" onclick="closeModal('editUserModal')">Cancel</button>
            <button type="button" class="btn btn-primary" onclick="saveUserEdit()"><i class="fas fa-floppy-disk"></i> Save Changes</button>
        </div>
    </div>
</div>


<script>
    // ─── CLOCK ───
    function updateClock() {
        const now = new Date();
        document.getElementById('topbarClock').textContent =
            now.toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit', second: '2-digit' });
    }
    setInterval(updateClock, 1000);
    updateClock();

    // ─── SECTION NAVIGATION ───
    const sectionNames = {
        dashboard: 'Dashboard',
        movies: 'Film Library',
        users: 'Member Registry',
        rentals: 'Rental History',
        queue: 'Rental Queue',
        reviews: 'Member Reviews',
        reports: 'System Reports'
    };

    function showSection(section, el) {
        document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
        document.getElementById(section + 'Section').classList.add('active');
        document.querySelectorAll('.nav-item').forEach(a => a.classList.remove('active'));
        if (el) el.classList.add('active');
        document.getElementById('topbarSection').textContent = sectionNames[section] || section;
        sessionStorage.setItem('adminActiveTab', section);
        sessionStorage.setItem('adminActiveEl', section);
        if (event) event.preventDefault();
    }

    function restoreActiveTab() {
        const saved = sessionStorage.getItem('adminActiveTab');
        if (saved) {
            const links = document.querySelectorAll('.nav-item');
            links.forEach(l => {
                const onclick = l.getAttribute('onclick') || '';
                if (onclick.includes("'" + saved + "'")) {
                    showSection(saved, l);
                }
            });
            sessionStorage.removeItem('adminActiveTab');
        }
    }

    // ─── FILTER TABLE ───
    function filterTable(type) {
        const search = document.getElementById(type + 'Search');
        if (!search) return;
        const term = search.value.toLowerCase();
        const rows = document.querySelectorAll('#' + type + 'sTable tbody tr');
        rows.forEach(row => {
            row.style.display = row.innerText.toLowerCase().includes(term) ? '' : 'none';
        });
    }

    // ─── MODALS ───
    function openModal(id) {
        document.getElementById(id).classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('open');
        document.body.style.overflow = '';
    }

    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) closeModal(overlay.id);
        });
    });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-overlay.open').forEach(m => closeModal(m.id));
        }
    });

    // ─── ACTIONS ───
    function deleteMovie(id) {
        if (confirm('Permanently delete this film from the catalogue?')) {
            submitForm({ action: 'deleteMovie', id });
        }
    }

    function deleteUser(id) {
        if (confirm('Permanently delete this member account?')) {
            submitForm({ action: 'deleteUser', id });
        }
    }

    function returnRental(id) {
        if (confirm('Mark this rental as returned?')) {
            submitForm({ action: 'returnRental', rentalId: id });
        }
    }

    function deleteReview(id) {
        if (confirm('Permanently delete this review?')) {
            submitForm({ action: 'deleteReview', reviewId: id });
        }
    }

    function submitForm(data) {
        const f = document.createElement('form');
        f.method = 'post';
        f.action = '${pageContext.request.contextPath}/admin';
        Object.entries(data).forEach(([k, v]) => {
            const inp = document.createElement('input');
            inp.type = 'hidden'; inp.name = k; inp.value = v;
            f.appendChild(inp);
        });
        document.body.appendChild(f);
        f.submit();
    }

    // ─── EDIT MOVIE ───
    function editMovie(id) {
        fetch('${pageContext.request.contextPath}/admin/api/movie?id=' + id)
            .then(r => r.json())
            .then(movie => {
                document.getElementById('editMovieId').value = movie.movieId;
                document.getElementById('editTitle').value = movie.title;
                document.getElementById('editDirector').value = movie.director;
                document.getElementById('editGenre').value = movie.genre;
                document.getElementById('editYear').value = movie.releaseYear;
                document.getElementById('editCopies').value = movie.totalCopies;
                document.getElementById('editPrice').value = movie.rentalPrice;
                document.getElementById('editPosterUrl').value = movie.posterUrl || '';
                openModal('editMovieModal');
            })
            .catch(() => alert('Could not load film data.'));
    }

    function saveMovieEdit() {
        const params = new URLSearchParams({
            action: 'updateMovieApi',
            movieId: document.getElementById('editMovieId').value,
            title: document.getElementById('editTitle').value,
            director: document.getElementById('editDirector').value,
            genre: document.getElementById('editGenre').value,
            year: document.getElementById('editYear').value,
            copies: document.getElementById('editCopies').value,
            price: document.getElementById('editPrice').value,
            posterUrl: document.getElementById('editPosterUrl').value,
        });

        closeModal('editMovieModal');
        fetch('${pageContext.request.contextPath}/admin', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(r => r.json())
        .then(result => {
            if (result.success) { sessionStorage.setItem('adminActiveTab', 'movies'); location.reload(); }
            else alert('Failed to update: ' + (result.error || 'Unknown error'));
        })
        .catch(() => alert('Error updating film.'));
    }

    // ─── EDIT USER ───
    function editUser(id) {
        fetch('${pageContext.request.contextPath}/admin/api/user?id=' + id)
            .then(r => r.json())
            .then(user => {
                document.getElementById('editUserId').value = user.userId;
                document.getElementById('editUsername').value = user.username;
                document.getElementById('editFullName').value = user.fullName;
                document.getElementById('editEmail').value = user.email;
                document.getElementById('editPhone').value = user.phone || '';
                document.getElementById('editAddress').value = user.address || '';
                document.getElementById('editUserType').value = user.userType;
                document.getElementById('editStatus').value = user.active;
                openModal('editUserModal');
            })
            .catch(() => alert('Could not load member data.'));
    }

    function saveUserEdit() {
        const params = new URLSearchParams({
            action: 'updateUserApi',
            userId: document.getElementById('editUserId').value,
            username: document.getElementById('editUsername').value,
            fullName: document.getElementById('editFullName').value,
            email: document.getElementById('editEmail').value,
            phone: document.getElementById('editPhone').value,
            address: document.getElementById('editAddress').value,
            userType: document.getElementById('editUserType').value,
            status: document.getElementById('editStatus').value,
        });

        closeModal('editUserModal');
        fetch('${pageContext.request.contextPath}/admin', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(r => r.json())
        .then(result => {
            if (result.success) { sessionStorage.setItem('adminActiveTab', 'users'); location.reload(); }
            else alert('Failed to update member.');
        })
        .catch(() => alert('Error updating member.'));
    }

    // ─── INIT ───
    document.addEventListener('DOMContentLoaded', restoreActiveTab);
</script>

</body>
</html>
