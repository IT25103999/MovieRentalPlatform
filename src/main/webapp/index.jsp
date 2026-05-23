<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.dao.MovieDAO, com.movierental.model.Movie, java.util.List" %>
<%@ page import="com.movierental.utils.QueueManager" %>
<%
    String basePath = application.getInitParameter("data.path").replace("${user.home}", System.getProperty("user.home"));
    String dataPath = basePath + "movies.txt";
    MovieDAO movieDAO = new MovieDAO(dataPath);
    List<Movie> allMovies = movieDAO.getAllMovies();
    List<Movie> featured = QueueManager.insertionSortByRating(allMovies);
    if (featured.size() > 8) featured = featured.subList(0, 8);
    HttpSession sess = request.getSession(false);
    String username = (sess != null) ? (String) sess.getAttribute("username") : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineRent — Premium Movie Rental</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root{--bg:#080b12;--surface:#0f1420;--surface2:#161c2d;--border:rgba(255,255,255,0.07);--accent:#e8b84b;--accent2:#3b82f6;--red:#ef4444;--green:#22c55e;--text:#f1f5f9;--muted:#64748b;}
        *,*::before,*::after{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;overflow-x:hidden;}
        body::before{content:'';position:fixed;inset:0;z-index:0;background-image:url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.03'/%3E%3C/svg%3E");pointer-events:none;}

        /* Sidebar */
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
        .sidebar-bottom{margin-top:auto;width:100%;display:flex;flex-direction:column;align-items:center;gap:6px;}

        /* Main */
        .main{margin-left:72px;position:relative;z-index:1;}

        /* Topbar */
        .topbar{position:sticky;top:0;z-index:90;background:rgba(8,11,18,.85);backdrop-filter:blur(24px);border-bottom:1px solid var(--border);padding:0 36px;height:64px;display:flex;align-items:center;justify-content:space-between;}
        .topbar-brand{font-family:'Syne',sans-serif;font-weight:800;font-size:1.15rem;color:var(--accent);letter-spacing:-.01em;}
        .topbar-right{display:flex;align-items:center;gap:12px;}
        .chip{display:inline-flex;align-items:center;gap:8px;background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:7px 14px;font-size:.85rem;font-weight:500;text-decoration:none;color:var(--text);transition:all .2s;}
        .chip:hover{border-color:var(--accent);color:var(--accent);}
        .chip-accent{background:var(--accent);color:#000;border-color:var(--accent);}
        .chip-accent:hover{background:#f0c75a;color:#000;}
        .user-av{width:26px;height:26px;background:var(--accent);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;color:#000;}

        /* Hero */
        .hero{position:relative;min-height:88vh;display:flex;align-items:center;overflow:hidden;padding:0 36px;}
        .hero-bg{position:absolute;inset:0;background:radial-gradient(ellipse 70% 80% at 70% 50%,rgba(232,184,75,.06),transparent),radial-gradient(ellipse 60% 60% at 20% 30%,rgba(59,130,246,.05),transparent);}
        .hero-grid{position:absolute;inset:0;background-image:linear-gradient(rgba(255,255,255,.02) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.02) 1px,transparent 1px);background-size:60px 60px;mask-image:radial-gradient(ellipse 80% 80% at 50% 50%,black,transparent);}
        .hero-content{position:relative;z-index:2;max-width:700px;}
        .hero-eyebrow{display:inline-flex;align-items:center;gap:8px;background:rgba(232,184,75,.1);border:1px solid rgba(232,184,75,.25);border-radius:100px;padding:6px 16px;font-size:.75rem;font-weight:600;text-transform:uppercase;letter-spacing:.1em;color:var(--accent);margin-bottom:24px;}
        .hero-title{font-family:'Syne',sans-serif;font-size:clamp(2.4rem,5vw,4rem);font-weight:800;line-height:1.05;letter-spacing:-.03em;margin-bottom:20px;}
        .hero-title .line2{color:var(--accent);}
        .hero-sub{font-size:1.05rem;color:var(--muted);line-height:1.7;max-width:500px;margin-bottom:36px;}
        .hero-ctas{display:flex;gap:12px;flex-wrap:wrap; margin-bottom: 100px;}
        .btn-primary{display:inline-flex;align-items:center;gap:8px;background:var(--accent);color:#000;border:none;border-radius:12px;padding:14px 28px;font-size:.95rem;font-weight:700;font-family:'DM Sans',sans-serif;cursor:pointer;text-decoration:none;transition:all .25s;}
        .btn-primary:hover{background:#f0c75a;transform:translateY(-2px);box-shadow:0 12px 32px rgba(232,184,75,.3);}
        .btn-ghost{display:inline-flex;align-items:center;gap:8px;background:transparent;color:var(--text);border:1px solid var(--border);border-radius:12px;padding:14px 28px;font-size:.95rem;font-weight:500;text-decoration:none;transition:all .25s;}
        .btn-ghost:hover{border-color:rgba(255,255,255,.25);background:rgba(255,255,255,.04);}

        /* Stats */
        .hero-stats{position:absolute;bottom:48px;left:36px;right:36px;z-index:2;display:grid;grid-template-columns:repeat(3,1fr);gap:16px;max-width:520px;}
        .stat-pill{background:rgba(15,20,32,.8);border:1px solid var(--border);border-radius:16px;padding:18px 22px;backdrop-filter:blur(12px);}
        .stat-pill .val{font-family:'Syne',sans-serif;font-size:1.7rem;font-weight:800;color:var(--accent);}
        .stat-pill .lbl{font-size:.75rem;color:var(--muted);margin-top:2px;}

        /* Section */
        .section{padding:64px 36px;}
        .section-head{display:flex;align-items:baseline;justify-content:space-between;margin-bottom:32px;}
        .section-title{font-family:'Syne',sans-serif;font-size:1.5rem;font-weight:800;letter-spacing:-.02em;}
        .section-title .dot{color:var(--accent);}
        .see-all{font-size:.82rem;color:var(--muted);text-decoration:none;display:flex;align-items:center;gap:6px;transition:color .2s;}
        .see-all:hover{color:var(--accent);}

        /* Movie cards */
        .grid-movies{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:18px;}
        .mc{background:var(--surface);border:1px solid var(--border);border-radius:14px;overflow:hidden;cursor:pointer;transition:transform .25s,border-color .25s,box-shadow .25s;animation:cardIn .4s ease both;}
        .mc:hover{transform:translateY(-6px);border-color:rgba(232,184,75,.35);box-shadow:0 20px 40px rgba(0,0,0,.4);}
        @keyframes cardIn{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:translateY(0)}}
        .mc:nth-child(1){animation-delay:.03s}.mc:nth-child(2){animation-delay:.06s}.mc:nth-child(3){animation-delay:.09s}.mc:nth-child(4){animation-delay:.12s}.mc:nth-child(5){animation-delay:.15s}.mc:nth-child(6){animation-delay:.18s}.mc:nth-child(7){animation-delay:.21s}.mc:nth-child(8){animation-delay:.24s}
        .mc-poster{height:260px;background:var(--surface2);position:relative;overflow:hidden;}
        .mc-poster img{width:100%;height:100%;object-fit:cover;transition:transform .4s;}
        .mc:hover .mc-poster img{transform:scale(1.06);}
        .mc-ph{width:100%;height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;background:linear-gradient(135deg,#0f1420,#161c2d);}
        .mc-ph i{font-size:2.2rem;color:var(--muted);opacity:.3;}
        .mc-overlay{position:absolute;inset:0;background:linear-gradient(to top,rgba(8,11,18,.95) 0%,transparent 60%);opacity:0;transition:opacity .3s;}
        .mc:hover .mc-overlay{opacity:1;}
        .mc-genre{position:absolute;top:10px;left:10px;padding:3px 9px;border-radius:5px;font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:.07em;background:rgba(232,184,75,.15);border:1px solid rgba(232,184,75,.3);color:var(--accent);backdrop-filter:blur(8px);}
        .mc-body{padding:14px 16px 16px;}
        .mc-title{font-family:'Syne',sans-serif;font-weight:700;font-size:.88rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-bottom:3px;}
        .mc-meta{font-size:.72rem;color:var(--muted);margin-bottom:8px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
        .mc-foot{display:flex;align-items:center;justify-content:space-between;}
        .mc-price{font-family:'Syne',sans-serif;font-size:.95rem;font-weight:700;}
        .mc-stars{color:var(--accent);font-size:.7rem;}

        /* Genre grid */
        .genre-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:14px;}
        .genre-tile{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:22px 16px;display:flex;flex-direction:column;align-items:center;gap:10px;cursor:pointer;transition:all .25s;text-decoration:none;color:var(--text);}
        .genre-tile:hover{border-color:rgba(232,184,75,.4);background:rgba(232,184,75,.05);transform:translateY(-4px);}
        .genre-tile i{font-size:1.6rem;color:var(--accent);}
        .genre-tile span{font-family:'Syne',sans-serif;font-size:.85rem;font-weight:700;}

        /* CTA banner */
        .cta-banner{margin:0 36px 64px;background:var(--surface);border:1px solid rgba(232,184,75,.2);border-radius:24px;padding:48px;display:flex;align-items:center;justify-content:space-between;gap:24px;position:relative;overflow:hidden;}
        .cta-banner::before{content:'';position:absolute;top:-50%;right:-20%;width:500px;height:500px;border-radius:50%;background:radial-gradient(circle,rgba(232,184,75,.07),transparent);pointer-events:none;}
        .cta-banner h2{font-family:'Syne',sans-serif;font-size:1.8rem;font-weight:800;letter-spacing:-.02em;max-width:420px;}
        .cta-banner h2 em{color:var(--accent);font-style:normal;}

        /* Footer */
        .footer{background:var(--surface);border-top:1px solid var(--border);padding:28px 36px;display:flex;align-items:center;justify-content:space-between;}
        .footer p{font-size:.8rem;color:var(--muted);}

        @media(max-width:900px){.sidebar{width:56px;}.main{margin-left:56px;}.hero,.section,.cta-banner{padding-left:20px;padding-right:20px;}.hero-stats{grid-template-columns:repeat(3,1fr);left:20px;right:20px;}.cta-banner{flex-direction:column;}}
    </style>
</head>
<body>

<aside class="sidebar">
    <div class="logo-mark">CR</div>
    <a href="${pageContext.request.contextPath}/" class="nav-link active"><i class="fas fa-house"></i><span>Home</span></a>
    <a href="${pageContext.request.contextPath}/movies" class="nav-link"><i class="fas fa-film"></i><span>Movies</span></a>
    <% if (username != null) { %>
    <a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="fas fa-chart-line"></i><span>Dashboard</span></a>
    <% } %>
    <a href="${pageContext.request.contextPath}/reviews" class="nav-link"><i class="fas fa-star"></i><span>Reviews</span></a>
    <div class="sidebar-bottom">
        <% if (username != null) { %>
        <a href="${pageContext.request.contextPath}/profile" class="nav-link"><i class="fas fa-user-circle"></i><span><%= username %></span></a>
        <a href="${pageContext.request.contextPath}/logout" class="nav-link" style="color:#ef4444"><i class="fas fa-arrow-right-from-bracket"></i><span>Logout</span></a>
        <% } else { %>
        <a href="${pageContext.request.contextPath}/pages/login.jsp" class="nav-link"><i class="fas fa-right-to-bracket"></i><span>Sign In</span></a>
        <% } %>
    </div>
</aside>

<div class="main">
    <header class="topbar">
        <span class="topbar-brand">CineRent</span>
        <div class="topbar-right">
            <a href="${pageContext.request.contextPath}/movies" class="chip"><i class="fas fa-film" style="font-size:.75rem"></i> Browse</a>
            <% if (username != null) { %>
            <a href="${pageContext.request.contextPath}/profile" class="chip">
                <div class="user-av"><%= username.substring(0,1).toUpperCase() %></div>
                <%= username %>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="chip" style="color:#ef4444;border-color:rgba(239,68,68,.25)">Logout</a>
            <% } else { %>
            <a href="${pageContext.request.contextPath}/pages/login.jsp" class="chip">Sign In</a>
            <a href="${pageContext.request.contextPath}/pages/register.jsp" class="chip chip-accent">Get Started</a>
            <% } %>
        </div>
    </header>

    <!-- Hero -->
    <section class="hero">
        <div class="hero-bg"></div>
        <div class="hero-grid"></div>
        <div class="hero-content">
            <div class="hero-eyebrow"><i class="fas fa-bolt"></i> Premium Movie Rentals</div>
            <h1 class="hero-title">
                Cinema at<br>
                <span class="line2">Your Fingertips.</span>
            </h1>
            <p class="hero-sub">Rent the world's finest films — from timeless classics to this season's blockbusters. Stream instantly, return never.</p>
            <div class="hero-ctas">
                <a href="${pageContext.request.contextPath}/movies" class="btn-primary">
                    <i class="fas fa-play" style="font-size:.75rem"></i> Start Watching
                </a>
                <% if (username == null) { %>
                <a href="${pageContext.request.contextPath}/pages/register.jsp" class="btn-ghost">
                    Create Free Account <i class="fas fa-arrow-right" style="font-size:.75rem"></i>
                </a>
                <% } %>
            </div>
        </div>
        <div class="hero-stats">
            <div class="stat-pill"><div class="val"><%= allMovies.size() %>+</div><div class="lbl">Movies</div></div>
            <div class="stat-pill"><div class="val">4K</div><div class="lbl">Ultra HD</div></div>
            <div class="stat-pill"><div class="val">24/7</div><div class="lbl">Support</div></div>
        </div>
    </section>

    <!-- Featured -->
    <section class="section">
        <div class="section-head">
            <h2 class="section-title">Trending Now<span class="dot">.</span></h2>
            <a href="${pageContext.request.contextPath}/movies" class="see-all">View all <i class="fas fa-arrow-right" style="font-size:.7rem"></i></a>
        </div>
        <div class="grid-movies">
        <%
            for (Movie movie : featured) {
                String posterUrl = movie.getPosterUrlOrDefault();
        %>
        <div class="mc" onclick="location.href='${pageContext.request.contextPath}/movies/<%= movie.getMovieId() %>'">
            <div class="mc-poster">
                <% if (!posterUrl.isEmpty()) { %><img src="<%= posterUrl %>" alt="<%= movie.getTitle() %>" loading="lazy">
                <% } else { %><div class="mc-ph"><i class="fas fa-clapperboard"></i></div><% } %>
                <div class="mc-overlay"></div>
                <span class="mc-genre"><%= movie.getGenre() %></span>
            </div>
            <div class="mc-body">
                <div class="mc-title"><%= movie.getTitle() %></div>
                <div class="mc-meta"><%= movie.getDirector() %> · <%= movie.getReleaseYear() %></div>
                <div class="mc-foot">
                    <div class="mc-price">$<%= movie.getRentalPrice() %></div>
                    <div class="mc-stars">
                        <% int f=(int)movie.getRating(); for(int i=0;i<f;i++){out.print("★");} for(int i=f;i<5;i++){out.print("☆");} %>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
        </div>
    </section>

    <!-- Genres -->
    <section class="section" style="padding-top:0">
        <div class="section-head">
            <h2 class="section-title">Browse by Genre<span class="dot">.</span></h2>
        </div>
        <div class="genre-grid">
            <a href="${pageContext.request.contextPath}/movies?genre=Action" class="genre-tile"><i class="fas fa-bolt"></i><span>Action</span></a>
            <a href="${pageContext.request.contextPath}/movies?genre=Sci-Fi" class="genre-tile"><i class="fas fa-rocket"></i><span>Sci-Fi</span></a>
            <a href="${pageContext.request.contextPath}/movies?genre=Drama" class="genre-tile"><i class="fas fa-masks-theater"></i><span>Drama</span></a>
            <a href="${pageContext.request.contextPath}/movies?genre=Comedy" class="genre-tile"><i class="fas fa-face-laugh"></i><span>Comedy</span></a>
            <a href="${pageContext.request.contextPath}/movies?genre=Thriller" class="genre-tile"><i class="fas fa-eye"></i><span>Thriller</span></a>
            <a href="${pageContext.request.contextPath}/movies?genre=Crime" class="genre-tile"><i class="fas fa-handcuffs"></i><span>Crime</span></a>
        </div>
    </section>

    <!-- CTA -->
    <% if (username == null) { %>
    <div class="cta-banner">
        <h2>Ready to watch something <em>great?</em></h2>
        <a href="${pageContext.request.contextPath}/pages/register.jsp" class="btn-primary" style="white-space:nowrap">
            <i class="fas fa-user-plus" style="font-size:.75rem"></i> Join Free Today
        </a>
    </div>
    <% } %>

    <footer class="footer">
        <p>© 2024 CineRent — Premium Movie Rental Platform</p>
        <p style="font-size:.75rem;color:var(--muted)">Built with ❤️ for film lovers</p>
    </footer>
</div>
</body>
</html>
