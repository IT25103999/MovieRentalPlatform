<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.dao.MovieDAO, com.movierental.model.Movie" %>
<%
    Movie movie = (Movie) request.getAttribute("movie");
    String basePath = application.getInitParameter("data.path").replace("${user.home}", System.getProperty("user.home"));
    String dataPath = basePath + "movies.txt";
    MovieDAO movieDAO = new MovieDAO(dataPath);
    if (movie == null) {
        String id = request.getParameter("id");
        if (id == null || id.isEmpty()) { response.sendRedirect("movies.jsp"); return; }
        movie = movieDAO.getMovieById(id);
        if (movie == null) { response.sendRedirect("movies.jsp"); return; }
    }
    String posterUrl = movie.getPosterUrlOrDefault();
    HttpSession userSession = request.getSession(false);
    String userId   = (userSession != null) ? (String) userSession.getAttribute("userId")   : null;
    String uname    = (userSession != null) ? (String) userSession.getAttribute("username") : null;
    String flashSuccess = (userSession != null) ? (String) userSession.getAttribute("success") : null;
    String flashError   = (userSession != null) ? (String) userSession.getAttribute("error")   : null;
    if (flashSuccess != null) userSession.removeAttribute("success");
    if (flashError   != null) userSession.removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= movie.getTitle() %> — CineRent</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root{--bg:#080b12;--surface:#0f1420;--surface2:#161c2d;--border:rgba(255,255,255,0.07);--accent:#e8b84b;--text:#f1f5f9;--muted:#64748b;--green:#22c55e;--red:#ef4444;}
        *,*::before,*::after{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;overflow-x:hidden;}
        body::before{content:'';position:fixed;inset:0;z-index:0;background-image:url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.03'/%3E%3C/svg%3E");pointer-events:none;}

        .sidebar{position:fixed;top:0;left:0;width:72px;height:100vh;background:var(--surface);border-right:1px solid var(--border);display:flex;flex-direction:column;align-items:center;padding:28px 0;gap:6px;z-index:100;transition:width .3s ease;}
        .sidebar:hover{width:220px;}
        .logo-mark{width:40px;height:40px;background:var(--accent);border-radius:12px;display:flex;align-items:center;justify-content:center;font-family:'Syne',sans-serif;font-weight:800;font-size:18px;color:#000;margin-bottom:24px;flex-shrink:0;}
        .nav-link{width:100%;display:flex;align-items:center;gap:14px;padding:12px 16px;color:var(--muted);text-decoration:none;font-size:.85rem;font-weight:500;white-space:nowrap;overflow:hidden;position:relative;transition:all .2s;}
        .nav-link i{font-size:1.1rem;min-width:20px;text-align:center;flex-shrink:0;}
        .nav-link span{opacity:0;transition:opacity .2s .05s;}
        .sidebar:hover .nav-link span{opacity:1;}
        .nav-link:hover{color:var(--text);background:rgba(255,255,255,.04);}
        .nav-link.active{color:var(--accent);background:rgba(232,184,75,.08);}
        .nav-link.active::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--accent);border-radius:0 2px 2px 0;}
        .sidebar-bottom{margin-top:auto;width:100%;display:flex;flex-direction:column;gap:6px;}

        .main{margin-left:72px;position:relative;z-index:1;}

        .topbar{position:sticky;top:0;z-index:90;background:rgba(8,11,18,.85);backdrop-filter:blur(24px);border-bottom:1px solid var(--border);padding:0 36px;height:64px;display:flex;align-items:center;justify-content:space-between;}
        .page-title{font-family:'Syne',sans-serif;font-weight:700;font-size:1.05rem;display:flex;align-items:center;gap:10px;color:var(--text);}
        .bc-sep{color:var(--muted);}
        .topbar-right{display:flex;align-items:center;gap:12px;}
        .chip{display:inline-flex;align-items:center;gap:8px;background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:7px 14px;font-size:.85rem;font-weight:500;text-decoration:none;color:var(--text);transition:all .2s;}
        .chip:hover{border-color:var(--accent);color:var(--accent);}
        .user-av{width:26px;height:26px;background:var(--accent);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;color:#000;}

        /* Hero backdrop */
        .hero-back{position:relative;height:360px;overflow:hidden;}
        .hero-back img{width:100%;height:100%;object-fit:cover;filter:blur(28px) brightness(.22);transform:scale(1.1);}
        .hero-back-grad{position:absolute;inset:0;background:linear-gradient(to bottom,rgba(8,11,18,.2),rgba(8,11,18,1));}
        .hero-back-empty{height:360px;background:linear-gradient(135deg,var(--surface),var(--bg));}

        /* Content */
        .content{padding:0 36px 60px;position:relative;z-index:2;margin-top:-160px;}

        .detail-grid{display:grid;grid-template-columns:260px 1fr;gap:36px;align-items:start;}

        /* Poster */
        .poster-wrap{border-radius:18px;overflow:hidden;border:1px solid rgba(232,184,75,.15);box-shadow:0 32px 64px rgba(0,0,0,.7);position:sticky;top:84px;}
        .poster-wrap img{width:100%;display:block;}
        .poster-ph{height:380px;background:var(--surface2);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:12px;color:var(--muted);}
        .poster-ph i{font-size:3rem;opacity:.25;}

        /* Info panel */
        .genre-pill{display:inline-block;padding:4px 12px;border-radius:100px;font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;background:rgba(232,184,75,.12);border:1px solid rgba(232,184,75,.28);color:var(--accent);margin-bottom:14px;}
        .movie-title{font-family:'Syne',sans-serif;font-size:2.4rem;font-weight:800;letter-spacing:-.03em;line-height:1.1;margin-bottom:10px;}
        .movie-meta{color:var(--muted);font-size:.9rem;margin-bottom:16px;display:flex;align-items:center;gap:14px;flex-wrap:wrap;}
        .movie-meta i{color:var(--accent);}
        .stars-row{display:flex;align-items:center;gap:10px;margin-bottom:24px;}
        .stars{color:var(--accent);font-size:1.15rem;letter-spacing:2px;}
        .stars-count{color:var(--muted);font-size:.82rem;}

        .info-card{background:var(--surface);border:1px solid var(--border);border-radius:18px;padding:24px;margin-bottom:20px;}
        .info-card p{color:rgba(255,255,255,.75);line-height:1.75;font-size:.92rem;}
        .info-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;padding-top:20px;margin-top:20px;border-top:1px solid var(--border);}
        .info-stat label{font-size:.68rem;color:var(--muted);text-transform:uppercase;letter-spacing:.08em;display:block;margin-bottom:6px;}
        .info-stat strong{font-family:'Syne',sans-serif;font-size:1.1rem;font-weight:700;}
        .info-stat.accent strong{color:var(--accent);font-size:1.4rem;}

        /* Rent box */
        .rent-card{background:var(--surface);border:1px solid rgba(232,184,75,.18);border-radius:18px;padding:24px;margin-bottom:20px;}
        .rent-card h5{font-family:'Syne',sans-serif;font-size:1rem;font-weight:700;margin-bottom:18px;display:flex;align-items:center;gap:8px;}
        .rent-card h5 i{color:var(--accent);}
        .select-days{width:100%;background:var(--surface2);border:1px solid var(--border);border-radius:10px;padding:12px 16px;color:var(--text);font-family:'DM Sans',sans-serif;font-size:.9rem;margin-bottom:14px;outline:none;transition:border-color .2s;}
        .select-days:focus{border-color:var(--accent);}
        .btn-rent{width:100%;background:var(--accent);color:#000;border:none;border-radius:12px;padding:13px;font-family:'Syne',sans-serif;font-weight:700;font-size:.95rem;cursor:pointer;transition:all .25s;display:flex;align-items:center;justify-content:center;gap:8px;}
        .btn-rent:hover{background:#f0c75a;transform:translateY(-2px);box-shadow:0 8px 24px rgba(232,184,75,.35);}
        .unavail{background:rgba(245,158,11,.08);border:1px solid rgba(245,158,11,.2);border-radius:12px;padding:16px;color:#fbbf24;font-size:.88rem;display:flex;align-items:center;gap:10px;}

        /* Action links */
        .action-links{display:flex;flex-wrap:wrap;gap:10px;margin-top:4px;}
        .action-link{display:inline-flex;align-items:center;gap:8px;background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:10px 16px;color:var(--muted);text-decoration:none;font-size:.84rem;transition:all .2s;}
        .action-link:hover{border-color:rgba(232,184,75,.3);color:var(--accent);}

        /* Alerts */
        .flash{border-radius:12px;padding:13px 16px;font-size:.86rem;margin:20px 36px 0;display:flex;align-items:center;gap:10px;}
        .flash-ok{background:rgba(34,197,94,.1);border:1px solid rgba(34,197,94,.25);color:#86efac;}
        .flash-err{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.25);color:#fca5a5;}

        @media(max-width:900px){
            .sidebar{width:56px;}.main{margin-left:56px;}
            .detail-grid{grid-template-columns:1fr;}.content{padding:0 20px 60px;}
            .topbar{padding:0 18px;}.poster-wrap{max-width:260px;margin:0 auto;}
        }
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="logo-mark">CR</div>
    <a href="${pageContext.request.contextPath}/" class="nav-link"><i class="fas fa-house"></i><span>Home</span></a>
    <a href="${pageContext.request.contextPath}/movies" class="nav-link active"><i class="fas fa-film"></i><span>Movies</span></a>
    <% if (uname != null) { %>
    <a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="fas fa-chart-line"></i><span>Dashboard</span></a>
    <% } %>
    <a href="${pageContext.request.contextPath}/reviews" class="nav-link"><i class="fas fa-star"></i><span>Reviews</span></a>
    <div class="sidebar-bottom">
        <% if (uname != null) { %>
        <a href="${pageContext.request.contextPath}/profile" class="nav-link"><i class="fas fa-user-circle"></i><span><%= uname %></span></a>
        <a href="${pageContext.request.contextPath}/logout" class="nav-link" style="color:#ef4444"><i class="fas fa-arrow-right-from-bracket"></i><span>Logout</span></a>
        <% } else { %>
        <a href="${pageContext.request.contextPath}/pages/login.jsp" class="nav-link"><i class="fas fa-right-to-bracket"></i><span>Sign In</span></a>
        <% } %>
    </div>
</aside>

<div class="main">
    <header class="topbar">
        <div class="page-title">
            <span style="color:var(--muted)">Movies</span><span class="bc-sep">/</span><%= movie.getTitle() %>
        </div>
        <div class="topbar-right">
            <% if (uname != null) { %>
            <a href="${pageContext.request.contextPath}/profile" class="chip">
                <div class="user-av"><%= uname.substring(0,1).toUpperCase() %></div><%= uname %>
            </a>
            <% } else { %>
            <a href="${pageContext.request.contextPath}/pages/login.jsp" class="chip">Sign In</a>
            <% } %>
        </div>
    </header>

    <% if (flashSuccess != null) { %><div class="flash flash-ok"><i class="fas fa-circle-check"></i><%= flashSuccess %></div><% } %>
    <% if (flashError   != null) { %><div class="flash flash-err"><i class="fas fa-circle-exclamation"></i><%= flashError %></div><% } %>

    <!-- Hero backdrop -->
    <% if (!posterUrl.isEmpty()) { %>
    <div class="hero-back"><img src="<%= posterUrl %>" alt=""><div class="hero-back-grad"></div></div>
    <% } else { %><div class="hero-back-empty"></div><% } %>

    <div class="content">
        <div class="detail-grid">

            <!-- Poster -->
            <div>
                <div class="poster-wrap">
                    <% if (!posterUrl.isEmpty()) { %>
                    <img src="<%= posterUrl %>" alt="<%= movie.getTitle() %>">
                    <% } else { %>
                    <div class="poster-ph"><i class="fas fa-clapperboard"></i><span style="font-size:.8rem">No poster</span></div>
                    <% } %>
                </div>
            </div>

            <!-- Info -->
            <div>
                <span class="genre-pill"><%= movie.getGenre() %></span>
                <h1 class="movie-title"><%= movie.getTitle() %></h1>
                <div class="movie-meta">
                    <span><i class="fas fa-user-tie"></i> <%= movie.getDirector() %></span>
                    <span><i class="fas fa-calendar"></i> <%= movie.getReleaseYear() %></span>
                </div>
                <div class="stars-row">
                    <span class="stars">
                        <% int f=(int)movie.getRating(); for(int i=0;i<f;i++){out.print("★");} for(int i=f;i<5;i++){out.print("☆");} %>
                    </span>
                    <span style="font-family:'Syne',sans-serif;font-weight:700;color:var(--accent)"><%= movie.getRating() %></span>
                    <span class="stars-count">(<%= movie.getTotalRatings() %> reviews)</span>
                </div>

                <!-- Description + stats -->
                <div class="info-card">
                    <p><%= (movie.getDescription() != null && !movie.getDescription().isEmpty()) ? movie.getDescription() : "No description available for this movie." %></p>
                    <div class="info-stats">
                        <div class="info-stat">
                            <label>Copies Available</label>
                            <strong style="color:<%= movie.getAvailableCopies()>0 ? "var(--green)" : "var(--red)" %>">
                                <%= movie.getAvailableCopies() %> / <%= movie.getTotalCopies() %>
                            </strong>
                        </div>
                        <div class="info-stat accent">
                            <label>Rental Price</label>
                            <strong>$<%= movie.getRentalPrice() %></strong>
                        </div>
                        <div class="info-stat">
                            <label>Rating</label>
                            <strong style="color:var(--accent)"><%= movie.getRating() %> / 5</strong>
                        </div>
                    </div>
                </div>

                <!-- Rent / Login -->
                <% if (userId != null) { %>
                    <% if (movie.isAvailable()) { %>
                    <div class="rent-card">
                        <h5><i class="fas fa-ticket"></i> Rent This Movie</h5>
                        <form action="${pageContext.request.contextPath}/rent" method="post">
                            <input type="hidden" name="movieId" value="<%= movie.getMovieId() %>">
                            <select name="days" class="select-days">
                                <option value="3">3 Days — $<%= movie.getRentalPrice() %></option>
                                <option value="5">5 Days — $<%= String.format("%.2f", movie.getRentalPrice() * 1.5) %></option>
                                <option value="7">7 Days — $<%= String.format("%.2f", movie.getRentalPrice() * 2) %></option>
                            </select>
                            <button type="submit" class="btn-rent"><i class="fas fa-play" style="font-size:.75rem"></i> Rent Now</button>
                        </form>
                    </div>
                    <% } else { %>
                    <div class="rent-card">
                        <h5><i class="fas fa-clock" style="color:#c9a84c"></i> Join the Waitlist</h5>
                        <p style="font-size:0.82rem;color:#9e9a91;margin-bottom:14px;">All copies are currently rented. Join the waitlist and the admin will process your request when a copy is returned.</p>
                        <form action="${pageContext.request.contextPath}/rent" method="post">
                            <input type="hidden" name="movieId" value="<%= movie.getMovieId() %>">
                            <select name="days" class="select-days">
                                <option value="3">3 Days — $<%= movie.getRentalPrice() %></option>
                                <option value="5">5 Days — $<%= String.format("%.2f", movie.getRentalPrice() * 1.5) %></option>
                                <option value="7">7 Days — $<%= String.format("%.2f", movie.getRentalPrice() * 2) %></option>
                            </select>
                            <button type="submit" class="btn-rent" style="background:#2a2a1a;color:#c9a84c;border:1px solid rgba(201,168,76,0.4);">
                                <i class="fas fa-hourglass-half" style="font-size:.75rem"></i> Join Waitlist
                            </button>
                        </form>
                    </div>
                    <% } %>
                <% } else { %>
                <div class="rent-card">
                    <h5><i class="fas fa-lock"></i> Sign in to Rent</h5>
                    <a href="${pageContext.request.contextPath}/pages/login.jsp" class="btn-rent" style="text-decoration:none">
                        <i class="fas fa-right-to-bracket" style="font-size:.8rem"></i> Sign In to Rent
                    </a>
                </div>
                <% } %>

                <div class="action-links">
                    <a href="${pageContext.request.contextPath}/pages/reviews.jsp?movieId=<%= movie.getMovieId() %>" class="action-link">
                        <i class="fas fa-star" style="color:var(--accent)"></i> Read Reviews
                    </a>
                    <% if (userId != null) { %>
                    <a href="${pageContext.request.contextPath}/pages/add-review.jsp?movieId=<%= movie.getMovieId() %>" class="action-link">
                        <i class="fas fa-pen"></i> Write Review
                    </a>
                    <% } %>
                    <a href="${pageContext.request.contextPath}/movies" class="action-link">
                        <i class="fas fa-arrow-left"></i> Back to Movies
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
