<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.dao.MovieDAO, com.movierental.model.Movie, java.util.List" %>
<%@ page import="com.movierental.utils.QueueManager" %>
<%
    String basePath = application.getInitParameter("data.path").replace("${user.home}", System.getProperty("user.home"));
    String dataPath = basePath + "movies.txt";
    MovieDAO movieDAO = new MovieDAO(dataPath);
    List<Movie> movies = movieDAO.getAllMovies();

    String keyword = request.getParameter("q");
    if (keyword != null && !keyword.isEmpty()) {
        movies = movieDAO.searchMovies(keyword);
    }
    String genre = request.getParameter("genre");
    if (genre != null && !genre.isEmpty() && !genre.equals("All")) {
        movies = movieDAO.getMoviesByGenre(genre);
    }
    movies = QueueManager.insertionSortByRating(movies);

    HttpSession sess = request.getSession(false);
    String uname = (sess != null) ? (String) sess.getAttribute("username") : null;
    String activeGenre = (genre != null && !genre.isEmpty()) ? genre : "All";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Movies — CineRent</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root {
            --bg:        #080b12;
            --surface:   #0f1420;
            --surface2:  #161c2d;
            --border:    rgba(255,255,255,0.07);
            --accent:    #e8b84b;
            --accent2:   #3b82f6;
            --red:       #ef4444;
            --green:     #22c55e;
            --text:      #f1f5f9;
            --muted:     #64748b;
            --card-h:    320px;
        }

        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* ── Noise overlay ── */
        body::before {
            content: '';
            position: fixed; inset: 0; z-index: 0;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.03'/%3E%3C/svg%3E");
            pointer-events: none;
        }

        /* ── Sidebar ── */
        .sidebar {
            position: fixed; top: 0; left: 0;
            width: 72px; height: 100vh;
            background: var(--surface);
            border-right: 1px solid var(--border);
            display: flex; flex-direction: column; align-items: center;
            padding: 28px 0; gap: 6px;
            z-index: 100;
            transition: width 0.3s ease;
        }
        .sidebar:hover { width: 220px; }

        .logo-mark {
            width: 40px; height: 40px;
            background: var(--accent);
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif;
            font-weight: 800; font-size: 18px;
            color: #000;
            margin-bottom: 24px;
            flex-shrink: 0;
        }

        .nav-link {
            width: 100%;
            display: flex; align-items: center;
            gap: 14px;
            padding: 12px 16px;
            color: var(--muted);
            text-decoration: none;
            font-size: 0.85rem;
            font-weight: 500;
            letter-spacing: 0.01em;
            border-radius: 0;
            transition: all 0.2s;
            white-space: nowrap;
            overflow: hidden;
            position: relative;
        }
        .nav-link i { font-size: 1.1rem; min-width: 20px; text-align: center; flex-shrink: 0; }
        .nav-link span { opacity: 0; transition: opacity 0.2s 0.05s; }
        .sidebar:hover .nav-link span { opacity: 1; }
        .nav-link:hover { color: var(--text); background: rgba(255,255,255,0.04); }
        .nav-link.active {
            color: var(--accent);
            background: rgba(232,184,75,0.08);
        }
        .nav-link.active::before {
            content: '';
            position: absolute; left: 0; top: 0; bottom: 0;
            width: 3px;
            background: var(--accent);
            border-radius: 0 2px 2px 0;
        }

        .sidebar-bottom {
            margin-top: auto;
            width: 100%;
            display: flex; flex-direction: column; align-items: center;
            gap: 6px;
        }

        /* ── Main Layout ── */
        .main {
            margin-left: 72px;
            min-height: 100vh;
            position: relative; z-index: 1;
        }

        /* ── Top bar ── */
        .topbar {
            position: sticky; top: 0; z-index: 90;
            background: rgba(8,11,18,0.85);
            backdrop-filter: blur(24px);
            border-bottom: 1px solid var(--border);
            padding: 0 36px;
            height: 64px;
            display: flex; align-items: center; justify-content: space-between;
        }

        .page-title {
            font-family: 'Syne', sans-serif;
            font-weight: 700;
            font-size: 1.1rem;
            color: var(--text);
            display: flex; align-items: center; gap: 10px;
        }
        .page-title .breadcrumb-sep { color: var(--muted); font-weight: 400; }

        .topbar-right {
            display: flex; align-items: center; gap: 16px;
        }

        .search-wrap {
            position: relative;
        }
        .search-wrap i {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
            color: var(--muted); font-size: 0.85rem;
        }
        .search-input {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 10px;
            color: var(--text);
            padding: 9px 16px 9px 38px;
            font-size: 0.85rem;
            font-family: 'DM Sans', sans-serif;
            width: 260px;
            transition: all 0.2s;
            outline: none;
        }
        .search-input::placeholder { color: var(--muted); }
        .search-input:focus {
            border-color: var(--accent);
            background: var(--surface2);
            box-shadow: 0 0 0 3px rgba(232,184,75,0.1);
        }

        .user-chip {
            display: flex; align-items: center; gap: 10px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 7px 14px;
            font-size: 0.85rem;
            font-weight: 500;
            text-decoration: none;
            color: var(--text);
            transition: all 0.2s;
        }
        .user-chip:hover { border-color: var(--accent); color: var(--accent); }
        .user-avatar {
            width: 26px; height: 26px;
            background: var(--accent);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; font-weight: 700; color: #000;
        }

        /* ── Content ── */
        .content { padding: 32px 36px; }

        /* ── Dashboard Header ── */
        .dash-header {
            display: grid;
            grid-template-columns: 1fr auto;
            align-items: start;
            gap: 24px;
            margin-bottom: 28px;
        }

        .dash-headline {
            font-family: 'Syne', sans-serif;
            font-size: 2.2rem;
            font-weight: 800;
            line-height: 1.1;
            letter-spacing: -0.02em;
        }
        .dash-headline .highlight { color: var(--accent); }
        .dash-sub {
            color: var(--muted);
            margin-top: 6px;
            font-size: 0.9rem;
        }

        /* ── Stats Strip ── */
        .stats-strip {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 32px;
        }
        .stat-tile {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 20px 22px;
            position: relative;
            overflow: hidden;
            transition: border-color 0.2s;
        }
        .stat-tile:hover { border-color: rgba(232,184,75,0.3); }
        .stat-tile::after {
            content: '';
            position: absolute; top: 0; right: 0;
            width: 80px; height: 80px;
            border-radius: 50%;
            transform: translate(30%, -30%);
            background: var(--tile-glow, rgba(59,130,246,0.12));
        }
        .stat-tile:nth-child(1) { --tile-glow: rgba(232,184,75,0.12); }
        .stat-tile:nth-child(2) { --tile-glow: rgba(59,130,246,0.12); }
        .stat-tile:nth-child(3) { --tile-glow: rgba(34,197,94,0.12); }
        .stat-tile:nth-child(4) { --tile-glow: rgba(239,68,68,0.12); }
        .stat-label { font-size: 0.75rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 10px; }
        .stat-value { font-family: 'Syne', sans-serif; font-size: 1.9rem; font-weight: 700; }
        .stat-icon { position: absolute; top: 18px; right: 20px; font-size: 1.1rem; color: var(--muted); opacity: 0.5; }

        /* ── Genre Bar ── */
        .genre-bar {
            display: flex; align-items: center; gap: 8px;
            margin-bottom: 28px;
            flex-wrap: wrap;
        }
        .genre-label {
            font-size: 0.75rem; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.1em;
            color: var(--muted);
            margin-right: 4px;
        }
        .genre-pill {
            padding: 7px 16px;
            border-radius: 100px;
            font-size: 0.8rem;
            font-weight: 500;
            text-decoration: none;
            border: 1px solid var(--border);
            color: var(--muted);
            background: transparent;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .genre-pill:hover { color: var(--text); border-color: rgba(255,255,255,0.2); }
        .genre-pill.active {
            background: var(--accent);
            border-color: var(--accent);
            color: #000;
            font-weight: 600;
        }

        /* ── Toolbar ── */
        .toolbar {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 24px;
        }
        .result-count {
            font-size: 0.85rem; color: var(--muted);
        }
        .result-count strong { color: var(--text); }

        .view-toggle { display: flex; gap: 4px; }
        .view-btn {
            width: 34px; height: 34px;
            border-radius: 8px;
            border: 1px solid var(--border);
            background: transparent;
            color: var(--muted);
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.85rem;
            transition: all 0.2s;
        }
        .view-btn.active, .view-btn:hover { background: var(--surface2); color: var(--text); border-color: rgba(255,255,255,0.15); }

        /* ── Movie Grid ── */
        .movies-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 20px;
        }

        .movie-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            cursor: pointer;
            transition: transform 0.25s ease, border-color 0.25s ease, box-shadow 0.25s ease;
            animation: cardIn 0.4s ease both;
        }
        .movie-card:hover {
            transform: translateY(-6px);
            border-color: rgba(232,184,75,0.35);
            box-shadow: 0 20px 40px rgba(0,0,0,0.4), 0 0 0 1px rgba(232,184,75,0.1);
        }

        @keyframes cardIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        /* Stagger */
        .movie-card:nth-child(1)  { animation-delay: 0.03s; }
        .movie-card:nth-child(2)  { animation-delay: 0.06s; }
        .movie-card:nth-child(3)  { animation-delay: 0.09s; }
        .movie-card:nth-child(4)  { animation-delay: 0.12s; }
        .movie-card:nth-child(5)  { animation-delay: 0.15s; }
        .movie-card:nth-child(6)  { animation-delay: 0.18s; }
        .movie-card:nth-child(7)  { animation-delay: 0.21s; }
        .movie-card:nth-child(8)  { animation-delay: 0.24s; }

        .movie-poster {
            height: 280px;
            background: var(--surface2);
            position: relative;
            overflow: hidden;
        }
        .movie-poster img {
            width: 100%; height: 100%;
            object-fit: cover;
            transition: transform 0.4s ease;
        }
        .movie-card:hover .movie-poster img { transform: scale(1.06); }

        .poster-placeholder {
            width: 100%; height: 100%;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            gap: 10px;
            background: linear-gradient(135deg, #0f1420 0%, #161c2d 100%);
        }
        .poster-placeholder i { font-size: 2.5rem; color: var(--muted); opacity: 0.4; }
        .poster-placeholder span { font-size: 0.7rem; color: var(--muted); opacity: 0.3; letter-spacing: 0.1em; }

        .poster-overlay {
            position: absolute; inset: 0;
            background: linear-gradient(to top, rgba(8,11,18,0.95) 0%, rgba(8,11,18,0.3) 50%, transparent 100%);
            opacity: 0; transition: opacity 0.3s;
        }
        .movie-card:hover .poster-overlay { opacity: 1; }

        .genre-badge {
            position: absolute; top: 12px; left: 12px;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.65rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            background: rgba(232,184,75,0.15);
            border: 1px solid rgba(232,184,75,0.3);
            color: var(--accent);
            backdrop-filter: blur(8px);
        }

        .copies-badge {
            position: absolute; top: 12px; right: 12px;
            width: 28px; height: 28px;
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.7rem; font-weight: 700;
            backdrop-filter: blur(8px);
        }
        .copies-badge.available { background: rgba(34,197,94,0.15); color: var(--green); border: 1px solid rgba(34,197,94,0.3); }
        .copies-badge.unavailable { background: rgba(239,68,68,0.15); color: var(--red); border: 1px solid rgba(239,68,68,0.3); }

        .card-body { padding: 16px 18px 18px; }

        .movie-title {
            font-family: 'Syne', sans-serif;
            font-weight: 700;
            font-size: 0.95rem;
            line-height: 1.3;
            margin-bottom: 4px;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }

        .movie-meta {
            font-size: 0.75rem;
            color: var(--muted);
            margin-bottom: 10px;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }

        .rating-row {
            display: flex; align-items: center; gap: 6px;
            margin-bottom: 14px;
        }
        .stars { color: var(--accent); font-size: 0.75rem; letter-spacing: 1px; }
        .rating-num { font-size: 0.75rem; font-weight: 600; color: var(--accent); }

        .card-footer-row {
            display: flex; align-items: center; justify-content: space-between;
        }
        .price-tag {
            font-family: 'Syne', sans-serif;
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--text);
        }
        .price-tag span { font-size: 0.7rem; font-weight: 400; color: var(--muted); font-family: 'DM Sans', sans-serif; }

        .rent-btn {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 8px 14px;
            background: var(--accent);
            color: #000;
            border: none;
            border-radius: 8px;
            font-size: 0.78rem;
            font-weight: 700;
            font-family: 'DM Sans', sans-serif;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
        }
        .rent-btn:hover { background: #f0c75a; transform: scale(1.03); }
        .rent-btn.disabled {
            background: var(--surface2);
            color: var(--muted);
            cursor: not-allowed;
            border: 1px solid var(--border);
        }
        .rent-btn.disabled:hover { transform: none; }

        /* ── List View ── */
        .movies-list { display: none; flex-direction: column; gap: 12px; }
        .movies-list.visible { display: flex; }
        .movies-grid.hidden { display: none; }

        .list-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 14px;
            display: grid;
            grid-template-columns: 80px 1fr auto;
            gap: 0;
            overflow: hidden;
            cursor: pointer;
            transition: border-color 0.2s, transform 0.2s;
            animation: cardIn 0.35s ease both;
        }
        .list-card:hover { border-color: rgba(232,184,75,0.35); transform: translateX(4px); }

        .list-thumb {
            width: 80px; height: 80px;
            background: var(--surface2);
            flex-shrink: 0;
            overflow: hidden;
        }
        .list-thumb img { width: 100%; height: 100%; object-fit: cover; }
        .list-thumb-placeholder {
            width: 100%; height: 100%;
            display: flex; align-items: center; justify-content: center;
            color: var(--muted); opacity: 0.3;
        }

        .list-info {
            padding: 14px 18px;
            display: flex; flex-direction: column; justify-content: center; gap: 4px;
        }
        .list-title {
            font-family: 'Syne', sans-serif; font-weight: 700; font-size: 0.9rem;
        }
        .list-sub { font-size: 0.75rem; color: var(--muted); }
        .list-actions {
            display: flex; align-items: center; gap: 14px;
            padding: 14px 20px;
        }

        /* ── Empty ── */
        .empty-state {
            text-align: center; padding: 80px 20px;
            grid-column: 1 / -1;
        }
        .empty-state i { font-size: 3rem; color: var(--muted); opacity: 0.3; margin-bottom: 16px; display: block; }
        .empty-state h3 { font-family: 'Syne', sans-serif; font-weight: 700; margin-bottom: 8px; }
        .empty-state p { color: var(--muted); font-size: 0.9rem; }

        /* ── Responsive ── */
        @media (max-width: 900px) {
            .sidebar { width: 56px; }
            .main { margin-left: 56px; }
            .stats-strip { grid-template-columns: repeat(2,1fr); }
            .content { padding: 20px 18px; }
            .topbar { padding: 0 18px; }
        }
        @media (max-width: 600px) {
            .search-input { width: 160px; }
            .dash-headline { font-size: 1.6rem; }
            .stats-strip { grid-template-columns: repeat(2,1fr); }
            .movies-grid { grid-template-columns: repeat(2,1fr); gap: 12px; }
        }
    </style>
</head>
<body>

<%-- ── Sidebar ── --%>
<aside class="sidebar" id="sidebar">
    <div class="logo-mark">CR</div>

    <a href="${pageContext.request.contextPath}/" class="nav-link">
        <i class="fas fa-house"></i><span>Home</span>
    </a>
    <a href="${pageContext.request.contextPath}/movies" class="nav-link active">
        <i class="fas fa-film"></i><span>Movies</span>
    </a>
    <% if (uname != null) { %>
    <a href="${pageContext.request.contextPath}/dashboard" class="nav-link">
        <i class="fas fa-chart-line"></i><span>Dashboard</span>
    </a>
    <% } %>
    <a href="${pageContext.request.contextPath}/reviews" class="nav-link">
        <i class="fas fa-star"></i><span>Reviews</span>
    </a>

    <div class="sidebar-bottom">
        <% if (uname != null) { %>
        <a href="${pageContext.request.contextPath}/profile" class="nav-link">
            <i class="fas fa-user-circle"></i><span><%= uname %></span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="nav-link" style="color: #ef4444;">
            <i class="fas fa-arrow-right-from-bracket"></i><span>Logout</span>
        </a>
        <% } else { %>
        <a href="${pageContext.request.contextPath}/pages/login.jsp" class="nav-link">
            <i class="fas fa-right-to-bracket"></i><span>Sign In</span>
        </a>
        <% } %>
    </div>
</aside>

<%-- ── Main ── --%>
<div class="main">

    <%-- Top bar --%>
    <header class="topbar">
        <div class="page-title">
            <span style="color:var(--muted)">CineRent</span>
            <span class="breadcrumb-sep">/</span>
            Movies
        </div>
        <div class="topbar-right">
            <form method="get" action="${pageContext.request.contextPath}/movies" class="search-wrap">
                <i class="fas fa-magnifying-glass"></i>
                <input
                    class="search-input"
                    type="text" name="q"
                    placeholder="Search title or director…"
                    value="<%= keyword != null ? keyword : "" %>">
                <% if (genre != null && !genre.isEmpty() && !genre.equals("All")) { %>
                <input type="hidden" name="genre" value="<%= genre %>">
                <% } %>
            </form>
            <% if (uname != null) { %>
            <a href="${pageContext.request.contextPath}/profile" class="user-chip">
                <div class="user-avatar"><%= uname.substring(0,1).toUpperCase() %></div>
                <%= uname %>
            </a>
            <% } else { %>
            <a href="${pageContext.request.contextPath}/pages/login.jsp" class="user-chip">
                <i class="fas fa-right-to-bracket" style="font-size:0.8rem"></i> Sign In
            </a>
            <% } %>
        </div>
    </header>

    <%-- Content --%>
    <div class="content">

        <%-- Header --%>
        <div class="dash-header">
            <div>
                <h1 class="dash-headline">
                    <% if (keyword != null && !keyword.isEmpty()) { %>
                    Results for <span class="highlight">"<%= keyword %>"</span>
                    <% } else if (!activeGenre.equals("All")) { %>
                    <span class="highlight"><%= activeGenre %></span> Films
                    <% } else { %>
                    Movie <span class="highlight">Library</span>
                    <% } %>
                </h1>
                <p class="dash-sub">Sorted by rating · <%= movies != null ? movies.size() : 0 %> titles found</p>
            </div>
        </div>

        <%-- Stats Strip --%>
        <%
            int totalMovies = movies != null ? movies.size() : 0;
            int availableCount = 0;
            double avgRating = 0;
            int premiumCount = 0;
            if (movies != null) {
                for (Movie m : movies) {
                    if (m.getAvailableCopies() > 0) availableCount++;
                    avgRating += m.getRating();
                    if (m.getRentalPrice() >= 5.0) premiumCount++;
                }
                if (totalMovies > 0) avgRating = avgRating / totalMovies;
            }
        %>
        <div class="stats-strip">
            <div class="stat-tile">
                <i class="fas fa-film stat-icon"></i>
                <div class="stat-label">Total Titles</div>
                <div class="stat-value"><%= totalMovies %></div>
            </div>
            <div class="stat-tile">
                <i class="fas fa-circle-check stat-icon"></i>
                <div class="stat-label">Available Now</div>
                <div class="stat-value"><%= availableCount %></div>
            </div>
            <div class="stat-tile">
                <i class="fas fa-star stat-icon"></i>
                <div class="stat-label">Avg Rating</div>
                <div class="stat-value"><%= String.format("%.1f", avgRating) %></div>
            </div>
            <div class="stat-tile">
                <i class="fas fa-crown stat-icon"></i>
                <div class="stat-label">Premium Picks</div>
                <div class="stat-value"><%= premiumCount %></div>
            </div>
        </div>

        <%-- Genre Filter Bar --%>
        <div class="genre-bar">
            <span class="genre-label">Genre</span>
            <% String[] genres = {"All","Action","Sci-Fi","Drama","Comedy","Thriller","Crime"}; %>
            <% for (String g : genres) { %>
            <a href="${pageContext.request.contextPath}/movies<%= g.equals("All") ? "" : "?genre=" + g %>"
               class="genre-pill <%= activeGenre.equals(g) ? "active" : "" %>"><%= g %></a>
            <% } %>
        </div>

        <%-- Toolbar --%>
        <div class="toolbar">
            <p class="result-count">
                Showing <strong><%= totalMovies %></strong> movie<%= totalMovies != 1 ? "s" : "" %>
                <% if (keyword != null && !keyword.isEmpty()) { %>
                &nbsp;·&nbsp;<a href="${pageContext.request.contextPath}/movies" style="color:var(--accent);text-decoration:none;font-size:0.8rem">Clear</a>
                <% } %>
            </p>
            <div class="view-toggle">
                <button class="view-btn active" id="gridBtn" onclick="setView('grid')" title="Grid view">
                    <i class="fas fa-grid-2"></i>
                </button>
                <button class="view-btn" id="listBtn" onclick="setView('list')" title="List view">
                    <i class="fas fa-list"></i>
                </button>
            </div>
        </div>

        <%-- ── Grid View ── --%>
        <div class="movies-grid" id="gridView">
            <% if (movies != null && !movies.isEmpty()) {
                for (Movie movie : movies) {
                    String posterImg = movie.getPosterUrlOrDefault();
            %>
            <div class="movie-card"
                 onclick="location.href='${pageContext.request.contextPath}/movies/<%= movie.getMovieId() %>'">

                <div class="movie-poster">
                    <% if (!posterImg.isEmpty()) { %>
                    <img src="<%= posterImg %>" alt="<%= movie.getTitle() %>" loading="lazy">
                    <% } else { %>
                    <div class="poster-placeholder">
                        <i class="fas fa-clapperboard"></i>
                        <span>NO POSTER</span>
                    </div>
                    <% } %>
                    <div class="poster-overlay"></div>
                    <span class="genre-badge"><%= movie.getGenre() %></span>
                    <span class="copies-badge <%= movie.getAvailableCopies() > 0 ? "available" : "unavailable" %>">
                        <%= movie.getAvailableCopies() %>
                    </span>
                </div>

                <div class="card-body">
                    <div class="movie-title"><%= movie.getTitle() %></div>
                    <div class="movie-meta"><%= movie.getDirector() %> &middot; <%= movie.getReleaseYear() %></div>
                    <div class="rating-row">
                        <span class="stars">
                            <%
                                int full = (int) movie.getRating();
                                for (int i = 0; i < full; i++) { out.print("★"); }
                                for (int i = full; i < 5; i++) { out.print("☆"); }
                            %>
                        </span>
                        <span class="rating-num"><%= movie.getRating() %></span>
                    </div>
                    <div class="card-footer-row" onclick="event.stopPropagation()">
                        <div class="price-tag">$<%= movie.getRentalPrice() %><span>/3 days</span></div>
                        <% if (uname != null) { %>
                            <% if (movie.getAvailableCopies() > 0) { %>
                            <form action="${pageContext.request.contextPath}/rent" method="post" style="margin:0">
                                <input type="hidden" name="movieId" value="<%= movie.getMovieId() %>">
                                <input type="hidden" name="days" value="3">
                                <button type="submit" class="rent-btn">
                                    <i class="fas fa-play" style="font-size:0.65rem"></i> Rent
                                </button>
                            </form>
                            <% } else { %>
                            <form action="${pageContext.request.contextPath}/rent" method="post" style="margin:0">
                                <input type="hidden" name="movieId" value="<%= movie.getMovieId() %>">
                                <input type="hidden" name="days" value="3">
                                <button type="submit" class="rent-btn" style="background:#2a2a1a;color:#c9a84c;border:1px solid rgba(201,168,76,0.4);">
                                    <i class="fas fa-clock" style="font-size:0.65rem"></i> Waitlist
                                </button>
                            </form>
                            <% } %>
                        <% } else { %>
                        <a href="${pageContext.request.contextPath}/pages/login.jsp" class="rent-btn">
                            <i class="fas fa-lock" style="font-size:0.65rem"></i> Sign in
                        </a>
                        <% } %>
                    </div>
                </div>
            </div>
            <%  }
            } else { %>
            <div class="empty-state">
                <i class="fas fa-magnifying-glass"></i>
                <h3>No movies found</h3>
                <p>Try a different search term or browse all genres.</p>
                <a href="${pageContext.request.contextPath}/movies" style="color:var(--accent);font-size:0.85rem;margin-top:12px;display:inline-block">Browse all →</a>
            </div>
            <% } %>
        </div>

        <%-- ── List View ── --%>
        <div class="movies-list" id="listView">
            <% if (movies != null && !movies.isEmpty()) {
                for (Movie movie : movies) {
                    String posterImg = movie.getPosterUrlOrDefault();
            %>
            <div class="list-card"
                 onclick="location.href='${pageContext.request.contextPath}/movies/<%= movie.getMovieId() %>'">
                <div class="list-thumb">
                    <% if (!posterImg.isEmpty()) { %>
                    <img src="<%= posterImg %>" alt="">
                    <% } else { %>
                    <div class="list-thumb-placeholder"><i class="fas fa-film"></i></div>
                    <% } %>
                </div>
                <div class="list-info">
                    <div class="list-title"><%= movie.getTitle() %></div>
                    <div class="list-sub">
                        <%= movie.getDirector() %> &middot; <%= movie.getReleaseYear() %> &middot; <%= movie.getGenre() %>
                    </div>
                    <div class="rating-row" style="margin:0">
                        <span class="stars" style="font-size:0.7rem">
                            <%
                                int f2 = (int) movie.getRating();
                                for (int i = 0; i < f2; i++) { out.print("★"); }
                                for (int i = f2; i < 5; i++) { out.print("☆"); }
                            %>
                        </span>
                        <span class="rating-num"><%= movie.getRating() %></span>
                    </div>
                </div>
                <div class="list-actions" onclick="event.stopPropagation()">
                    <div style="text-align:right">
                        <div class="price-tag" style="font-size:0.95rem">$<%= movie.getRentalPrice() %></div>
                        <div style="font-size:0.7rem;color:var(--muted);margin-top:2px">
                            <%= movie.getAvailableCopies() %> left
                        </div>
                    </div>
                    <% if (uname != null && movie.getAvailableCopies() > 0) { %>
                    <form action="${pageContext.request.contextPath}/rent" method="post" style="margin:0">
                        <input type="hidden" name="movieId" value="<%= movie.getMovieId() %>">
                        <input type="hidden" name="days" value="3">
                        <button type="submit" class="rent-btn">Rent</button>
                    </form>
                    <% } else if (uname == null) { %>
                    <a href="${pageContext.request.contextPath}/pages/login.jsp" class="rent-btn">Sign in</a>
                    <% } else { %>
                    <form action="${pageContext.request.contextPath}/rent" method="post" style="margin:0">
                        <input type="hidden" name="movieId" value="<%= movie.getMovieId() %>">
                        <input type="hidden" name="days" value="3">
                        <button type="submit" class="rent-btn" style="background:#2a2a1a;color:#c9a84c;border:1px solid rgba(201,168,76,0.4);">
                            <i class="fas fa-clock" style="font-size:0.65rem"></i> Join Waitlist
                        </button>
                    </form>
                    <% } %>
                </div>
            </div>
            <%  }
            } %>
        </div>

    </div><%-- /content --%>
</div><%-- /main --%>

<script>
    function setView(v) {
        const grid = document.getElementById('gridView');
        const list = document.getElementById('listView');
        const gb   = document.getElementById('gridBtn');
        const lb   = document.getElementById('listBtn');
        if (v === 'grid') {
            grid.classList.remove('hidden');
            list.classList.remove('visible');
            gb.classList.add('active');
            lb.classList.remove('active');
            localStorage.setItem('cinerview','grid');
        } else {
            grid.classList.add('hidden');
            list.classList.add('visible');
            lb.classList.add('active');
            gb.classList.remove('active');
            localStorage.setItem('cinerview','list');
        }
    }
    // Restore preference
    const saved = localStorage.getItem('cinerview');
    if (saved === 'list') setView('list');
</script>
</body>
</html>
