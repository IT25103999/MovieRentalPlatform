<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.dao.MovieDAO, com.movierental.model.Movie" %>
<%
    String movieId = request.getParameter("movieId");
    if (movieId == null || movieId.isEmpty()) { response.sendRedirect("movies.jsp"); return; }
    String basePath = application.getInitParameter("data.path").replace("${user.home}", System.getProperty("user.home"));
    String moviePath = basePath + "movies.txt";
    MovieDAO movieDAO = new MovieDAO(moviePath);
    Movie movie = movieDAO.getMovieById(movieId);
    HttpSession s = request.getSession(false);
    String userId   = (s != null) ? (String) s.getAttribute("userId")   : null;
    String username = (s != null) ? (String) s.getAttribute("username") : null;
    if (userId == null) { response.sendRedirect("login.jsp"); return; }
    String error = request.getParameter("error");
    String posterUrl = "";
    if (movie != null) {
        posterUrl = movie.getPosterUrl() != null ? movie.getPosterUrl() : "";
        if (posterUrl.isEmpty()) {
            String t = movie.getTitle();
            if (t.equals("Inception"))           posterUrl = "https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg";
            else if (t.equals("The Dark Knight")) posterUrl = "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg";
            else if (t.equals("Interstellar"))   posterUrl = "https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg";
            else if (t.equals("Parasite"))       posterUrl = "https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg";
            else if (t.equals("The Godfather"))  posterUrl = "https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsLMd14iZLcb9.jpg";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Write Review — CineRent</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root{--bg:#080b12;--surface:#0f1420;--surface2:#161c2d;--border:rgba(255,255,255,0.07);--accent:#e8b84b;--text:#f1f5f9;--muted:#64748b;}
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
        .sidebar-bottom{margin-top:auto;width:100%;display:flex;flex-direction:column;gap:6px;}

        .main{margin-left:72px;position:relative;z-index:1;min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:48px 24px;}

        /* Movie mini-card at top */
        .movie-context{display:flex;align-items:center;gap:16px;background:var(--surface);border:1px solid var(--border);border-radius:16px;padding:16px 20px;width:100%;max-width:560px;margin-bottom:28px;}
        .ctx-poster{width:52px;height:70px;border-radius:10px;overflow:hidden;background:var(--surface2);flex-shrink:0;}
        .ctx-poster img{width:100%;height:100%;object-fit:cover;}
        .ctx-ph{width:100%;height:100%;display:flex;align-items:center;justify-content:center;color:var(--muted);opacity:.4;}
        .ctx-info{}
        .ctx-label{font-size:.68rem;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin-bottom:4px;}
        .ctx-title{font-family:'Syne',sans-serif;font-weight:700;font-size:1rem;}
        .ctx-meta{font-size:.78rem;color:var(--muted);margin-top:3px;}

        /* Form panel */
        .panel{background:var(--surface);border:1px solid var(--border);border-radius:22px;padding:38px;width:100%;max-width:560px;box-shadow:0 40px 80px rgba(0,0,0,.4),inset 0 1px 0 rgba(255,255,255,.04);animation:up .5s cubic-bezier(.16,1,.3,1);}
        @keyframes up{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)}}
        .panel-icon{width:52px;height:52px;background:rgba(232,184,75,.12);border:1px solid rgba(232,184,75,.25);border-radius:14px;display:flex;align-items:center;justify-content:center;margin:0 auto 18px;font-size:1.4rem;color:var(--accent);}
        .panel-title{font-family:'Syne',sans-serif;font-size:1.3rem;font-weight:700;text-align:center;margin-bottom:6px;}
        .panel-sub{text-align:center;color:var(--muted);font-size:.85rem;margin-bottom:30px;}
        .panel-sub strong{color:var(--text);}

        /* Star rating */
        .star-section label.sec-label{font-size:.72rem;color:var(--muted);text-transform:uppercase;letter-spacing:.08em;display:block;margin-bottom:14px;}
        .star-rating{direction:rtl;display:flex;justify-content:center;gap:6px;margin-bottom:28px;}
        .star-rating input{display:none;}
        .star-rating label{font-size:48px;color:rgba(255,255,255,.12);cursor:pointer;transition:color .15s,transform .15s;line-height:1;}
        .star-rating label:hover,.star-rating label:hover ~ label,.star-rating input:checked ~ label{color:var(--accent);}
        .star-rating label:hover{transform:scale(1.15);}

        /* Selected label */
        .rating-hint{text-align:center;font-size:.82rem;color:var(--muted);margin-bottom:24px;min-height:20px;transition:all .2s;}

        /* Textarea */
        .field-label{font-size:.72rem;color:var(--muted);text-transform:uppercase;letter-spacing:.08em;display:block;margin-bottom:8px;}
        .textarea{width:100%;background:var(--surface2);border:1px solid rgba(255,255,255,.06);border-radius:12px;padding:14px 16px;color:var(--text);font-family:'DM Sans',sans-serif;font-size:.92rem;resize:vertical;min-height:130px;transition:border-color .2s,box-shadow .2s;outline:none;margin-bottom:20px;}
        .textarea:focus{border-color:var(--accent);box-shadow:0 0 0 3px rgba(232,184,75,.1);}
        .textarea::placeholder{color:rgba(255,255,255,.2);}
        .char-count{font-size:.72rem;color:var(--muted);text-align:right;margin-top:-16px;margin-bottom:20px;}

        .btn-submit{width:100%;background:var(--accent);color:#000;border:none;border-radius:12px;padding:14px;font-family:'Syne',sans-serif;font-weight:700;font-size:.95rem;cursor:pointer;transition:all .25s;display:flex;align-items:center;justify-content:center;gap:8px;}
        .btn-submit:hover{background:#f0c75a;transform:translateY(-2px);box-shadow:0 8px 24px rgba(232,184,75,.35);}

        .back-link{display:block;text-align:center;margin-top:16px;color:var(--muted);text-decoration:none;font-size:.85rem;transition:color .2s;}
        .back-link:hover{color:var(--accent);}

        .alert-err{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.25);border-radius:10px;padding:11px 14px;color:#fca5a5;font-size:.84rem;margin-bottom:18px;display:flex;align-items:center;gap:8px;}
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="logo-mark">CR</div>
    <a href="${pageContext.request.contextPath}/" class="nav-link"><i class="fas fa-house"></i><span>Home</span></a>
    <a href="${pageContext.request.contextPath}/movies" class="nav-link"><i class="fas fa-film"></i><span>Movies</span></a>
    <a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="fas fa-chart-line"></i><span>Dashboard</span></a>
    <a href="${pageContext.request.contextPath}/reviews" class="nav-link"><i class="fas fa-star"></i><span>Reviews</span></a>
    <div class="sidebar-bottom">
        <a href="${pageContext.request.contextPath}/profile" class="nav-link"><i class="fas fa-user-circle"></i><span><%= username %></span></a>
        <a href="${pageContext.request.contextPath}/logout" class="nav-link" style="color:#ef4444"><i class="fas fa-arrow-right-from-bracket"></i><span>Logout</span></a>
    </div>
</aside>

<div class="main">
    <!-- Movie context card -->
    <% if (movie != null) { %>
    <div class="movie-context">
        <div class="ctx-poster">
            <% if (!posterUrl.isEmpty()) { %><img src="<%= posterUrl %>" alt="">
            <% } else { %><div class="ctx-ph"><i class="fas fa-film"></i></div><% } %>
        </div>
        <div class="ctx-info">
            <div class="ctx-label">Reviewing</div>
            <div class="ctx-title"><%= movie.getTitle() %></div>
            <div class="ctx-meta"><%= movie.getDirector() %> · <%= movie.getReleaseYear() %></div>
        </div>
    </div>
    <% } %>

    <div class="panel">
        <div class="panel-icon"><i class="fas fa-pen-to-square"></i></div>
        <div class="panel-title">Write a Review</div>
        <p class="panel-sub">Share your thoughts on <strong><%= movie != null ? movie.getTitle() : "this movie" %></strong></p>

        <% if (error != null) { %><div class="alert-err"><i class="fas fa-circle-exclamation"></i><%= error %></div><% } %>

        <form action="${pageContext.request.contextPath}/review/add" method="post">
            <input type="hidden" name="movieId" value="<%= movieId %>">

            <div class="star-section">
                <label class="sec-label">Your Rating</label>
                <div class="star-rating" id="starRating">
                    <input type="radio" name="rating" value="5" id="s5"><label for="s5" title="Excellent">★</label>
                    <input type="radio" name="rating" value="4" id="s4"><label for="s4" title="Good">★</label>
                    <input type="radio" name="rating" value="3" id="s3"><label for="s3" title="Average">★</label>
                    <input type="radio" name="rating" value="2" id="s2"><label for="s2" title="Poor">★</label>
                    <input type="radio" name="rating" value="1" id="s1" checked><label for="s1" title="Terrible">★</label>
                </div>
                <div class="rating-hint" id="ratingHint">⭐ Terrible</div>
            </div>

            <label class="field-label">Your Review</label>
            <textarea name="comment" class="textarea" id="reviewText" rows="5"
                placeholder="What did you think about this film? Be honest and specific…" required
                oninput="updateCount()"></textarea>
            <div class="char-count" id="charCount">0 / 500</div>

            <button type="submit" class="btn-submit">
                <i class="fas fa-paper-plane" style="font-size:.8rem"></i> Submit Review
            </button>
        </form>
        <a href="${pageContext.request.contextPath}/movies/<%= movieId %>" class="back-link">
            <i class="fas fa-arrow-left" style="margin-right:5px"></i> Back to Movie
        </a>
    </div>
</div>

<script>
    const labels = ['','⭐ Terrible','⭐⭐ Poor','⭐⭐⭐ Average','⭐⭐⭐⭐ Good','⭐⭐⭐⭐⭐ Excellent'];
    document.querySelectorAll('#starRating input').forEach(r => {
        r.addEventListener('change', () => {
            document.getElementById('ratingHint').textContent = labels[r.value] || '';
        });
    });
    function updateCount(){
        const t = document.getElementById('reviewText');
        const c = document.getElementById('charCount');
        c.textContent = Math.min(t.value.length, 500) + ' / 500';
        if (t.value.length > 500) { t.value = t.value.substring(0,500); }
    }
</script>
</body>
</html>
