<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In — CineRent</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root{--bg:#080b12;--surface:#0f1420;--surface2:#161c2d;--border:rgba(255,255,255,0.07);--accent:#e8b84b;--text:#f1f5f9;--muted:#64748b;}
        *,*::before,*::after{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;display:flex;overflow:hidden;}

        /* Film strips */
        .strip{position:fixed;top:0;bottom:0;width:52px;background:repeating-linear-gradient(180deg,#0a0d14 0,#0a0d14 34px,#111622 34px,#111622 36px);display:flex;flex-direction:column;align-items:center;gap:26px;padding-top:14px;overflow:hidden;z-index:10;}
        .strip.left{left:0;border-right:1px solid rgba(255,255,255,.04);}
        .strip.right{right:0;border-left:1px solid rgba(255,255,255,.04);}
        .hole{width:16px;height:12px;border:1.5px solid rgba(255,255,255,.06);border-radius:3px;flex-shrink:0;}

        /* Center */
        .center{flex:1;display:flex;align-items:center;justify-content:center;margin:0 52px;padding:32px 20px;position:relative;}
        .center::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse 60% 70% at 50% 50%,rgba(232,184,75,.05),transparent);pointer-events:none;}

        .card{width:100%;max-width:420px;animation:up .55s cubic-bezier(.16,1,.3,1) both;}
        @keyframes up{from{opacity:0;transform:translateY(24px)}to{opacity:1;transform:translateY(0)}}

        /* Brand */
        .brand{text-align:center;margin-bottom:36px;}
        .logo{width:52px;height:52px;background:var(--accent);border-radius:14px;display:inline-flex;align-items:center;justify-content:center;font-family:'Syne',sans-serif;font-weight:800;font-size:20px;color:#000;box-shadow:0 8px 28px rgba(232,184,75,.3);margin-bottom:14px;}
        .brand h1{font-family:'Syne',sans-serif;font-size:1.8rem;font-weight:800;letter-spacing:-.02em;}
        .brand p{color:var(--muted);font-size:.87rem;margin-top:4px;}

        /* Panel */
        .panel{background:var(--surface);border:1px solid var(--border);border-radius:22px;padding:36px;box-shadow:0 40px 80px rgba(0,0,0,.5),inset 0 1px 0 rgba(255,255,255,.05);}
        .panel-title{font-family:'Syne',sans-serif;font-size:1.25rem;font-weight:700;text-align:center;margin-bottom:28px;}

        /* Inputs */
        .field{position:relative;margin-bottom:14px;}
        .field-icon{position:absolute;left:14px;top:50%;transform:translateY(-50%);color:var(--accent);font-size:.82rem;pointer-events:none;}
        .field input{width:100%;background:var(--surface2);border:1px solid rgba(255,255,255,.06);border-radius:11px;padding:13px 16px 13px 42px;color:var(--text);font-family:'DM Sans',sans-serif;font-size:.92rem;transition:border-color .2s,box-shadow .2s;outline:none;}
        .field input:focus{border-color:var(--accent);box-shadow:0 0 0 3px rgba(232,184,75,.12);}
        .field input::placeholder{color:rgba(255,255,255,.22);}

        /* Button */
        .btn-main{width:100%;background:var(--accent);color:#000;border:none;border-radius:11px;padding:13px;font-family:'Syne',sans-serif;font-weight:700;font-size:.95rem;cursor:pointer;transition:all .25s;margin-top:6px;letter-spacing:.01em;}
        .btn-main:hover{background:#f0c75a;transform:translateY(-2px);box-shadow:0 8px 24px rgba(232,184,75,.35);}

        /* Divider */
        .div-line{display:flex;align-items:center;gap:12px;margin:18px 0;color:var(--muted);font-size:.75rem;}
        .div-line::before,.div-line::after{content:'';flex:1;height:1px;background:var(--border);}

        /* Link */
        .foot-link{text-align:center;color:var(--muted);font-size:.86rem;}
        .foot-link a{color:var(--accent);text-decoration:none;font-weight:600;}
        .foot-link a:hover{color:#f0c75a;}

        /* Alerts */
        .alert{border-radius:10px;padding:11px 14px;font-size:.84rem;margin-bottom:18px;display:flex;align-items:center;gap:8px;}
        .alert-err{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.25);color:#fca5a5;}
        .alert-ok{background:rgba(34,197,94,.1);border:1px solid rgba(34,197,94,.25);color:#86efac;}

        /* Demo hint */
        .demo{background:rgba(232,184,75,.05);border:1px solid rgba(232,184,75,.12);border-radius:10px;padding:9px 14px;text-align:center;font-size:.74rem;color:rgba(232,184,75,.6);margin-top:16px;}
    </style>
</head>
<body>
    <div class="strip left"><% for(int i=0;i<50;i++){%><div class="hole"></div><%}%></div>
    <div class="strip right"><% for(int i=0;i<50;i++){%><div class="hole"></div><%}%></div>

    <div class="center">
        <div class="card">
            <div class="brand">
                <div class="logo">CR</div>
                <h1>CineRent</h1>
                <p>Premium Movie Rental Platform</p>
            </div>
            <div class="panel">
                <div class="panel-title">Welcome back</div>

                <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-err"><i class="fas fa-circle-exclamation"></i><%= request.getAttribute("error") %></div>
                <% } %>
                <% if (request.getAttribute("success") != null) { %>
                <div class="alert alert-ok"><i class="fas fa-circle-check"></i><%= request.getAttribute("success") %></div>
                <% } %>

                <form action="${pageContext.request.contextPath}/login" method="post">
                    <div class="field">
                        <span class="field-icon"><i class="fas fa-user"></i></span>
                        <input type="text" name="username" placeholder="Username" required autofocus>
                    </div>
                    <div class="field">
                        <span class="field-icon"><i class="fas fa-lock"></i></span>
                        <input type="password" name="password" placeholder="Password" required>
                    </div>
                    <button type="submit" class="btn-main"><i class="fas fa-right-to-bracket" style="margin-right:8px"></i>Sign In</button>
                </form>

                <div class="div-line">or</div>
                <div class="foot-link">Don't have an account? <a href="${pageContext.request.contextPath}/pages/register.jsp">Sign up free</a></div>
                <div class="demo"><i class="fas fa-circle-info" style="margin-right:5px"></i>Demo: <strong>admin</strong> / admin123 &nbsp;·&nbsp; <strong>john</strong> / pass123</div>
            </div>
        </div>
    </div>
</body>
</html>
