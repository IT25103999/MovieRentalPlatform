<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.dao.ReviewDAO, com.movierental.dao.MovieDAO" %>
<%@ page import="com.movierental.model.Review, com.movierental.model.Movie, java.util.List" %>
<%
    String movieId = request.getParameter("movieId");
    if (movieId == null || movieId.isEmpty()) {
        response.sendRedirect("movies.jsp");
        return;
    }

    String basePath = application.getInitParameter("data.path").replace("${user.home}", System.getProperty("user.home"));
    String moviePath = basePath + "movies.txt";
    String reviewPath = basePath + "reviews.txt";

    MovieDAO movieDAO = new MovieDAO(moviePath);
    ReviewDAO reviewDAO = new ReviewDAO(reviewPath, movieDAO);

    Movie movie = movieDAO.getMovieById(movieId);
    List<Review> reviews = reviewDAO.getReviewsByMovie(movieId);
    double avgRating = reviewDAO.getAverageRating(movieId);

    HttpSession s = request.getSession(false);
    String userId = (s != null) ? (String) s.getAttribute("userId") : null;
    String username = (s != null) ? (String) s.getAttribute("username") : null;
    boolean hasReviewed = (userId != null) && reviewDAO.hasUserReviewed(userId, movieId);

    // Read and clear flash messages
    String flashSuccess = (s != null) ? (String) s.getAttribute("success") : null;
    String flashError   = (s != null) ? (String) s.getAttribute("error")   : null;
    if (flashSuccess != null) s.removeAttribute("success");
    if (flashError   != null) s.removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reviews - <%= movie != null ? movie.getTitle() : "Movie" %> - CineRent</title>
    <%-- FIX: Bootstrap version unified to 5.3.2 (was 5.1.3) --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root{--gold:#c9a84c;--gold-light:#e8c97e;--dark:#080810;--dark-card:#0e0e1a;--dark-surface:#12121f;--border:rgba(255,255,255,0.07);--muted:rgba(255,255,255,0.45);}
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'DM Sans',sans-serif;background:var(--dark);color:#fff;min-height:100vh;}
        .navbar{background:rgba(8,8,16,0.96);backdrop-filter:blur(20px);padding:1rem 0;border-bottom:1px solid rgba(201,168,76,0.15);}
        .navbar-brand{font-family:'Playfair Display',serif;font-size:1.5rem;font-weight:900;color:var(--gold)!important;text-decoration:none;}
        .navbar-brand i{margin-right:6px;}
        .btn-nav-outline{background:transparent;border:1px solid rgba(201,168,76,0.4);padding:7px 18px;border-radius:8px;color:rgba(255,255,255,0.8);text-decoration:none;font-size:0.88rem;transition:all 0.2s;}
        .btn-nav-outline:hover{border-color:var(--gold);color:var(--gold);}
        .btn-nav-gold{background:linear-gradient(135deg,var(--gold),var(--gold-light));border:none;padding:7px 18px;border-radius:8px;color:#000;font-weight:600;font-size:0.88rem;text-decoration:none;transition:all 0.2s;}
        .page-header{padding:36px 0 24px;}
        .page-header h1{font-family:'Playfair Display',serif;font-size:2rem;font-weight:900;}
        .page-header h1 span{color:var(--gold);}
        .rating-summary{background:var(--dark-card);border:1px solid var(--border);border-radius:20px;padding:28px;text-align:center;margin-bottom:28px;border-top:3px solid var(--gold);}
        .avg-stars{color:var(--gold);font-size:2.4rem;margin:8px 0;}
        .avg-num{font-family:'Playfair Display',serif;font-size:2.5rem;font-weight:900;color:#fff;}
        .avg-sub{color:var(--muted);font-size:0.85rem;margin-top:4px;}
        .write-review-box{background:var(--dark-card);border:1px solid rgba(201,168,76,0.2);border-radius:16px;padding:24px;margin-bottom:24px;}
        .write-review-box h5{font-family:'Playfair Display',serif;font-size:1.1rem;margin-bottom:16px;}
        .star-rating{direction:rtl;display:inline-block;margin-bottom:12px;}
        .star-rating input{display:none;}
        .star-rating label{color:rgba(255,255,255,0.2);font-size:28px;padding:0 3px;cursor:pointer;transition:color 0.15s;}
        .star-rating label:hover,.star-rating label:hover ~ label,.star-rating input:checked ~ label{color:var(--gold);}
        .textarea-custom{background:var(--dark-surface);border:1px solid var(--border);border-radius:10px;padding:12px 14px;color:#fff;width:100%;font-family:'DM Sans',sans-serif;font-size:0.9rem;resize:vertical;min-height:90px;transition:border-color 0.2s;}
        .textarea-custom:focus{outline:none;border-color:var(--gold);}
        .textarea-custom::placeholder{color:rgba(255,255,255,0.2);}
        .btn-submit{background:linear-gradient(135deg,var(--gold),var(--gold-light));border:none;padding:11px 24px;border-radius:10px;font-weight:600;font-size:0.9rem;color:#000;cursor:pointer;transition:all 0.2s;}
        .btn-submit:hover{transform:translateY(-1px);box-shadow:0 6px 18px rgba(201,168,76,0.35);}
        .review-card{background:var(--dark-card);border:1px solid var(--border);border-radius:16px;padding:20px;margin-bottom:16px;transition:border-color 0.2s;}
        .review-card:hover{border-color:rgba(201,168,76,0.2);}
        .reviewer-name{font-weight:600;font-size:0.95rem;}
        .review-stars{color:var(--gold);font-size:0.9rem;margin:4px 0 10px;}
        .review-comment{color:rgba(255,255,255,0.8);line-height:1.6;font-size:0.9rem;}
        .review-date{color:var(--muted);font-size:0.78rem;margin-top:10px;}
        .btn-edit-rev{background:rgba(245,158,11,0.15);border:1px solid rgba(245,158,11,0.3);color:#fbbf24;padding:5px 12px;border-radius:7px;font-size:0.8rem;cursor:pointer;transition:all 0.2s;}
        .btn-edit-rev:hover{background:rgba(245,158,11,0.25);}
        .btn-del-rev{background:rgba(239,68,68,0.12);border:1px solid rgba(239,68,68,0.25);color:#fca5a5;padding:5px 12px;border-radius:7px;font-size:0.8rem;cursor:pointer;transition:all 0.2s;}
        .btn-del-rev:hover{background:rgba(239,68,68,0.2);}
        .back-btn{display:inline-flex;align-items:center;gap:8px;background:var(--dark-card);border:1px solid var(--border);border-radius:10px;padding:9px 18px;color:rgba(255,255,255,0.7);text-decoration:none;font-size:0.88rem;transition:all 0.2s;}
        .back-btn:hover{border-color:rgba(201,168,76,0.4);color:var(--gold);}
        .empty-reviews{text-align:center;padding:40px;color:var(--muted);}
        .empty-reviews i{font-size:2.5rem;margin-bottom:12px;opacity:0.4;}
        .modal-content{background:var(--dark-card);border:1px solid var(--border);}
        .modal-header{border-bottom:1px solid var(--border);}
        .modal-footer{border-top:1px solid var(--border);}
        .form-select{background:var(--dark-surface);border:1px solid var(--border);color:#fff;}
        .form-select:focus{background:var(--dark-surface);border-color:var(--gold);box-shadow:none;}
        .alert-info-custom{background:rgba(59,130,246,0.08);border:1px solid rgba(59,130,246,0.2);border-radius:10px;padding:12px 14px;color:rgba(147,197,253,0.9);font-size:0.86rem;margin-bottom:16px;}
    </style>
</head>
<body>
<nav class="navbar">
    <div class="container d-flex justify-content-between align-items-center">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/"><i class="fas fa-crown"></i>CineRent</a>
        <div class="d-flex gap-2">
            <% if (userId != null) { %>
                <a href="${pageContext.request.contextPath}/profile" class="btn-nav-outline">Profile</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-nav-gold">Logout</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/pages/login.jsp" class="btn-nav-outline">Login</a>
                <a href="${pageContext.request.contextPath}/pages/register.jsp" class="btn-nav-gold">Sign Up</a>
            <% } %>
        </div>
    </div>
</nav>

<div class="container">
    <div class="page-header d-flex justify-content-between align-items-center">
        <h1><span><%= movie != null ? movie.getTitle() : "Movie" %></span> Reviews</h1>
        <a href="${pageContext.request.contextPath}/movies/<%= movieId %>" class="back-btn"><i class="fas fa-arrow-left"></i>Back to Movie</a>
    </div>

    <% if (flashSuccess != null) { %>
        <div style="background:rgba(34,197,94,0.12);border:1px solid rgba(34,197,94,0.3);border-radius:10px;padding:12px 16px;color:#86efac;margin-bottom:16px;">
            <i class="fas fa-check-circle me-2"></i><%= flashSuccess %>
        </div>
    <% } %>
    <% if (flashError != null) { %>
        <div style="background:rgba(239,68,68,0.12);border:1px solid rgba(239,68,68,0.3);border-radius:10px;padding:12px 16px;color:#fca5a5;margin-bottom:16px;">
            <i class="fas fa-exclamation-circle me-2"></i><%= flashError %>
        </div>
    <% } %>

    <div class="row g-4">
        <div class="col-md-4">
            <div class="rating-summary">
                <div style="color:var(--muted);font-size:0.82rem;text-transform:uppercase;letter-spacing:0.05em;">Average Rating</div>
                <div class="avg-stars">
                    <% for(int i=0;i<(int)avgRating;i++){%>★<%}%><% for(int i=(int)avgRating;i<5;i++){%>☆<%}%>
                </div>
                <div class="avg-num"><%= String.format("%.1f", avgRating) %><span style="font-size:1.2rem;color:var(--muted)"> / 5.0</span></div>
                <div class="avg-sub"><%= reviews.size() %> review<%= reviews.size() != 1 ? "s" : "" %></div>
            </div>
        </div>

        <div class="col-md-8">
            <% if (userId != null && !hasReviewed && movie != null) { %>
                <div class="write-review-box">
                    <h5><i class="fas fa-pen me-2" style="color:var(--gold)"></i>Write a Review</h5>
                    <form action="${pageContext.request.contextPath}/review/add" method="post">
                        <input type="hidden" name="movieId" value="<%= movieId %>">
                        <div class="mb-3">
                            <div style="font-size:0.78rem;color:var(--muted);margin-bottom:6px;">YOUR RATING</div>
                            <div class="star-rating">
                                <input type="radio" name="rating" value="5" id="star5"><label for="star5">★</label>
                                <input type="radio" name="rating" value="4" id="star4"><label for="star4">★</label>
                                <input type="radio" name="rating" value="3" id="star3"><label for="star3">★</label>
                                <input type="radio" name="rating" value="2" id="star2"><label for="star2">★</label>
                                <input type="radio" name="rating" value="1" id="star1" checked><label for="star1">★</label>
                            </div>
                        </div>
                        <div class="mb-3">
                            <textarea name="comment" class="textarea-custom" rows="3" placeholder="Share your thoughts about this movie..." required></textarea>
                        </div>
                        <button type="submit" class="btn-submit"><i class="fas fa-paper-plane me-2"></i>Submit Review</button>
                    </form>
                </div>
            <% } else if (userId != null && hasReviewed) { %>
                <div class="alert-info-custom"><i class="fas fa-check-circle me-2"></i>You have already reviewed this movie.</div>
            <% } %>

            <h5 class="mb-3" style="font-family:'Playfair Display',serif;">All Reviews</h5>
            <% if (reviews.isEmpty()) { %>
                <div class="empty-reviews"><i class="fas fa-comment d-block"></i><p>No reviews yet. Be the first to review!</p></div>
            <% } else { %>
                <% for (Review review : reviews) { %>
                <div class="review-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div style="flex:1;">
                            <div class="reviewer-name"><i class="fas fa-user-circle me-2" style="color:var(--gold)"></i><%= review.getUsername() %></div>
                            <div class="review-stars"><%= review.getStarRating() %></div>
                            <div class="review-comment"><%= review.getComment() %></div>
                            <div class="review-date"><%= review.getFormattedDate() %><% if (review.isEdited()) { %> &bull; <em>edited</em><% } %></div>
                        </div>
                        <% if (userId != null && userId.equals(review.getUserId())) { %>
                        <div class="d-flex gap-2 ms-3 flex-shrink-0">
                            <button class="btn-edit-rev" onclick="editReview('<%= review.getReviewId() %>', <%= review.getRating() %>, '<%= review.getComment().replace("'", "\\'") %>')"><i class="fas fa-pen"></i></button>
                            <form action="${pageContext.request.contextPath}/review/delete" method="post" style="display:inline;">
                                <input type="hidden" name="reviewId" value="<%= review.getReviewId() %>">
                                <input type="hidden" name="movieId" value="<%= movieId %>">
                                <button type="submit" class="btn-del-rev" onclick="return confirm('Delete this review?')"><i class="fas fa-trash"></i></button>
                            </form>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } %>
            <% } %>
        </div>
    </div>
</div>

<!-- Edit Review Modal -->
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title">Edit Review</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <form id="editForm" action="${pageContext.request.contextPath}/review/edit" method="post">
                    <input type="hidden" name="reviewId" id="editReviewId">
                    <input type="hidden" name="movieId" value="<%= movieId %>">
                    <div class="mb-3"><label class="form-label" style="color:var(--muted);font-size:0.82rem;">RATING</label>
                        <select name="rating" id="editRating" class="form-select">
                            <option value="5">★★★★★ (5)</option><option value="4">★★★★☆ (4)</option>
                            <option value="3">★★★☆☆ (3)</option><option value="2">★★☆☆☆ (2)</option>
                            <option value="1">★☆☆☆☆ (1)</option>
                        </select>
                    </div>
                    <div class="mb-3"><label class="form-label" style="color:var(--muted);font-size:0.82rem;">COMMENT</label>
                        <textarea name="comment" id="editComment" class="textarea-custom" rows="3" required></textarea>
                    </div>
                    <button type="submit" class="btn-submit w-100">Save Changes</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function editReview(reviewId, rating, comment) {
        document.getElementById('editReviewId').value = reviewId;
        document.getElementById('editRating').value = rating;
        document.getElementById('editComment').value = comment;
        new bootstrap.Modal(document.getElementById('editModal')).show();
    }
</script>
<%-- FIX: Bootstrap JS version unified to 5.3.2 (was 5.1.3) --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
