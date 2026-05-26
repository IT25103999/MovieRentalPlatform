<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account — CineRent</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root{--bg:#080b12;--surface:#0f1420;--surface2:#161c2d;--border:rgba(255,255,255,0.07);--accent:#e8b84b;--text:#f1f5f9;--muted:#64748b;}
        *,*::before,*::after{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;display:flex;overflow:hidden;}

        .strip{position:fixed;top:0;bottom:0;width:52px;background:repeating-linear-gradient(180deg,#0a0d14 0,#0a0d14 34px,#111622 34px,#111622 36px);display:flex;flex-direction:column;align-items:center;gap:26px;padding-top:14px;overflow:hidden;z-index:10;}
        .strip.left{left:0;border-right:1px solid rgba(255,255,255,.04);}
        .strip.right{right:0;border-left:1px solid rgba(255,255,255,.04);}
        .hole{width:16px;height:12px;border:1.5px solid rgba(255,255,255,.06);border-radius:3px;flex-shrink:0;}

        .center{flex:1;display:flex;align-items:center;justify-content:center;margin:0 52px;padding:32px 20px;position:relative;overflow-y:auto;}
        .center::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse 60% 70% at 50% 50%,rgba(232,184,75,.05),transparent);pointer-events:none;}

        .card{width:100%;max-width:460px;animation:up .55s cubic-bezier(.16,1,.3,1) both;}
        @keyframes up{from{opacity:0;transform:translateY(24px)}to{opacity:1;transform:translateY(0)}}

        .brand{text-align:center;margin-bottom:32px;}
        .logo{width:52px;height:52px;background:var(--accent);border-radius:14px;display:inline-flex;align-items:center;justify-content:center;font-family:'Syne',sans-serif;font-weight:800;font-size:20px;color:#000;box-shadow:0 8px 28px rgba(232,184,75,.3);margin-bottom:14px;}
        .brand h1{font-family:'Syne',sans-serif;font-size:1.8rem;font-weight:800;letter-spacing:-.02em;}
        .brand p{color:var(--muted);font-size:.87rem;margin-top:4px;}

        .panel{background:var(--surface);border:1px solid var(--border);border-radius:22px;padding:36px;box-shadow:0 40px 80px rgba(0,0,0,.5),inset 0 1px 0 rgba(255,255,255,.05);}
        .panel-title{font-family:'Syne',sans-serif;font-size:1.25rem;font-weight:700;text-align:center;margin-bottom:8px;}
        .panel-sub{text-align:center;color:var(--muted);font-size:.83rem;margin-bottom:28px;}

        /* Progress dots */
        .progress-dots{display:flex;justify-content:center;gap:6px;margin-bottom:28px;}
        .dot{width:28px;height:4px;border-radius:2px;background:var(--surface2);transition:background .3s;}
        .dot.active{background:var(--accent);}

        /* Steps */
        .step{display:none;}
        .step.active{display:block;animation:stepIn .35s ease both;}
        @keyframes stepIn{from{opacity:0;transform:translateX(16px)}to{opacity:1;transform:translateX(0)}}

        .field{position:relative;margin-bottom:13px;}
        .field-label{font-size:.72rem;color:var(--muted);text-transform:uppercase;letter-spacing:.08em;display:block;margin-bottom:6px;}
        .field-icon{position:absolute;left:14px;top:50%;transform:translateY(-50%);color:var(--accent);font-size:.82rem;pointer-events:none;}
        .field.has-label .field-icon{top:calc(50% + 10px);}
        .field input,.field select{width:100%;background:var(--surface2);border:1px solid rgba(255,255,255,.06);border-radius:11px;padding:13px 16px 13px 42px;color:var(--text);font-family:'DM Sans',sans-serif;font-size:.92rem;transition:border-color .2s,box-shadow .2s;outline:none;}
        .field input:focus,.field select:focus{border-color:var(--accent);box-shadow:0 0 0 3px rgba(232,184,75,.12);}
        .field input::placeholder{color:rgba(255,255,255,.22);}

        /* Strength bar */
        .strength-bar{height:3px;border-radius:2px;background:var(--surface2);margin-top:6px;overflow:hidden;}
        .strength-fill{height:100%;width:0;border-radius:2px;transition:width .3s,background .3s;}

        .btn-main{width:100%;background:var(--accent);color:#000;border:none;border-radius:11px;padding:13px;font-family:'Syne',sans-serif;font-weight:700;font-size:.95rem;cursor:pointer;transition:all .25s;margin-top:6px;}
        .btn-main:hover{background:#f0c75a;transform:translateY(-2px);box-shadow:0 8px 24px rgba(232,184,75,.35);}
        .btn-ghost{width:100%;background:transparent;color:var(--muted);border:1px solid var(--border);border-radius:11px;padding:12px;font-family:'DM Sans',sans-serif;font-size:.88rem;cursor:pointer;transition:all .2s;margin-top:8px;}
        .btn-ghost:hover{border-color:rgba(255,255,255,.15);color:var(--text);}

        /* Perks */
        .perks{display:flex;flex-direction:column;gap:10px;margin-bottom:24px;}
        .perk{display:flex;align-items:center;gap:12px;padding:14px;background:rgba(232,184,75,.05);border:1px solid rgba(232,184,75,.1);border-radius:12px;}
        .perk i{color:var(--accent);font-size:1.1rem;width:20px;text-align:center;flex-shrink:0;}
        .perk-text{font-size:.84rem;color:var(--muted);}
        .perk-text strong{color:var(--text);display:block;font-size:.88rem;}

        .alert{border-radius:10px;padding:11px 14px;font-size:.84rem;margin-bottom:18px;display:flex;align-items:center;gap:8px;}
        .alert-err{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.25);color:#fca5a5;}

        .div-line{display:flex;align-items:center;gap:12px;margin:18px 0;color:var(--muted);font-size:.75rem;}
        .div-line::before,.div-line::after{content:'';flex:1;height:1px;background:var(--border);}
        .foot-link{text-align:center;color:var(--muted);font-size:.86rem;}
        .foot-link a{color:var(--accent);text-decoration:none;font-weight:600;}
        .foot-link a:hover{color:#f0c75a;}
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
                <p>Join thousands of movie lovers</p>
            </div>
            <div class="panel">
                <div class="panel-title">Create your account</div>
                <div class="panel-sub">Two quick steps and you're in</div>

                <div class="progress-dots">
                    <div class="dot active" id="d1"></div>
                    <div class="dot" id="d2"></div>
                </div>

                <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-err"><i class="fas fa-circle-exclamation"></i><%= request.getAttribute("error") %></div>
                <% } %>

                <form action="${pageContext.request.contextPath}/register" method="post" id="regForm">
                    <!-- Step 1: Identity -->
                    <div class="step active" id="step1">
                        <div class="field">
                            <span class="field-icon"><i class="fas fa-id-card"></i></span>
                            <input type="text" name="fullName" id="fullName" placeholder="Full name" required>
                        </div>
                        <div class="field">
                            <span class="field-icon"><i class="fas fa-at"></i></span>
                            <input type="text" name="username" id="username" placeholder="Choose a username" required>
                        </div>
                        <button type="button" class="btn-main" onclick="goStep2()">
                            Continue <i class="fas fa-arrow-right" style="margin-left:6px;font-size:.8rem"></i>
                        </button>
                    </div>

                    <!-- Step 2: Credentials -->
                    <div class="step" id="step2">
                        <div class="field">
                            <span class="field-icon"><i class="fas fa-envelope"></i></span>
                            <input type="email" name="email" placeholder="Email address" required>
                        </div>
                        <div class="field">
                            <span class="field-icon"><i class="fas fa-lock"></i></span>
                            <input type="password" name="password" id="pwdInput" placeholder="Create a password" required minlength="8" pattern=".*[^a-zA-Z0-9].*" title="Password must be at least 8 characters long and contain at least one symbol" oninput="checkStrength(this.value)">
                            <div class="strength-bar"><div class="strength-fill" id="sf"></div></div>
                        </div>
                        <button type="submit" class="btn-main">
                            <i class="fas fa-user-plus" style="margin-right:8px"></i>Create Account
                        </button>
                        <button type="button" class="btn-ghost" onclick="goStep1()">
                            <i class="fas fa-arrow-left" style="margin-right:6px;font-size:.8rem"></i> Back
                        </button>
                    </div>
                </form>

                <div class="div-line">or</div>
                <div class="foot-link">Already have an account? <a href="${pageContext.request.contextPath}/pages/login.jsp">Sign in</a></div>
            </div>

            <!-- Perks below card -->
            <div class="perks" style="margin-top:20px">
                <div class="perk"><i class="fas fa-play-circle"></i><div class="perk-text"><strong>Instant Streaming</strong>Rent and watch in seconds</div></div>
                <div class="perk"><i class="fas fa-shield-halved"></i><div class="perk-text"><strong>Secure & Private</strong>Your data stays yours</div></div>
                <div class="perk"><i class="fas fa-ticket"></i><div class="perk-text"><strong>Flexible Rentals</strong>3, 5 or 7-day windows</div></div>
            </div>
        </div>
    </div>

    <script>
        function goStep2(){
            const fn=document.getElementById('fullName');
            const un=document.getElementById('username');
            if(!fn.value.trim()||!un.value.trim()){fn.focus();return;}
            document.getElementById('step1').classList.remove('active');
            document.getElementById('step2').classList.add('active');
            document.getElementById('d1').classList.remove('active');
            document.getElementById('d2').classList.add('active');
        }
        function goStep1(){
            document.getElementById('step2').classList.remove('active');
            document.getElementById('step1').classList.add('active');
            document.getElementById('d2').classList.remove('active');
            document.getElementById('d1').classList.add('active');
        }
        function checkStrength(v){
            const sf=document.getElementById('sf');
            let s=0;
            if(v.length>=8)s++;if(/[A-Z]/.test(v))s++;if(/[0-9]/.test(v))s++;if(/[^A-Za-z0-9]/.test(v))s++;
            const w=['0%','28%','55%','78%','100%'][s];
            const c=['','#ef4444','#f59e0b','#3b82f6','#22c55e'][s];
            sf.style.width=w;sf.style.background=c;
        }
    </script>
</body>
</html>
