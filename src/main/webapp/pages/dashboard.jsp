<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.dao.MovieDAO, com.movierental.model.Movie, java.util.List" %>
<%@ page import="com.movierental.dao.RentalDAO, com.movierental.model.Rental" %>
<%@ page import="com.movierental.model.RentalRequest, java.util.ArrayList" %>
<%@ page import="com.movierental.dao.ReviewDAO, com.movierental.model.Review" %>
<%@ page import="com.movierental.utils.QueueManager" %>
<%@ page import="com.movierental.utils.RecentlyWatchedStack" %>
<%
    String basePath = application.getInitParameter("data.path")
            .replace("${user.home}", System.getProperty("user.home"));
    String dataPath = basePath + "movies.txt";
    String rentalPath = basePath + "rentals.txt";
    String reviewPath = basePath + "reviews.txt";

    MovieDAO movieDAO = new MovieDAO(dataPath);
    RentalDAO rentalDAO = new RentalDAO(rentalPath, dataPath);
    ReviewDAO reviewDAO = new ReviewDAO(reviewPath, movieDAO);

    List<Movie> allMovies = movieDAO.getAllMovies();
    List<Movie> featuredMovies = QueueManager.insertionSortByRating(allMovies);
    if (featuredMovies.size() > 8) featuredMovies = featuredMovies.subList(0, 8);

    HttpSession sess = request.getSession(false);
    String username = (sess != null) ? (String) sess.getAttribute("username") : null;
    String userId = (sess != null) ? (String) sess.getAttribute("userId") : null;
    String userType = (sess != null) ? (String) sess.getAttribute("userType") : null;

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Rental> userRentals = rentalDAO.getUserRentalHistory(userId);
    List<Rental> activeRentals = rentalDAO.getActiveRentals(userId);
    List<Review> userReviews = reviewDAO.getReviewsByUser(userId);
    double totalSpent = userRentals.stream().mapToDouble(Rental::getRentalPrice).sum();
    long totalRentals = userRentals.size();
    long activeCount = activeRentals.size();

    String msg = request.getParameter("msg");
    String activeTab = request.getParameter("tab");
    if (activeTab == null) activeTab = "overview";

    RecentlyWatchedStack recentStack = RecentlyWatchedStack.fromSession(sess);
    MovieDAO movieDAOForRecent = new MovieDAO(dataPath);
    List<Movie> recentlyWatched = recentStack.resolveMovies(movieDAOForRecent.getAllMovies());

    String sessionSuccess = (String) sess.getAttribute("success");
    String sessionError = (String) sess.getAttribute("error");
    if (sessionSuccess != null) sess.removeAttribute("success");
    if (sessionError != null) sess.removeAttribute("error");

    // Always read fresh from disk via file-backed QueueManager.
    String queuePath = basePath + "queue.txt";
    QueueManager queueManager = new QueueManager(queuePath);
    List<RentalRequest> pendingRequests = new ArrayList<>();
    for (RentalRequest r : queueManager.getAllRequests()) {
        if (r.getUserId().equals(userId)) pendingRequests.add(r);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Cinema — CineVault</title>
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
            --rose: #e11d48;
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

        /* Noise texture */
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

        .brand-icon i { font-size: 16px; color: var(--obsidian); }

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
            border-radius: var(--radius);
            cursor: pointer;
            transition: all 0.2s;
            color: var(--text-secondary);
            font-size: 13px;
            font-weight: 500;
            letter-spacing: 0.02em;
            text-decoration: none;
            position: relative;
            margin-bottom: 2px;
        }

        .nav-item:hover {
            background: var(--gold-dim);
            color: var(--gold-bright);
        }

        .nav-item.active {
            background: var(--gold-dim);
            color: var(--gold-bright);
            border-left: 2px solid var(--gold);
        }

        .nav-item i {
            width: 16px;
            text-align: center;
            font-size: 12px;
            opacity: 0.8;
        }

        .nav-badge {
            margin-left: auto;
            background: var(--crimson);
            color: white;
            font-size: 10px;
            padding: 2px 7px;
            border-radius: 10px;
            font-family: 'JetBrains Mono', monospace;
        }

        .nav-badge-gold {
            background: var(--gold-dim);
            color: var(--gold);
            border: 1px solid rgba(201,168,76,0.3);
        }

        .sidebar-footer {
            padding: 20px 16px;
            border-top: 1px solid var(--border);
        }

        .user-chip {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 14px;
            background: var(--charcoal);
            border-radius: var(--radius);
            border: 1px solid var(--border);
        }

        .user-avatar {
            width: 34px; height: 34px;
            background: linear-gradient(135deg, var(--gold-dim), rgba(201,168,76,0.3));
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Cormorant Garamond', serif;
            font-size: 15px;
            font-weight: 600;
            color: var(--gold);
            border: 1px solid rgba(201,168,76,0.3);
            flex-shrink: 0;
        }

        .user-info-name {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-primary);
        }

        .user-info-role {
            font-size: 10px;
            color: var(--gold);
            letter-spacing: 0.1em;
            text-transform: uppercase;
            font-family: 'JetBrains Mono', monospace;
        }

        .logout-btn {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 9px 14px;
            background: transparent;
            border: 1px solid rgba(192,57,43,0.25);
            border-radius: var(--radius);
            color: #e87a6e;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            margin-top: 8px;
            width: 100%;
            text-decoration: none;
            font-family: 'Syne', sans-serif;
        }

        .logout-btn:hover {
            background: rgba(192,57,43,0.12);
            border-color: rgba(192,57,43,0.5);
            color: #f87a6e;
        }

        /* ─── MAIN LAYOUT ─── */
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
            padding: 0 40px;
            height: 64px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 50;
        }

        .topbar-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 22px;
            font-weight: 600;
            letter-spacing: 0.04em;
            color: var(--text-primary);
        }

        .topbar-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .topbar-btn {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 18px;
            background: var(--gold);
            color: var(--obsidian);
            border: none;
            border-radius: var(--radius);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
            font-family: 'Syne', sans-serif;
        }

        .topbar-btn:hover {
            background: var(--gold-bright);
            color: var(--obsidian);
        }

        .topbar-btn-ghost {
            background: transparent;
            border: 1px solid var(--border-bright);
            color: var(--text-secondary);
        }

        .topbar-btn-ghost:hover {
            border-color: var(--gold);
            color: var(--gold);
            background: var(--gold-glow);
        }

        /* ─── CONTENT ─── */
        .content {
            flex: 1;
            padding: 36px 40px;
        }

        /* ─── FLASH MESSAGES ─── */
        .flash {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 20px;
            border-radius: var(--radius);
            margin-bottom: 28px;
            font-size: 13px;
        }

        .flash-success {
            background: rgba(26,158,110,0.1);
            border: 1px solid rgba(26,158,110,0.25);
            color: #5cd6a8;
        }

        .flash-error {
            background: rgba(192,57,43,0.1);
            border: 1px solid rgba(192,57,43,0.25);
            color: #f87a6e;
        }

        .flash-close {
            margin-left: auto;
            background: none;
            border: none;
            color: inherit;
            cursor: pointer;
            opacity: 0.6;
        }

        /* ─── HERO BANNER ─── */
        .hero-banner {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 36px 40px;
            margin-bottom: 36px;
            position: relative;
            overflow: hidden;
        }

        .hero-banner::before {
            content: '';
            position: absolute;
            top: -60px; right: -40px;
            width: 280px; height: 280px;
            background: radial-gradient(circle, rgba(201,168,76,0.06), transparent 70%);
            pointer-events: none;
        }

        .hero-banner::after {
            content: '';
            position: absolute;
            bottom: 0; left: 0;
            width: 100%; height: 1px;
            background: linear-gradient(90deg, var(--gold), transparent);
            opacity: 0.4;
        }

        .hero-greeting {
            font-size: 11px;
            letter-spacing: 0.3em;
            text-transform: uppercase;
            color: var(--gold);
            font-weight: 500;
            margin-bottom: 10px;
            font-family: 'JetBrains Mono', monospace;
        }

        .hero-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 42px;
            font-weight: 300;
            color: var(--text-primary);
            line-height: 1.1;
            margin-bottom: 12px;
        }

        .hero-title em {
            font-style: italic;
            color: var(--gold-bright);
        }

        .hero-sub {
            color: var(--text-secondary);
            font-size: 13px;
            max-width: 460px;
        }

        .hero-stats {
            display: flex;
            gap: 32px;
            align-items: center;
        }

        .hero-stat {
            text-align: center;
        }

        .hero-stat-num {
            font-family: 'Cormorant Garamond', serif;
            font-size: 32px;
            font-weight: 600;
            color: var(--gold-bright);
            line-height: 1;
        }

        .hero-stat-label {
            font-size: 9px;
            letter-spacing: 0.25em;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-top: 6px;
            font-family: 'JetBrains Mono', monospace;
        }

        .hero-stat-sep {
            width: 1px;
            height: 40px;
            background: var(--border-bright);
        }

        /* ─── STAT CARDS ─── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 24px;
            position: relative;
            overflow: hidden;
            transition: all 0.25s;
        }

        .stat-card:hover {
            border-color: var(--border-bright);
            transform: translateY(-2px);
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0;
            right: 0; height: 1px;
            background: linear-gradient(90deg, transparent, var(--gold), transparent);
            opacity: 0;
            transition: opacity 0.25s;
        }

        .stat-card:hover::before { opacity: 0.5; }

        .stat-icon {
            width: 40px; height: 40px;
            border-radius: var(--radius);
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 16px;
            font-size: 16px;
        }

        .stat-icon-gold { background: var(--gold-dim); color: var(--gold); }
        .stat-icon-green { background: rgba(26,158,110,0.12); color: #5cd6a8; }
        .stat-icon-rose { background: rgba(225,29,72,0.12); color: #fb7185; }
        .stat-icon-blue { background: rgba(37,99,235,0.12); color: #60a5fa; }

        .stat-number {
            font-family: 'Cormorant Garamond', serif;
            font-size: 36px;
            font-weight: 600;
            color: var(--text-primary);
            line-height: 1;
            margin-bottom: 6px;
        }

        .stat-label {
            font-size: 11px;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            color: var(--text-muted);
            font-family: 'JetBrains Mono', monospace;
        }

        /* ─── SECTION HEADERS ─── */
        .section-header {
            display: flex;
            align-items: baseline;
            gap: 16px;
            margin-bottom: 20px;
        }

        .section-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 22px;
            font-weight: 600;
            color: var(--text-primary);
            letter-spacing: 0.02em;
        }

        .section-rule {
            flex: 1;
            height: 1px;
            background: var(--border);
        }

        .section-count {
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            color: var(--text-muted);
        }

        /* ─── QUICK ACTION CARDS ─── */
        .action-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin-bottom: 36px;
        }

        .action-card {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 28px 24px;
            cursor: pointer;
            transition: all 0.25s;
            text-decoration: none;
            display: block;
            position: relative;
            overflow: hidden;
        }

        .action-card::after {
            content: '';
            position: absolute;
            bottom: 0; left: 0; right: 0;
            height: 2px;
            background: var(--gold);
            transform: scaleX(0);
            transition: transform 0.25s;
        }

        .action-card:hover { border-color: rgba(201,168,76,0.3); transform: translateY(-3px); }
        .action-card:hover::after { transform: scaleX(1); }

        .action-icon {
            font-size: 24px;
            color: var(--gold);
            margin-bottom: 14px;
            opacity: 0.8;
        }

        .action-title {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 6px;
        }

        .action-desc {
            font-size: 11px;
            color: var(--text-muted);
            line-height: 1.5;
        }

        /* ─── RENTAL ITEMS ─── */
        .rental-list { display: flex; flex-direction: column; gap: 10px; }

        .rental-item {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 18px 22px;
            display: flex;
            align-items: center;
            gap: 18px;
            transition: all 0.2s;
        }

        .rental-item:hover {
            border-color: var(--border-bright);
        }

        .rental-item.active-rental {
            border-left: 3px solid var(--gold);
        }

        .rental-item.overdue {
            border-left: 3px solid var(--crimson);
            background: rgba(192,57,43,0.04);
        }

        .rental-poster {
            width: 48px; height: 64px;
            background: var(--slate);
            border-radius: var(--radius);
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
            overflow: hidden;
            border: 1px solid var(--border);
        }

        .rental-poster img { width: 100%; height: 100%; object-fit: cover; }
        .rental-poster i { font-size: 18px; color: var(--text-muted); }

        .rental-info { flex: 1; min-width: 0; }

        .rental-title {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 4px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .rental-meta {
            font-size: 11px;
            color: var(--text-muted);
            font-family: 'JetBrains Mono', monospace;
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
        }

        .rental-status-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 3px 10px;
            border-radius: 10px;
            font-size: 10px;
            font-weight: 600;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            font-family: 'JetBrains Mono', monospace;
        }

        .badge-active { background: rgba(201,168,76,0.12); color: var(--gold); border: 1px solid rgba(201,168,76,0.25); }
        .badge-completed { background: rgba(26,158,110,0.1); color: #5cd6a8; border: 1px solid rgba(26,158,110,0.2); }
        .badge-overdue { background: rgba(192,57,43,0.12); color: #f87a6e; border: 1px solid rgba(192,57,43,0.25); }
        .badge-cancelled { background: rgba(90,86,80,0.2); color: var(--text-muted); border: 1px solid var(--border); }

        .rental-actions { display: flex; gap: 8px; flex-shrink: 0; }

        /* ─── BUTTONS ─── */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            border-radius: var(--radius);
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            cursor: pointer;
            border: none;
            text-decoration: none;
            transition: all 0.2s;
            font-family: 'Syne', sans-serif;
        }

        .btn-gold {
            background: var(--gold);
            color: var(--obsidian);
        }

        .btn-gold:hover { background: var(--gold-bright); color: var(--obsidian); }

        .btn-ghost {
            background: transparent;
            border: 1px solid var(--border-bright);
            color: var(--text-secondary);
        }

        .btn-ghost:hover { border-color: var(--gold); color: var(--gold); }

        .btn-danger {
            background: transparent;
            border: 1px solid rgba(192,57,43,0.3);
            color: #f87a6e;
        }

        .btn-danger:hover { background: rgba(192,57,43,0.12); }

        .btn-amber {
            background: rgba(217,119,6,0.12);
            border: 1px solid rgba(217,119,6,0.25);
            color: #fbbf24;
        }

        .btn-amber:hover { background: rgba(217,119,6,0.2); }

        /* ─── MOVIE GRID ─── */
        .movie-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
        }

        .movie-card {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            overflow: hidden;
            cursor: pointer;
            transition: all 0.25s;
        }

        .movie-card:hover {
            border-color: rgba(201,168,76,0.4);
            transform: translateY(-4px);
            box-shadow: 0 12px 32px rgba(0,0,0,0.4);
        }

        .movie-poster-wrap {
            height: 200px;
            overflow: hidden;
            background: var(--slate);
            position: relative;
        }

        .movie-poster-wrap img {
            width: 100%; height: 100%;
            object-fit: cover;
            transition: transform 0.4s;
        }

        .movie-card:hover .movie-poster-wrap img { transform: scale(1.05); }

        .movie-poster-placeholder {
            width: 100%; height: 100%;
            display: flex; align-items: center; justify-content: center;
        }

        .movie-poster-placeholder i {
            font-size: 32px;
            color: var(--text-muted);
            opacity: 0.5;
        }

        .movie-overlay {
            position: absolute;
            bottom: 0; left: 0; right: 0;
            height: 50%;
            background: linear-gradient(to top, rgba(8,8,8,0.9), transparent);
        }

        .movie-genre-tag {
            position: absolute;
            top: 10px; left: 10px;
            background: rgba(8,8,8,0.85);
            border: 1px solid var(--border-bright);
            color: var(--text-muted);
            font-size: 9px;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            padding: 3px 8px;
            border-radius: 2px;
            font-family: 'JetBrains Mono', monospace;
        }

        .movie-info {
            padding: 16px;
        }

        .movie-title {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 4px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .movie-director {
            font-size: 11px;
            color: var(--text-muted);
            margin-bottom: 10px;
        }

        .movie-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .movie-rating {
            color: var(--gold);
            font-size: 11px;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .movie-price {
            font-family: 'JetBrains Mono', monospace;
            font-size: 12px;
            color: var(--gold-bright);
            font-weight: 500;
        }

        .movie-avail {
            font-size: 10px;
            padding: 2px 8px;
            border-radius: 2px;
        }

        /* ─── TABLE ─── */
        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .data-table th {
            text-align: left;
            padding: 10px 16px;
            font-size: 9px;
            letter-spacing: 0.25em;
            text-transform: uppercase;
            color: var(--text-muted);
            border-bottom: 1px solid var(--border);
            font-weight: 600;
            font-family: 'JetBrains Mono', monospace;
        }

        .data-table td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--border);
            color: var(--text-secondary);
            vertical-align: middle;
        }

        .data-table tr:hover td { background: var(--charcoal); }

        .data-table td strong {
            color: var(--text-primary);
            font-weight: 600;
        }

        .table-wrap {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            overflow: hidden;
        }

        /* ─── REVIEW ITEMS ─── */
        .review-item {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 22px;
            margin-bottom: 12px;
            transition: all 0.2s;
        }

        .review-item:hover { border-color: var(--border-bright); }

        .review-movie {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 6px;
        }

        .review-stars {
            color: var(--gold);
            font-size: 13px;
            letter-spacing: 2px;
        }

        .review-comment {
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.6;
            margin: 10px 0;
        }

        .review-date {
            font-size: 10px;
            font-family: 'JetBrains Mono', monospace;
            color: var(--text-muted);
        }

        /* ─── EMPTY STATE ─── */
        .empty-state {
            text-align: center;
            padding: 60px 40px;
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
        }

        .empty-icon {
            font-size: 40px;
            color: var(--text-muted);
            opacity: 0.3;
            margin-bottom: 20px;
        }

        .empty-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 22px;
            color: var(--text-secondary);
            margin-bottom: 8px;
        }

        .empty-sub {
            font-size: 12px;
            color: var(--text-muted);
            margin-bottom: 24px;
        }

        /* ─── SETTINGS ─── */
        .settings-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .settings-panel {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 28px;
        }

        .settings-panel-title {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .settings-panel-title i { color: var(--gold); font-size: 13px; }

        .toggle-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid var(--border);
        }

        .toggle-row:last-child { border-bottom: none; }

        .toggle-label {
            font-size: 12px;
            color: var(--text-secondary);
        }

        .toggle-switch {
            width: 36px; height: 20px;
            background: var(--slate);
            border-radius: 10px;
            border: 1px solid var(--border-bright);
            position: relative;
            cursor: pointer;
            transition: all 0.2s;
        }

        .toggle-switch.on { background: var(--gold-dim); border-color: rgba(201,168,76,0.4); }

        .toggle-switch::after {
            content: '';
            position: absolute;
            top: 2px; left: 2px;
            width: 14px; height: 14px;
            background: var(--text-muted);
            border-radius: 50%;
            transition: all 0.2s;
        }

        .toggle-switch.on::after {
            left: 18px;
            background: var(--gold);
        }

        .form-field {
            margin-bottom: 16px;
        }

        .form-label {
            display: block;
            font-size: 10px;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 8px;
            font-family: 'JetBrains Mono', monospace;
        }

        .form-select {
            width: 100%;
            background: var(--slate);
            border: 1px solid var(--border-bright);
            border-radius: var(--radius);
            color: var(--text-primary);
            padding: 10px 14px;
            font-size: 13px;
            font-family: 'Syne', sans-serif;
            appearance: none;
            cursor: pointer;
        }

        .form-select:focus {
            outline: none;
            border-color: var(--gold);
        }

        /* ─── RECENTLY WATCHED ─── */
        .stack-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
        }

        .stack-item {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 18px;
            display: flex;
            align-items: center;
            gap: 14px;
            transition: all 0.2s;
        }

        .stack-item:hover { border-color: var(--border-bright); }
        .stack-item.top-item { border-left: 3px solid var(--gold); }

        .stack-pos {
            width: 38px; height: 38px;
            background: var(--gold-dim);
            border-radius: var(--radius);
            display: flex; align-items: center; justify-content: center;
            font-family: 'JetBrains Mono', monospace;
            font-size: 12px;
            color: var(--gold);
            flex-shrink: 0;
            border: 1px solid rgba(201,168,76,0.2);
        }

        .stack-movie-title {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-primary);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .stack-movie-meta {
            font-size: 10px;
            color: var(--text-muted);
            margin-top: 3px;
            font-family: 'JetBrains Mono', monospace;
        }

        .stack-tag {
            font-size: 9px;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            color: var(--gold);
            background: var(--gold-dim);
            border: 1px solid rgba(201,168,76,0.2);
            padding: 2px 8px;
            border-radius: 2px;
            margin-top: 6px;
            display: inline-block;
            font-family: 'JetBrains Mono', monospace;
        }

        /* ─── TAB CONTENT ─── */
        .tab-pane { display: none; }
        .tab-pane.active { display: block; animation: fadeUp 0.3s ease; }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* ─── MODAL ─── */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.8);
            z-index: 200;
            align-items: center;
            justify-content: center;
        }

        .modal-overlay.open { display: flex; }

        .modal-box {
            background: var(--charcoal);
            border: 1px solid var(--border-bright);
            border-radius: var(--radius-lg);
            padding: 32px;
            width: 440px;
            max-width: 90vw;
            position: relative;
        }

        .modal-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 22px;
            color: var(--text-primary);
            margin-bottom: 24px;
        }

        .modal-close {
            position: absolute;
            top: 20px; right: 20px;
            background: none;
            border: none;
            color: var(--text-muted);
            cursor: pointer;
            font-size: 16px;
        }

        .modal-close:hover { color: var(--text-primary); }

        .modal-field { margin-bottom: 18px; }

        .modal-label {
            display: block;
            font-size: 10px;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 8px;
            font-family: 'JetBrains Mono', monospace;
        }

        .modal-select, .modal-textarea {
            width: 100%;
            background: var(--slate);
            border: 1px solid var(--border-bright);
            border-radius: var(--radius);
            color: var(--text-primary);
            padding: 10px 14px;
            font-size: 13px;
            font-family: 'Syne', sans-serif;
        }

        .modal-select:focus, .modal-textarea:focus {
            outline: none;
            border-color: var(--gold);
        }

        .modal-textarea { resize: vertical; min-height: 90px; }

        /* ─── FINE INDICATOR ─── */
        .fine-indicator {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-top: 6px;
            font-size: 11px;
            color: #f87a6e;
            font-family: 'JetBrains Mono', monospace;
            background: rgba(192,57,43,0.08);
            padding: 3px 10px;
            border-radius: 2px;
        }

        /* ─── SCROLLBAR ─── */
        ::-webkit-scrollbar { width: 4px; height: 4px; }
        ::-webkit-scrollbar-track { background: var(--void); }
        ::-webkit-scrollbar-thumb { background: rgba(201,168,76,0.3); border-radius: 2px; }

        /* ─── ACTIVE RENTAL HIGHLIGHT ─── */
        .currently-watching {
            background: var(--charcoal);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 28px;
            margin-bottom: 32px;
        }

        /* ─── HORIZONTAL DIVIDER ─── */
        .hdivider {
            height: 1px;
            background: var(--border);
            margin: 32px 0;
        }
    </style>
</head>
<body>

<!-- ═══════════ SIDEBAR ═══════════ -->
<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="brand-icon"><i class="fas fa-film"></i></div>
        <div class="brand-name">CineVault</div>
        <div class="brand-sub">Member Portal</div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Navigation</div>

        <a class="nav-item <%= activeTab.equals("overview") ? "active" : "" %>"
           href="${pageContext.request.contextPath}/dashboard?tab=overview">
            <i class="fas fa-th-large"></i> Overview
        </a>
        <a class="nav-item <%= activeTab.equals("rentals") ? "active" : "" %>"
           href="${pageContext.request.contextPath}/dashboard?tab=rentals">
            <i class="fas fa-ticket-alt"></i> My Rentals
            <% if (activeCount > 0) { %>
                <span class="nav-badge"><%= activeCount %></span>
            <% } %>
        </a>
        <a class="nav-item <%= activeTab.equals("waitlist") ? "active" : "" %>"
           href="${pageContext.request.contextPath}/dashboard?tab=waitlist">
            <i class="fas fa-hourglass-half"></i> My Waitlist
            <% if (pendingRequests != null && pendingRequests.size() > 0) { %>
                <span class="nav-badge nav-badge-gold"><%= pendingRequests.size() %></span>
            <% } %>
        </a>
        <a class="nav-item <%= activeTab.equals("history") ? "active" : "" %>"
           href="${pageContext.request.contextPath}/dashboard?tab=history">
            <i class="fas fa-clock-rotate-left"></i> History
        </a>
        <a class="nav-item <%= activeTab.equals("reviews") ? "active" : "" %>"
           href="${pageContext.request.contextPath}/dashboard?tab=reviews">
            <i class="fas fa-star"></i> My Reviews
            <% if (userReviews != null && userReviews.size() > 0) { %>
                <span class="nav-badge nav-badge-gold"><%= userReviews.size() %></span>
            <% } %>
        </a>
        <a class="nav-item <%= activeTab.equals("recommended") ? "active" : "" %>"
           href="${pageContext.request.contextPath}/dashboard?tab=recommended">
            <i class="fas fa-fire-flame-curved"></i> Recommended
        </a>
        <a class="nav-item <%= activeTab.equals("recent") ? "active" : "" %>"
           href="${pageContext.request.contextPath}/dashboard?tab=recent">
            <i class="fas fa-layer-group"></i> Recently Watched
        </a>

        <div class="nav-section-label">Account</div>

        <a class="nav-item" href="${pageContext.request.contextPath}/movies">
            <i class="fas fa-search"></i> Browse Movies
        </a>
        <a class="nav-item" href="${pageContext.request.contextPath}/profile">
            <i class="fas fa-user-circle"></i> My Profile
        </a>
        <a class="nav-item <%= activeTab.equals("settings") ? "active" : "" %>"
           href="${pageContext.request.contextPath}/dashboard?tab=settings">
            <i class="fas fa-sliders"></i> Settings
        </a>
    </nav>

    <div class="sidebar-footer">
        <div class="user-chip">
            <div class="user-avatar"><%= username.substring(0,1).toUpperCase() %></div>
            <div>
                <div class="user-info-name"><%= username %></div>
                <div class="user-info-role">Member</div>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
            <i class="fas fa-right-from-bracket"></i> Sign Out
        </a>
    </div>
</aside>

<!-- ═══════════ MAIN ═══════════ -->
<main class="main">

    <!-- Top Bar -->
    <div class="topbar">
        <div class="topbar-title">
            <%
                String tabLabel = "Overview";
                if (activeTab.equals("rentals")) tabLabel = "My Rentals";
                else if (activeTab.equals("history")) tabLabel = "Rental History";
                else if (activeTab.equals("reviews")) tabLabel = "My Reviews";
                else if (activeTab.equals("recommended")) tabLabel = "Recommended";
                else if (activeTab.equals("recent")) tabLabel = "Recently Watched";
                else if (activeTab.equals("settings")) tabLabel = "Settings";
            %>
            <%= tabLabel %>
        </div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/movies" class="btn btn-ghost topbar-btn">
                <i class="fas fa-search"></i> Browse Movies
            </a>
            <a href="${pageContext.request.contextPath}/movies" class="btn btn-gold topbar-btn">
                <i class="fas fa-plus"></i> Rent a Film
            </a>
        </div>
    </div>

    <div class="content">

        <!-- Flash Messages -->
        <% if (msg != null && !msg.isEmpty()) { %>
        <div class="flash flash-success">
            <i class="fas fa-circle-check"></i> <%= msg %>
            <button class="flash-close" onclick="this.parentElement.remove()"><i class="fas fa-xmark"></i></button>
        </div>
        <% } %>
        <% if (sessionSuccess != null) { %>
        <div class="flash flash-success">
            <i class="fas fa-circle-check"></i> <%= sessionSuccess %>
            <button class="flash-close" onclick="this.parentElement.remove()"><i class="fas fa-xmark"></i></button>
        </div>
        <% } %>
        <% if (sessionError != null) { %>
        <div class="flash flash-error">
            <i class="fas fa-circle-exclamation"></i> <%= sessionError %>
            <button class="flash-close" onclick="this.parentElement.remove()"><i class="fas fa-xmark"></i></button>
        </div>
        <% } %>

        <!-- ══════ OVERVIEW TAB ══════ -->
        <div class="tab-pane <%= activeTab.equals("overview") ? "active" : "" %>">

            <!-- Hero -->
            <div class="hero-banner">
                <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                    <div>
                        <div class="hero-greeting">Welcome Back</div>
                        <div class="hero-title">Good to see you, <em><%= username %></em>.</div>
                        <div class="hero-sub">Your personal cinema awaits. Discover films, track rentals, and share your cinematic journey.</div>
                    </div>
                    <div class="hero-stats">
                        <div class="hero-stat">
                            <div class="hero-stat-num"><%= activeCount %></div>
                            <div class="hero-stat-label">Active</div>
                        </div>
                        <div class="hero-stat-sep"></div>
                        <div class="hero-stat">
                            <div class="hero-stat-num"><%= totalRentals %></div>
                            <div class="hero-stat-label">Total</div>
                        </div>
                        <div class="hero-stat-sep"></div>
                        <div class="hero-stat">
                            <div class="hero-stat-num">$<%= String.format("%.0f", totalSpent) %></div>
                            <div class="hero-stat-label">Spent</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Stats -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon stat-icon-gold"><i class="fas fa-ticket-alt"></i></div>
                    <div class="stat-number"><%= activeCount %></div>
                    <div class="stat-label">Active Rentals</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon stat-icon-green"><i class="fas fa-clock-rotate-left"></i></div>
                    <div class="stat-number"><%= totalRentals %></div>
                    <div class="stat-label">Total Rentals</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon stat-icon-blue"><i class="fas fa-dollar-sign"></i></div>
                    <div class="stat-number">$<%= String.format("%.0f", totalSpent) %></div>
                    <div class="stat-label">Total Spent</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon stat-icon-rose"><i class="fas fa-star"></i></div>
                    <div class="stat-number"><%= userReviews != null ? userReviews.size() : 0 %></div>
                    <div class="stat-label">Reviews Written</div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="section-header">
                <div class="section-title">Quick Actions</div>
                <div class="section-rule"></div>
            </div>
            <div class="action-grid">
                <a href="${pageContext.request.contextPath}/movies" class="action-card">
                    <div class="action-icon"><i class="fas fa-film"></i></div>
                    <div class="action-title">Browse Films</div>
                    <div class="action-desc">Discover our curated collection of new releases and classics.</div>
                </a>
                <a href="${pageContext.request.contextPath}/dashboard?tab=rentals" class="action-card">
                    <div class="action-icon"><i class="fas fa-play-circle"></i></div>
                    <div class="action-title">Track Rentals</div>
                    <div class="action-desc">Manage your active rentals, extend or return films.</div>
                </a>
                <a href="${pageContext.request.contextPath}/dashboard?tab=reviews" class="action-card">
                    <div class="action-icon"><i class="fas fa-pen-nib"></i></div>
                    <div class="action-title">Write Reviews</div>
                    <div class="action-desc">Share your thoughts and help fellow cinephiles discover great films.</div>
                </a>
            </div>

            <!-- Currently Watching -->
            <% if (activeRentals != null && !activeRentals.isEmpty()) { %>
            <div class="section-header" style="margin-top:36px;">
                <div class="section-title">Currently Watching</div>
                <div class="section-rule"></div>
                <div class="section-count"><%= activeCount %> active</div>
            </div>
            <div class="rental-list">
                <% for (Rental rental : activeRentals) { %>
                <div class="rental-item active-rental <%= rental.isOverdue() ? "overdue" : "" %>">
                    <div class="rental-poster"><i class="fas fa-film"></i></div>
                    <div class="rental-info">
                        <div class="rental-title"><%= rental.getMovieTitle() %></div>
                        <div class="rental-meta">
                            <span><i class="fas fa-calendar-check"></i> Rented <%= rental.getFormattedRentDate() %></span>
                            <span class="<%= rental.isOverdue() ? "" : "" %>">
                                <i class="fas fa-calendar-xmark"></i> Due <%= rental.getFormattedDueDate() %>
                            </span>
                            <% if (rental.isOverdue()) { %>
                                <span style="color:#f87a6e;"><i class="fas fa-triangle-exclamation"></i> Fine: $<%= rental.calculateFine() %></span>
                            <% } %>
                        </div>
                    </div>
                    <div class="rental-status-badge <%= rental.isOverdue() ? "badge-overdue" : "badge-active" %>">
                        <i class="fas fa-circle" style="font-size:6px;"></i>
                        <%= rental.isOverdue() ? "Overdue" : "Active" %>
                    </div>
                    <div class="rental-actions">
                        <a href="${pageContext.request.contextPath}/movies/<%= rental.getMovieId() %>" class="btn btn-gold">Watch</a>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>

        <!-- ══════ RENTALS TAB ══════ -->
        <div class="tab-pane <%= activeTab.equals("rentals") ? "active" : "" %>">
            <div class="section-header">
                <div class="section-title">Active Rentals</div>
                <div class="section-rule"></div>
                <a href="${pageContext.request.contextPath}/movies" class="btn btn-gold" style="padding:7px 16px;">
                    <i class="fas fa-plus"></i> Rent More
                </a>
            </div>

            <% if (activeRentals == null || activeRentals.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon"><i class="fas fa-film"></i></div>
                <div class="empty-title">No Active Rentals</div>
                <div class="empty-sub">You don't have any films rented at the moment.</div>
                <a href="${pageContext.request.contextPath}/movies" class="btn btn-gold">Browse Films</a>
            </div>
            <% } else { %>
            <div class="rental-list">
                <% for (Rental rental : activeRentals) {
                    Movie movie = movieDAO.getMovieById(rental.getMovieId());
                    String posterUrl = "";
                    if (movie != null) {
                        String title = movie.getTitle();
                        if (title.equals("Inception")) posterUrl = "https://image.tmdb.org/t/p/w200/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg";
                        else if (title.equals("The Dark Knight")) posterUrl = "https://image.tmdb.org/t/p/w200/qJ2tW6WMUDux911r6m7haRef0WH.jpg";
                        else if (title.equals("Interstellar")) posterUrl = "https://image.tmdb.org/t/p/w200/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg";
                    }
                %>
                <div class="rental-item active-rental <%= rental.isOverdue() ? "overdue" : "" %>">
                    <div class="rental-poster">
                        <% if (!posterUrl.isEmpty()) { %>
                            <img src="<%= posterUrl %>" alt="<%= rental.getMovieTitle() %>">
                        <% } else { %>
                            <i class="fas fa-film"></i>
                        <% } %>
                    </div>
                    <div class="rental-info">
                        <div class="rental-title"><%= rental.getMovieTitle() %></div>
                        <div class="rental-meta">
                            <span><i class="fas fa-calendar-check"></i> <%= rental.getFormattedRentDate() %></span>
                            <span><i class="fas fa-calendar-xmark"></i> Due <%= rental.getFormattedDueDate() %></span>
                            <span><i class="fas fa-dollar-sign"></i> $<%= rental.getRentalPrice() %>/day</span>
                        </div>
                        <% if (rental.isOverdue()) { %>
                        <div class="fine-indicator">
                            <i class="fas fa-triangle-exclamation"></i> Late fee: $<%= rental.calculateFine() %>
                        </div>
                        <% } %>
                    </div>
                    <div class="rental-status-badge <%= rental.isOverdue() ? "badge-overdue" : "badge-active" %>">
                        <i class="fas fa-circle" style="font-size:6px;"></i>
                        <%= rental.isOverdue() ? "Overdue" : "Active" %>
                    </div>
                    <div class="rental-actions">
                        <form action="${pageContext.request.contextPath}/profile" method="post" style="margin:0;">
                            <input type="hidden" name="action" value="returnRental">
                            <input type="hidden" name="redirectTo" value="dashboard">
                            <input type="hidden" name="rentalId" value="<%= rental.getRentalId() %>">
                            <button type="submit" class="btn btn-gold">Return</button>
                        </form>
                        <button class="btn btn-amber" onclick="showExtend('<%= rental.getRentalId() %>')">+Days</button>
                        <form action="${pageContext.request.contextPath}/profile" method="post" style="margin:0;"
                              onsubmit="return confirm('Cancel this rental?')">
                            <input type="hidden" name="action" value="cancelRental">
                            <input type="hidden" name="redirectTo" value="dashboard">
                            <input type="hidden" name="rentalId" value="<%= rental.getRentalId() %>">
                            <button type="submit" class="btn btn-danger">Cancel</button>
                        </form>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>

        <!-- ══════ WAITLIST TAB ══════ -->
        <div class="tab-pane <%= activeTab.equals("waitlist") ? "active" : "" %>">
            <div class="section-header">
                <div class="section-title">My Waitlist</div>
                <div class="section-rule"></div>
                <div class="section-count"><%= pendingRequests != null ? pendingRequests.size() : 0 %> pending</div>
            </div>

            <% if (pendingRequests == null || pendingRequests.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon"><i class="fas fa-hourglass-half"></i></div>
                <div class="empty-title">No Pending Requests</div>
                <div class="empty-sub">You're not on any waitlist. When a movie is unavailable, you'll be added here automatically.</div>
                <a href="${pageContext.request.contextPath}/movies" class="btn btn-gold">Browse Films</a>
            </div>
            <% } else { %>
            <div class="rental-list">
                <% for (int i = 0; i < pendingRequests.size(); i++) {
                    RentalRequest req = pendingRequests.get(i);
                %>
                <div class="rental-item active-rental">
                    <div class="rental-poster"><i class="fas fa-hourglass-half" style="color:var(--gold);"></i></div>
                    <div class="rental-info">
                        <div class="rental-title"><%= req.getMovieTitle() %></div>
                        <div class="rental-meta">
                            <span><i class="fas fa-calendar-plus"></i> Requested: <%= req.getFormattedTime() %></span>
                            <span><i class="fas fa-clock"></i> <%= req.getRentalDays() %> days rental</span>
                            <span><i class="fas fa-list-ol"></i> Queue position: #<%= i + 1 %></span>
                        </div>
                    </div>
                    <div class="rental-status-badge badge-active">
                        <i class="fas fa-circle" style="font-size:6px;"></i> Pending
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>

        <!-- ══════ HISTORY TAB ══════ -->
        <div class="tab-pane <%= activeTab.equals("history") ? "active" : "" %>">
            <div class="section-header">
                <div class="section-title">Rental History</div>
                <div class="section-rule"></div>
                <div class="section-count"><%= totalRentals %> total</div>
            </div>

            <% if (userRentals == null || userRentals.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon"><i class="fas fa-clock-rotate-left"></i></div>
                <div class="empty-title">No History Yet</div>
                <div class="empty-sub">Your rental history will appear here once you start watching.</div>
                <a href="${pageContext.request.contextPath}/movies" class="btn btn-gold">Start Watching</a>
            </div>
            <% } else { %>
            <div class="table-wrap">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Film</th>
                            <th>Rented</th>
                            <th>Due</th>
                            <th>Returned</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Rental rental : userRentals) { %>
                        <tr>
                            <td><strong><%= rental.getMovieTitle() %></strong></td>
                            <td><%= rental.getFormattedRentDate() %></td>
                            <td style="<%= rental.isOverdue() ? "color:#f87a6e;" : "" %>"><%= rental.getFormattedDueDate() %></td>
                            <td><%= rental.getReturnDate() != null ? rental.getReturnDate().toString() : "—" %></td>
                            <td style="font-family:'JetBrains Mono',monospace;">$<%= rental.getRentalPrice() %></td>
                            <td>
                                <span class="rental-status-badge
                                    <%= rental.getStatus().equals("ACTIVE") ? "badge-active" :
                                        rental.getStatus().equals("COMPLETED") ? "badge-completed" : "badge-cancelled" %>">
                                    <i class="fas fa-circle" style="font-size:6px;"></i>
                                    <%= rental.getStatus() %>
                                </span>
                            </td>
                            <td>
                                <% if (rental.getStatus().equals("ACTIVE")) { %>
                                <div style="display:flex;gap:6px;flex-wrap:wrap;">
                                    <form action="${pageContext.request.contextPath}/profile" method="post" style="margin:0;">
                                        <input type="hidden" name="action" value="returnRental">
                                        <input type="hidden" name="redirectTo" value="dashboard">
                                        <input type="hidden" name="rentalId" value="<%= rental.getRentalId() %>">
                                        <button type="submit" class="btn btn-gold" style="padding:5px 12px;">Return</button>
                                    </form>
                                    <button class="btn btn-amber" style="padding:5px 10px;" onclick="showExtend('<%= rental.getRentalId() %>')">+Days</button>
                                    <form action="${pageContext.request.contextPath}/profile" method="post" style="margin:0;"
                                          onsubmit="return confirm('Cancel?')">
                                        <input type="hidden" name="action" value="cancelRental">
                                        <input type="hidden" name="redirectTo" value="dashboard">
                                        <input type="hidden" name="rentalId" value="<%= rental.getRentalId() %>">
                                        <button type="submit" class="btn btn-danger" style="padding:5px 10px;">Cancel</button>
                                    </form>
                                </div>
                                <% } else { %>
                                <a href="${pageContext.request.contextPath}/movies/<%= rental.getMovieId() %>" class="btn btn-ghost" style="padding:5px 12px;">Rent Again</a>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>

        <!-- ══════ REVIEWS TAB ══════ -->
        <div class="tab-pane <%= activeTab.equals("reviews") ? "active" : "" %>">
            <div class="section-header">
                <div class="section-title">My Reviews</div>
                <div class="section-rule"></div>
                <a href="${pageContext.request.contextPath}/movies" class="btn btn-gold" style="padding:7px 16px;">
                    <i class="fas fa-pen-nib"></i> Write Review
                </a>
            </div>

            <% if (userReviews == null || userReviews.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon"><i class="fas fa-star"></i></div>
                <div class="empty-title">No Reviews Yet</div>
                <div class="empty-sub">Share your cinematic perspective with the community.</div>
                <a href="${pageContext.request.contextPath}/movies" class="btn btn-gold">Browse &amp; Review</a>
            </div>
            <% } else { %>
            <% for (Review review : userReviews) {
                Movie movie = movieDAO.getMovieById(review.getMovieId());
            %>
            <div class="review-item">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:20px;">
                    <div style="flex:1; min-width:0;">
                        <div style="display:flex; align-items:center; gap:14px; margin-bottom:8px; flex-wrap:wrap;">
                            <div class="review-movie"><%= movie != null ? movie.getTitle() : "Film" %></div>
                            <div class="review-stars">
                                <% for(int i=0; i<review.getRating(); i++) { %>★<% } %>
                                <% for(int i=review.getRating(); i<5; i++) { %><span style="opacity:0.2;">★</span><% } %>
                            </div>
                            <div class="rental-status-badge badge-active" style="font-size:9px;padding:2px 8px;">
                                <%= review.getRating() %>/5
                            </div>
                        </div>
                        <div class="review-comment"><%= review.getComment() %></div>
                        <div class="review-date">
                            <i class="fas fa-calendar-alt" style="margin-right:5px;"></i>
                            Reviewed <%= review.getFormattedDate() %>
                            <% if (review.isEdited()) { %><span style="margin-left:8px;">(edited)</span><% } %>
                        </div>
                    </div>
                    <div style="display:flex; gap:8px; flex-shrink:0;">
                        <button class="btn btn-ghost"
                            onclick="editReview('<%= review.getReviewId() %>', <%= review.getRating() %>, '<%= review.getComment().replace("'", "\\'") %>', '<%= review.getMovieId() %>')">
                            <i class="fas fa-pen"></i> Edit
                        </button>
                        <form action="${pageContext.request.contextPath}/review/delete" method="post" style="margin:0;">
                            <input type="hidden" name="reviewId" value="<%= review.getReviewId() %>">
                            <input type="hidden" name="movieId" value="<%= review.getMovieId() %>">
                            <button type="submit" class="btn btn-danger" onclick="return confirm('Delete this review?')">
                                <i class="fas fa-trash"></i>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>
            <% } %>
        </div>

        <!-- ══════ RECOMMENDED TAB ══════ -->
        <div class="tab-pane <%= activeTab.equals("recommended") ? "active" : "" %>">
            <div class="section-header">
                <div class="section-title">Recommended For You</div>
                <div class="section-rule"></div>
                <div class="section-count">Top rated films</div>
            </div>

            <div class="movie-grid">
                <% for (Movie movie : featuredMovies) {
                    String posterUrl = "";
                    String title = movie.getTitle();
                    if (title.equals("Inception")) posterUrl = "https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg";
                    else if (title.equals("The Dark Knight")) posterUrl = "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg";
                    else if (title.equals("Interstellar")) posterUrl = "https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg";
                    else if (title.equals("Parasite")) posterUrl = "https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg";
                    else if (title.equals("The Godfather")) posterUrl = "https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg";
                %>
                <div class="movie-card" onclick="location.href='${pageContext.request.contextPath}/movies/<%= movie.getMovieId() %>'">
                    <div class="movie-poster-wrap">
                        <% if (!posterUrl.isEmpty()) { %>
                            <img src="<%= posterUrl %>" alt="<%= movie.getTitle() %>">
                        <% } else { %>
                            <div class="movie-poster-placeholder">
                                <i class="fas fa-film"></i>
                            </div>
                        <% } %>
                        <div class="movie-overlay"></div>
                        <div class="movie-genre-tag"><%= movie.getGenre() %></div>
                    </div>
                    <div class="movie-info">
                        <div class="movie-title"><%= movie.getTitle() %></div>
                        <div class="movie-director"><%= movie.getDirector() %></div>
                        <div class="movie-footer">
                            <div class="movie-rating">
                                <i class="fas fa-star"></i>
                                <%= String.format("%.1f", movie.getRating()) %>
                            </div>
                            <div class="movie-price">$<%= movie.getRentalPrice() %></div>
                        </div>
                        <div style="margin-top:10px; display:flex; justify-content:space-between; align-items:center;">
                            <span class="rental-status-badge <%= movie.getAvailableCopies() > 0 ? "badge-completed" : "badge-cancelled" %>" style="font-size:9px;">
                                <%= movie.getAvailableCopies() %> available
                            </span>
                            <span style="font-size:10px;color:var(--text-muted);font-family:'JetBrains Mono',monospace;"><%= movie.getReleaseYear() %></span>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>

        <!-- ══════ RECENTLY WATCHED TAB ══════ -->
        <div class="tab-pane <%= activeTab.equals("recent") ? "active" : "" %>">
            <div class="section-header">
                <div class="section-title">Recently Watched</div>
                <div class="section-rule"></div>
                <div class="section-count" style="display:flex;align-items:center;gap:8px;">
                    <i class="fas fa-layer-group" style="color:var(--gold);font-size:11px;"></i>
                    Stack (LIFO) · depth <%= recentStack.size() %>
                </div>
            </div>
            <div style="font-size:11px;color:var(--text-muted);margin-bottom:24px;font-family:'JetBrains Mono',monospace;background:var(--charcoal);border:1px solid var(--border);border-radius:var(--radius);padding:10px 16px;display:inline-flex;align-items:center;gap:10px;">
                <i class="fas fa-info-circle" style="color:var(--gold);"></i>
                Most recently viewed film appears at the top of the stack.
            </div>

            <% if (recentlyWatched.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon"><i class="fas fa-layer-group"></i></div>
                <div class="empty-title">Stack Empty</div>
                <div class="empty-sub">Browse films and click on any title to build your viewing history.</div>
                <a href="${pageContext.request.contextPath}/movies" class="btn btn-gold">Browse Films</a>
            </div>
            <% } else { %>
            <div class="stack-grid">
                <% int stackPos = 1; for (Movie rm : recentlyWatched) { %>
                <div class="stack-item <%= stackPos == 1 ? "top-item" : "" %>">
                    <div class="stack-pos">
                        <% if (stackPos == 1) { %><i class="fas fa-caret-up"></i><% } else { %>#<%= stackPos %><% } %>
                    </div>
                    <div style="flex:1;min-width:0;">
                        <div class="stack-movie-title"><%= rm.getTitle() %></div>
                        <div class="stack-movie-meta"><%= rm.getGenre() %> &bull; <%= rm.getReleaseYear() %> &bull; ★ <%= String.format("%.1f", rm.getRating()) %></div>
                        <% if (stackPos == 1) { %><div class="stack-tag">Stack Top</div><% } %>
                    </div>
                    <a href="${pageContext.request.contextPath}/movies/<%= rm.getMovieId() %>" class="btn btn-ghost" style="padding:6px 12px;flex-shrink:0;">
                        View
                    </a>
                </div>
                <% stackPos++; } %>
            </div>
            <div style="margin-top:16px;font-size:10px;color:var(--text-muted);font-family:'JetBrains Mono',monospace;">
                Showing <%= recentlyWatched.size() %> of up to 10 recent titles
            </div>
            <% } %>
        </div>

        <!-- ══════ SETTINGS TAB ══════ -->
        <div class="tab-pane <%= activeTab.equals("settings") ? "active" : "" %>">
            <div class="section-header">
                <div class="section-title">Settings &amp; Preferences</div>
                <div class="section-rule"></div>
            </div>

            <div class="settings-grid">
                <div class="settings-panel">
                    <div class="settings-panel-title"><i class="fas fa-bell"></i> Notifications</div>
                    <div class="toggle-row">
                        <div class="toggle-label">Email notifications</div>
                        <div class="toggle-switch on" onclick="this.classList.toggle('on')"></div>
                    </div>
                    <div class="toggle-row">
                        <div class="toggle-label">Rental due reminders</div>
                        <div class="toggle-switch on" onclick="this.classList.toggle('on')"></div>
                    </div>
                    <div class="toggle-row">
                        <div class="toggle-label">New releases alerts</div>
                        <div class="toggle-switch" onclick="this.classList.toggle('on')"></div>
                    </div>
                    <div class="toggle-row">
                        <div class="toggle-label">Promotional offers</div>
                        <div class="toggle-switch" onclick="this.classList.toggle('on')"></div>
                    </div>
                </div>

                <div class="settings-panel">
                    <div class="settings-panel-title"><i class="fas fa-palette"></i> Preferences</div>
                    <div class="form-field">
                        <label class="form-label">Preferred Language</label>
                        <select class="form-select">
                            <option>English</option>
                            <option>Spanish</option>
                            <option>French</option>
                            <option>German</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Streaming Quality</label>
                        <select class="form-select">
                            <option>Auto (Recommended)</option>
                            <option>1080p HD</option>
                            <option>4K Ultra HD</option>
                        </select>
                    </div>
                    <div class="form-field" style="margin-bottom:0;">
                        <label class="form-label">Default Rental Period</label>
                        <select class="form-select">
                            <option>3 days</option>
                            <option>5 days</option>
                            <option>7 days</option>
                            <option>14 days</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="settings-panel">
                <div class="settings-panel-title"><i class="fas fa-user-gear"></i> Account Management</div>
                <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:12px; margin-top:8px;">
                    <a href="${pageContext.request.contextPath}/profile" class="btn btn-ghost" style="justify-content:center;padding:12px;">
                        <i class="fas fa-user-pen"></i> Edit Profile
                    </a>
                    <button class="btn btn-ghost" style="justify-content:center;padding:12px;" onclick="alert('Download feature coming soon!')">
                        <i class="fas fa-download"></i> Download History
                    </button>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger" style="justify-content:center;padding:12px;">
                        <i class="fas fa-right-from-bracket"></i> Sign Out
                    </a>
                </div>
            </div>
        </div>

    </div><!-- /content -->
</main>

<!-- ══════ EXTEND MODAL ══════ -->
<div class="modal-overlay" id="extendModal">
    <div class="modal-box">
        <button class="modal-close" onclick="document.getElementById('extendModal').classList.remove('open')">
            <i class="fas fa-xmark"></i>
        </button>
        <div class="modal-title">Extend Rental</div>
        <form action="${pageContext.request.contextPath}/profile" method="post">
            <input type="hidden" name="action" value="extendRental">
            <input type="hidden" name="redirectTo" value="dashboard">
            <input type="hidden" name="rentalId" id="extendRentalId">
            <div class="modal-field">
                <label class="modal-label">Additional Days</label>
                <select name="extraDays" class="modal-select">
                    <option value="1">1 day</option>
                    <option value="3" selected>3 days</option>
                    <option value="7">7 days</option>
                    <option value="14">14 days</option>
                </select>
            </div>
            <button type="submit" class="btn btn-gold" style="width:100%;justify-content:center;padding:12px;">
                <i class="fas fa-calendar-plus"></i> Extend Rental
            </button>
        </form>
    </div>
</div>

<!-- ══════ EDIT REVIEW MODAL ══════ -->
<div class="modal-overlay" id="editReviewModal">
    <div class="modal-box">
        <button class="modal-close" onclick="document.getElementById('editReviewModal').classList.remove('open')">
            <i class="fas fa-xmark"></i>
        </button>
        <div class="modal-title">Edit Review</div>
        <form id="editReviewForm" action="${pageContext.request.contextPath}/review/edit" method="post">
            <input type="hidden" name="reviewId" id="editReviewId">
            <input type="hidden" name="movieId" id="editMovieId">
            <div class="modal-field">
                <label class="modal-label">Rating</label>
                <select name="rating" id="editRating" class="modal-select">
                    <option value="5">★★★★★ — Exceptional (5)</option>
                    <option value="4">★★★★☆ — Very Good (4)</option>
                    <option value="3">★★★☆☆ — Good (3)</option>
                    <option value="2">★★☆☆☆ — Fair (2)</option>
                    <option value="1">★☆☆☆☆ — Poor (1)</option>
                </select>
            </div>
            <div class="modal-field">
                <label class="modal-label">Your Review</label>
                <textarea name="comment" id="editComment" class="modal-textarea" required></textarea>
            </div>
            <button type="submit" class="btn btn-gold" style="width:100%;justify-content:center;padding:12px;">
                <i class="fas fa-check"></i> Save Changes
            </button>
        </form>
    </div>
</div>

<script>
    function showExtend(rentalId) {
        document.getElementById('extendRentalId').value = rentalId;
        document.getElementById('extendModal').classList.add('open');
    }

    function editReview(reviewId, rating, comment, movieId) {
        document.getElementById('editReviewId').value = reviewId;
        document.getElementById('editRating').value = rating;
        document.getElementById('editComment').value = comment;
        document.getElementById('editMovieId').value = movieId || '';
        document.getElementById('editReviewModal').classList.add('open');
    }

    // Close modals on backdrop click
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', function(e) {
            if (e.target === this) this.classList.remove('open');
        });
    });

    // Auto-dismiss flash messages
    setTimeout(() => {
        document.querySelectorAll('.flash').forEach(el => {
            el.style.opacity = '0';
            el.style.transition = 'opacity 0.5s';
            setTimeout(() => el.remove(), 500);
        });
    }, 4000);
</script>
</body>
</html>
