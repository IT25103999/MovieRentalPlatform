<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.model.User, com.movierental.model.Rental, java.util.List" %>
<%
    User user = (User) request.getAttribute("user");
    List<Rental> rentals = (List<Rental>) request.getAttribute("rentals");
    HttpSession s = request.getSession(false);
    if (user == null || s == null) { response.sendRedirect("login.jsp"); return; }
    String success = (String) session.getAttribute("success");
    String error = (String) session.getAttribute("error");
    if (success != null) session.removeAttribute("success");
    if (error != null) session.removeAttribute("error");
    // FIX: safe date extraction — null-guard getRegDate() before calling toString()
    String regDate = "N/A";
    if (user.getRegDate() != null) {
        String regStr = user.getRegDate().toString();
        regDate = regStr.contains("T") ? regStr.split("T")[0] : regStr;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - CineRent</title>
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
        .btn-nav-gold:hover{transform:translateY(-1px);box-shadow:0 4px 16px rgba(201,168,76,0.35);}
        .profile-hero{background:linear-gradient(135deg,var(--dark-card),var(--dark-surface));border-bottom:1px solid var(--border);padding:40px 0 36px;}
        .avatar{width:72px;height:72px;background:linear-gradient(135deg,var(--gold),var(--gold-light));border-radius:20px;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:1.8rem;font-weight:900;color:#000;margin-bottom:14px;}
        .profile-hero h1{font-family:'Playfair Display',serif;font-size:1.8rem;font-weight:700;}
        .profile-hero p{color:var(--muted);font-size:0.88rem;margin-top:4px;}
        .card-section{background:var(--dark-card);border:1px solid var(--border);border-radius:18px;padding:24px;margin-bottom:20px;}
        .card-section h5{font-family:'Playfair Display',serif;font-size:1.05rem;font-weight:700;margin-bottom:18px;display:flex;align-items:center;gap:10px;}
        .card-section h5 i{color:var(--gold);}
        .form-label-custom{font-size:0.78rem;color:var(--muted);text-transform:uppercase;letter-spacing:0.05em;display:block;margin-bottom:6px;}
        .input-custom{background:var(--dark-surface);border:1px solid var(--border);border-radius:10px;padding:11px 14px;color:#fff;width:100%;font-family:'DM Sans',sans-serif;font-size:0.9rem;transition:border-color 0.2s;margin-bottom:14px;}
        .input-custom:focus{outline:none;border-color:var(--gold);}
        .input-custom::placeholder{color:rgba(255,255,255,0.25);}
        .btn-gold-full{background:linear-gradient(135deg,var(--gold),var(--gold-light));border:none;padding:11px;border-radius:10px;font-weight:600;font-size:0.9rem;width:100%;color:#000;cursor:pointer;transition:all 0.2s;font-family:'DM Sans',sans-serif;}
        .btn-gold-full:hover{transform:translateY(-1px);box-shadow:0 6px 18px rgba(201,168,76,0.35);}
        .btn-danger-full{background:rgba(220,38,38,0.12);border:1px solid rgba(220,38,38,0.25);padding:11px;border-radius:10px;font-weight:600;font-size:0.9rem;width:100%;color:#fca5a5;cursor:pointer;transition:all 0.2s;font-family:'DM Sans',sans-serif;}
        .btn-danger-full:hover{background:rgba(220,38,38,0.2);}
        .rental-item{background:var(--dark-surface);border-radius:12px;padding:14px 16px;margin-bottom:12px;border-left:3px solid #10b981;transition:all 0.2s;}
        .rental-item:hover{transform:translateX(4px);}
        .rental-overdue{border-left-color:#ef4444;}
        .rental-title{font-weight:600;font-size:0.9rem;}
        .rental-dates{color:var(--muted);font-size:0.78rem;margin-top:3px;}
        .badge-active{background:rgba(16,185,129,0.15);color:#34d399;border:1px solid rgba(16,185,129,0.2);border-radius:20px;padding:2px 10px;font-size:0.72rem;}
        .badge-returned{background:rgba(255,255,255,0.06);color:var(--muted);border:1px solid var(--border);border-radius:20px;padding:2px 10px;font-size:0.72rem;}
        .badge-overdue{background:rgba(239,68,68,0.15);color:#fca5a5;border:1px solid rgba(239,68,68,0.25);border-radius:20px;padding:2px 10px;font-size:0.72rem;}
        .btn-return{background:rgba(16,185,129,0.15);border:1px solid rgba(16,185,129,0.3);color:#34d399;padding:5px 14px;border-radius:7px;font-size:0.8rem;cursor:pointer;transition:all 0.2s;font-family:'DM Sans',sans-serif;}
        .btn-return:hover{background:rgba(16,185,129,0.25);}
        .alert-ok{background:rgba(34,197,94,0.1);border:1px solid rgba(34,197,94,0.2);border-radius:12px;padding:12px 16px;color:#86efac;font-size:0.87rem;margin-bottom:20px;}
        .alert-err{background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.2);border-radius:12px;padding:12px 16px;color:#fca5a5;font-size:0.87rem;margin-bottom:20px;}
        .empty-rentals{text-align:center;padding:30px;color:var(--muted);}
        .empty-rentals i{font-size:2rem;margin-bottom:10px;opacity:0.4;}
        .empty-rentals a{color:var(--gold);text-decoration:none;}
    </style>
</head>
<body>
<nav class="navbar">
    <div class="container d-flex justify-content-between align-items-center">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/"><i class="fas fa-crown"></i>CineRent</a>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/movies" class="btn-nav-outline">Browse Movies</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn-nav-gold">Logout</a>
        </div>
    </div>
</nav>

<div class="profile-hero">
    <div class="container">
        <div class="avatar"><%= user.getFullName().substring(0,1).toUpperCase() %></div>
        <h1><%= user.getFullName() %></h1>
        <%-- FIX: safe date — null-guarded above in scriptlet --%>
        <p>@<%= user.getUsername() %> &bull; Member since <%= regDate %></p>
    </div>
</div>

<div class="container mt-4 pb-5">
    <% if (success != null) { %><div class="alert-ok"><i class="fas fa-check-circle me-2"></i><%= success %></div><% } %>
    <% if (error != null) { %><div class="alert-err"><i class="fas fa-exclamation-circle me-2"></i><%= error %></div><% } %>

    <div class="row g-4">
        <div class="col-md-4">
            <div class="card-section">
                <h5><i class="fas fa-user"></i>Profile Information</h5>
                <form action="${pageContext.request.contextPath}/profile" method="post">
                    <input type="hidden" name="action" value="update">
                    <label class="form-label-custom">Full Name</label>
                    <input type="text" name="fullName" class="input-custom" value="<%= user.getFullName() %>" required>
                    <label class="form-label-custom">Email</label>
                    <input type="email" name="email" class="input-custom" value="<%= user.getEmail() %>">
                    <label class="form-label-custom">Phone</label>
                    <input type="text" name="phone" class="input-custom" value="<%= user.getPhone() != null ? user.getPhone() : "" %>">
                    <label class="form-label-custom">Address</label>
                    <input type="text" name="address" class="input-custom" value="<%= user.getAddress() != null ? user.getAddress() : "" %>" placeholder="Your address">
                    <button type="submit" class="btn-gold-full">Update Profile</button>
                </form>
            </div>
            <div class="card-section">
                <h5><i class="fas fa-lock"></i>Change Password</h5>
                <form action="${pageContext.request.contextPath}/profile" method="post">
                    <input type="hidden" name="action" value="changePassword">
                    <label class="form-label-custom">Current Password</label>
                    <input type="password" name="oldPassword" class="input-custom" placeholder="••••••••" required>
                    <label class="form-label-custom">New Password</label>
                    <input type="password" name="newPassword" class="input-custom" placeholder="••••••••" required>
                    <button type="submit" class="btn-gold-full">Change Password</button>
                </form>
            </div>
            <div class="card-section" style="border-color:rgba(220,38,38,0.2);">
                <h5><i class="fas fa-triangle-exclamation" style="color:#ef4444"></i><span style="color:#ef4444">Danger Zone</span></h5>
                <form action="${pageContext.request.contextPath}/profile" method="post" onsubmit="return confirm('Are you sure? This cannot be undone!')">
                    <input type="hidden" name="action" value="deactivate">
                    <button type="submit" class="btn-danger-full">Deactivate Account</button>
                </form>
                <form action="${pageContext.request.contextPath}/profile" method="post" style="margin-top:10px;" onsubmit="return confirm('This will permanently delete all your data including rentals and reviews. This cannot be undone!')">
                    <input type="hidden" name="action" value="deleteData">
                    <button type="submit" class="btn-danger-full" style="border-color:rgba(220,38,38,0.5);">
                        <i class="fas fa-trash me-2"></i>Delete All My Data
                    </button>
                </form>
            </div>
        </div>

        <div class="col-md-8">
            <div class="card-section">
                <h5><i class="fas fa-history"></i>Rental History</h5>
                <% if (rentals == null || rentals.isEmpty()) { %>
                    <div class="empty-rentals">
                        <i class="fas fa-ticket-alt d-block"></i>
                        <p>No rentals yet. <a href="${pageContext.request.contextPath}/movies">Browse movies</a> to get started!</p>
                    </div>
                <% } else { for (Rental rental : rentals) {
                    String statusClass = rental.isOverdue() ? "rental-overdue" : "";
                    String badgeClass = rental.isOverdue() ? "badge-overdue" : (rental.getStatus().equals("ACTIVE") ? "badge-active" : "badge-returned");
                 %>
                    <div class="rental-item <%= statusClass %>">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="rental-title"><%= rental.getMovieTitle() %></div>
                                <div class="rental-dates">Rented: <%= rental.getFormattedRentDate() %> &bull; Due: <%= rental.getFormattedDueDate() %></div>
                                <div class="mt-1">
                                    <span class="<%= badgeClass %>"><%= rental.isOverdue() ? "Overdue" : rental.getStatus() %></span>
                                    <% if (rental.isOverdue()) { %><span class="ms-2" style="font-size:0.78rem;color:#fca5a5;">Fine: $<%= rental.calculateFine() %></span><% } %>
                                </div>
                            </div>
                            <% if (rental.getStatus().equals("ACTIVE")) { %>
                            <form action="${pageContext.request.contextPath}/profile" method="post">
                                <input type="hidden" name="action" value="returnRental">
                                <input type="hidden" name="rentalId" value="<%= rental.getRentalId() %>">
                                <button type="submit" class="btn-return">Return</button>
                            </form>
                            <% } %>
                        </div>
                    </div>
                <% } } %>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
