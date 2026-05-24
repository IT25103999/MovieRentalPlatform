<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.dao.ReviewDAO, com.movierental.dao.MovieDAO" %>
<%@ page import="com.movierental.model.Review, com.movierental.model.Movie, java.util.List" %>
<%
    String basePath = application.getInitParameter("data.path").replace("${user.home}", System.getProperty("user.home"));
    MovieDAO movieDAO = new MovieDAO(basePath + "movies.txt");
    ReviewDAO reviewDAO = new ReviewDAO(basePath + "reviews.txt", movieDAO);

    List<Review> allReviews = reviewDAO.getAllReviews();
    List<Movie> allMovies = movieDAO.getAllMovies();

    HttpSession s = request.getSession(false);
    String username = (s != null) ? (String) s.getAttribute("username") : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reviews - CineRent</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root{--bg:#080b12;--surface:#0f1420;--surface2:#161c2d;--border:rgba(255,255,255,0.07);--accent:#e8b84b;--text:#f1f5f9;--muted:#64748b;}
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;}
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
        .main{margin-left:72px;padding:48px 40px;}
        .page-title{font-family:'Syne',sans-serif;font-size:2rem;font-weight:800;margin-bottom:4px;}
        .page-title span{color:var(--accent);}
        .page-sub{color:var(--muted);font-size:.9rem;margin-bottom:32px;}
        .stats-row{display:flex;gap:16px;margin-bottom:36px;flex-wrap:wrap;}
        .stat-card{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:18px 24px;flex:1;min-width:140px;}
        .stat-card .num{font-family:'Syne',sans-serif;font-size:1.8rem;font-weight:800;color:var(--accent);}
        .stat-card .label{color:var(--muted);font-size:.8rem;margin-top:2px;}
        .reviews-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:20px;}
        .review-card{background:var(--surface);border:1px solid var(--border);border-radius:16px;padding:22px;transition:border-color .2s;}
        .review-card:hover{border-color:rgba(232,184,75,.3);}
        .review-movie{display:flex;align-items:center;gap:12px;margin-bottom:14px;}
        .movie-thumb{width:44px;height:62px;border-radius:8px;object-fit:cover;flex-shrink:0;background:var(--surface2);}
        .movie-info .title{font-weight:600;font-size:.95rem;color:var(--text);text-decoration:none;}
        .movie-info .title:hover{color:var(--accent);}
        .movie-info .genre{color:var(--muted);font-size:.78rem;margin-top:2px;}
        .stars{color:var(--accent);font-size:.85rem;letter-spacing:1px;margin-bottom:10px;}
        .stars .empty{color:rgba(255,255,255,.15);}
        .review-comment{color:rgba(255,255,255,.75);font-size:.88rem;line-height:1.6;margin-bottom:14px;}
        .review-footer{display:flex;align-items:center;justify-content:space-between;}
        .reviewer{display:flex;align-items:center;gap:8px;}
        .avatar{width:28px;height:28px;border-radius:50%;background:rgba(232,184,75,.2);display:flex;align-items:center;justify-content:center;font-size:.75rem;font-weight:700;color:var(--accent);}
        .reviewer-name{font-size:.82rem;color:var(--muted);}
        .review-date{font-size:.78rem;color:var(--muted);}
        .empty-state{text-align:center;padding:80px 20px;color:var(--muted);}
        .empty-state i{font-size:3rem;margin-bottom:16px;display:block;opacity:.3;}
        @media(max-width:900px){.main{margin-left:56px;padding:28px 20px;}.reviews-grid{grid-template-columns:1fr;}}
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="logo-mark">CR</div>
    <a href="${pageContext.request.contextPath}/" class="nav-link"><i class="fas fa-house"></i><span>Home</span></a>
    <a href="${pageContext.request.contextPath}/movies" class="nav-link"><i class="fas fa-film"></i><span>Movies</span></a>
    <% if (username != null) { %>
    <a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="fas fa-chart-line"></i><span>Dashboard</span></a>
    <% } %>
    <a href="${pageContext.request.contextPath}/reviews" class="nav-link active"><i class="fas fa-star"></i><span>Reviews</span></a>
    <div class="sidebar-bottom">
        <% if (username != null) { %>
        <a href="${pageContext.request.contextPath}/profile" class="nav-link"><i class="fas fa-user-circle"></i><span><%= username %></span></a>
        <a href="${pageContext.request.contextPath}/logout" class="nav-link" style="color:#ef4444"><i class="fas fa-arrow-right-from-bracket"></i><span>Logout</span></a>
        <% } else { %>
        <a href="${pageContext.request.contextPath}/pages/login.jsp" class="nav-link"><i class="fas fa-right-to-bracket"></i><span>Sign In</span></a>
        <% } %>
    </div>
</aside>

<main class="main">
    <h1 class="page-title">Community <span>Reviews</span></h1>
    <p class="page-sub">What our members are saying about the films they've watched</p>

    <%
        int totalReviews = allReviews.size();
        double totalRating = 0;
        for (Review r : allReviews) totalRating += r.getRating();
        double avgRating = totalReviews > 0 ? totalRating / totalReviews : 0;
        long fiveStars = allReviews.stream().filter(r -> r.getRating() == 5).count();
    %>

    <div class="stats-row">
        <div class="stat-card">
            <div class="num"><%= totalReviews %></div>
            <div class="label">Total Reviews</div>
        </div>
        <div class="stat-card">
            <div class="num"><%= String.format("%.1f", avgRating) %></div>
            <div class="label">Avg Rating</div>
        </div>
        <div class="stat-card">
            <div class="num"><%= fiveStars %></div>
            <div class="label">5-Star Reviews</div>
        </div>
        <div class="stat-card">
            <div class="num"><%= allMovies.size() %></div>
            <div class="label">Movies Available</div>
        </div>
    </div>

    <% if (allReviews.isEmpty()) { %>
    <div class="empty-state">
        <i class="fas fa-star"></i>
        <p>No reviews yet. Be the first to review a movie!</p>
    </div>
    <% } else { %>
    <div class="reviews-grid">
        <% for (Review review : allReviews) {
            Movie m = movieDAO.getMovieById(review.getMovieId());
            String movieTitle = (m != null) ? m.getTitle() : "Unknown Movie";
            String movieGenre = (m != null) ? m.getGenre() : "";
            String movieImg   = (m != null) ? m.getPosterUrl() : "";
            String movieId    = review.getMovieId();
        %>
        <div class="review-card">
            <div class="review-movie">
                <% if (movieImg != null && !movieImg.isEmpty()) { %>
                <img src="<%= movieImg %>" alt="<%= movieTitle %>" class="movie-thumb">
                <% } else { %>
                <div class="movie-thumb" style="display:flex;align-items:center;justify-content:center;"><i class="fas fa-film" style="color:var(--muted)"></i></div>
                <% } %>
                <div class="movie-info">
                    <a href="${pageContext.request.contextPath}/movies/<%= movieId %>" class="title"><%= movieTitle %></a>
                    <div class="genre"><%= movieGenre %></div>
                </div>
            </div>
            <div class="stars">
                <% for (int i = 1; i <= 5; i++) { %>
                    <% if (i <= review.getRating()) { %><i class="fas fa-star"></i><% } else { %><i class="far fa-star empty"></i><% } %>
                <% } %>
            </div>
            <div class="review-comment">"<%= review.getComment() %>"</div>
            <div class="review-footer">
                <div class="reviewer">
                    <div class="avatar"><%= review.getUsername().substring(0,1).toUpperCase() %></div>
                    <span class="reviewer-name">@<%= review.getUsername() %></span>
                </div>
                <span class="review-date"><%= review.getReviewDate() != null ? review.getReviewDate().toString() : "" %></span>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</main>
</body>
</html>
