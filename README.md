<div align="center">

# 🎬 CineRent — Movie Rental Platform

**A full-stack Java EE web application for browsing, renting, and managing movies**

![Java](https://img.shields.io/badge/Java-11-orange?style=flat-square&logo=java)
![JSP](https://img.shields.io/badge/JSP-2.3-blue?style=flat-square)
![Maven](https://img.shields.io/badge/Maven-3.x-red?style=flat-square&logo=apachemaven)
![Tomcat](https://img.shields.io/badge/Tomcat-9.x-yellow?style=flat-square&logo=apachetomcat)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

> A group project built with Java Servlets, JSP, JSTL, and flat-file persistence — no database required.

</div>

---

## 📋 Table of Contents

- [About the Project](#-about-the-project)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Data Structures & Algorithms](#-data-structures--algorithms)
- [Data Storage](#-data-storage)
- [Getting Started](#-getting-started)
- [Default Accounts](#-default-accounts)
- [Module Overview](#-module-overview)
- [Team & File Distribution](#-team--file-distribution)

---

## 🎯 About the Project

CineRent is a movie rental web platform developed as a group project using **Java EE** technologies with an **MVC architecture**. Instead of a relational database, it uses **plain text files** as its persistence layer — demonstrating core data structure concepts like stacks, queues, and custom sorting algorithms in a real-world context.

Users can browse a movie catalogue, rent titles, leave reviews, and manage their profiles. Admins get a dedicated dashboard for managing the entire platform.

---

## ✨ Features

### 👤 Customer
- Register and log in with session-based authentication
- Browse the full movie catalogue with genre filters and keyword search
- View movie details, ratings, and community reviews
- Rent a movie instantly (if copies are available) or join a **waitlist queue**
- Extend, cancel, or return active rentals
- Leave star ratings and written reviews; edit or delete your own
- View rental history and recently watched movies on your profile

### 🛡️ Admin
- Full CRUD for movies and users from a single dashboard
- View platform-wide stats: total rentals, revenue, most popular movies
- Manage the rental waitlist queue (approve / reject requests)
- Moderate reviews (delete any review)
- Export data to CSV

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Java 11 |
| Web Framework | Java Servlets + JSP (MVC) |
| Templating | JSTL 1.2 |
| JSON | Gson 2.8.9 |
| Build Tool | Maven 3.x |
| Server | Apache Tomcat 9.x |
| Persistence | Flat-file (`.txt`) via custom `FileHandler` |
| IDE | IntelliJ IDEA (with Smart Tomcat plugin) |

---

## 📁 Project Structure

```
MovieRentalPlatform/
├── data/                          # Flat-file data store
│   ├── movies.txt                 # Movie catalogue
│   ├── users.txt                  # User accounts
│   ├── rentals.txt                # Rental ledger
│   ├── reviews.txt                # User reviews
│   └── queue.txt                  # Rental waitlist queue
│
├── src/main/
│   ├── java/com/movierental/
│   │   ├── dao/                   # Data Access Objects
│   │   │   ├── FileHandler.java   # Shared I/O utility (read/write/append)
│   │   │   ├── MovieDAO.java
│   │   │   ├── RentalDAO.java
│   │   │   ├── ReviewDAO.java
│   │   │   └── UserDAO.java
│   │   │
│   │   ├── model/                 # Plain Java models (POJO + serialisation)
│   │   │   ├── Movie.java
│   │   │   ├── Rental.java
│   │   │   ├── RentalRequest.java
│   │   │   ├── Review.java
│   │   │   └── User.java
│   │   │
│   │   ├── servlet/               # Controllers (one per feature)
│   │   │   ├── AdminServlet.java
│   │   │   ├── DashboardServlet.java
│   │   │   ├── LoginServlet.java
│   │   │   ├── MovieServlet.java
│   │   │   ├── ProfileServlet.java
│   │   │   ├── RegisterServlet.java
│   │   │   ├── RentalServlet.java
│   │   │   └── ReviewServlet.java
│   │   │
│   │   └── utils/                 # Algorithm & data-structure utilities
│   │       ├── BubbleSortUtil.java
│   │       ├── QueueManager.java
│   │       └── RecentlyWatchedStack.java
│   │
│   └── webapp/
│       ├── index.jsp              # Landing page
│       ├── pages/                 # All JSP views
│       │   ├── admin.jsp
│       │   ├── add-review.jsp
│       │   ├── all-reviews.jsp
│       │   ├── dashboard.jsp
│       │   ├── login.jsp
│       │   ├── movie-details.jsp
│       │   ├── movies.jsp
│       │   ├── profile.jsp
│       │   ├── register.jsp
│       │   └── reviews.jsp
│       └── WEB-INF/
│           └── web.xml            # App config (data.path, session timeout)
│
└── pom.xml                        # Maven build descriptor
```

---

## 🧠 Data Structures & Algorithms

This project deliberately implements key CS concepts from scratch rather than relying on library utilities:

### 📚 Stack — Recently Watched (`RecentlyWatchedStack.java`)
- **Structure:** Java `Stack<String>` stored in the HTTP session
- **Behaviour:** LIFO — the most recently viewed movie is always on top
- **Capacity:** Capped at 10 entries; the oldest is auto-trimmed from the bottom
- **Deduplication:** If a movie is viewed again, it moves to the top instead of duplicating
- **Used for:** "Recently Watched" section on the customer profile and dashboard

### 📬 Queue — Rental Waitlist (`QueueManager.java`)
- **Structure:** File-backed FIFO queue (`queue.txt`)
- **Behaviour:** When all copies of a movie are rented out, new requests enter the queue as `PENDING`; the admin processes them in order (`PROCESSED`)
- **Stateless:** Every read/write hits the file directly — no in-memory state — so it survives Tomcat restarts
- **Used for:** Waitlist management in `RentalServlet` and the Admin dashboard

### 🔃 Bubble Sort (`BubbleSortUtil.java`)
- **Algorithm:** Classic bubble sort with an **early-exit optimisation** (stops if a pass completes with no swaps)
- **Time complexity:** O(n²) worst/average · O(n) best
- **Provides:** `sortByRatingDescending()` and `sortByRatingAscending()`
- **Used for:** Ordering the movie catalogue by community rating

### 🔃 Insertion Sort (`QueueManager.insertionSortByRating()`)
- A secondary sort used when rendering movie listings from the queue context

---

## 💾 Data Storage

All data is stored as **pipe-delimited (`|`) plain text files**. No database or ORM is used.

| File | Format | Example |
|------|--------|---------|
| `movies.txt` | `movieId\|title\|director\|genre\|year\|rating\|totalRatings\|availCopies\|totalCopies\|price\|description\|active\|posterUrl` | `MOV001\|Inception\|Christopher Nolan\|Sci-Fi\|2010\|4.8\|125\|3\|5\|4.99\|...` |
| `users.txt` | `userId\|username\|password\|email\|fullName\|phone\|address\|userType\|joinDate\|isActive` | `USR001\|john\|pass123\|john@email.com\|John Doe\|\|\|CUSTOMER\|2024-01-15\|true` |
| `rentals.txt` | `rentalId\|userId\|movieId\|movieTitle\|rentDate\|dueDate\|returnDate\|price\|status` | `RNT001\|USR001\|MOV001\|Inception\|2024-01-20\|2024-01-23\|\|4.99\|ACTIVE` |
| `reviews.txt` | `reviewId\|movieId\|userId\|username\|rating\|comment\|date\|isEdited` | `REV001\|MOV001\|USR001\|john\|5\|Great film!\|2024-01-21\|false` |
| `queue.txt` | `requestId\|userId\|movieId\|movieTitle\|requestDate\|status\|rentalDays` | `REQ1234\|USR002\|MOV002\|The Dark Knight\|2024-01-22\|PENDING\|3` |

The `data.path` is configured once in `web.xml` and resolved at runtime by every DAO — changing this one value relocates all data files.

---

## 🚀 Getting Started

### Prerequisites

- Java 11+
- Apache Maven 3.x
- Apache Tomcat 9.x
- IntelliJ IDEA (recommended, with the **Smart Tomcat** plugin)

### 1. Clone the repository

```bash
git clone https://github.com/IT25103999/MovieRentalPlatform.git
cd MovieRentalPlatform
```

### 2. Build the project

```bash
mvn clean package
```

This produces `target/MovieRentalPlatform.war`.

### 3. Configure the data path

Open `src/main/webapp/WEB-INF/web.xml` and verify (or update) the data directory:

```xml
<context-param>
    <param-name>data.path</param-name>
    <param-value>${user.home}/MovieRentalPlatform/data/</param-value>
</context-param>
```

Copy the `data/` folder to that location:

```bash
cp -r data/ ~/MovieRentalPlatform/data/
```

### 4. Deploy to Tomcat

**Option A — IntelliJ + Smart Tomcat:**
1. Add a **Smart Tomcat** run configuration pointing to your local Tomcat installation
2. Set the deployment artifact to `MovieRentalPlatform:war exploded`
3. Click **Run**

**Option B — Manual WAR deploy:**
```bash
cp target/MovieRentalPlatform.war $CATALINA_HOME/webapps/
$CATALINA_HOME/bin/startup.sh
```

### 5. Open in browser

```
http://localhost:8080/MovieRentalPlatform/
```

---

## 🔑 Default Accounts

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Customer | `john` | `pass123` |
| Customer | `jane` | `pass456` |

> ⚠️ Change these credentials before any public or assessed deployment.

---

## 📦 Module Overview

| Module | Servlet | Key Classes | Description |
|--------|---------|-------------|-------------|
| Authentication | `LoginServlet`, `RegisterServlet` | `UserDAO`, `User` | Register, login, logout via session |
| Movie Catalogue | `MovieServlet` | `MovieDAO`, `Movie`, `BubbleSortUtil` | Browse, search, filter, sort by rating |
| Rental System | `RentalServlet` | `RentalDAO`, `Rental`, `QueueManager` | Rent instantly or join waitlist |
| Review & Rating | `ReviewServlet` | `ReviewDAO`, `Review` | Add, edit, delete star ratings and comments |
| User Profile | `ProfileServlet` | `UserDAO`, `RentalDAO`, `RecentlyWatchedStack` | Edit profile, view history, recently watched |
| Admin Dashboard | `AdminServlet` | All DAOs, `QueueManager` | Full platform management |
| Shared I/O | — | `FileHandler` | Low-level read/write/append for all DAOs |

---

## 👥 Team & File Distribution

| Member | Module | Primary Files |
|--------|--------|---------------|
| Member 1 | Admin Dashboard | `AdminServlet.java`, `admin.jsp`, `UserDAO`, `RentalDAO`, `ReviewDAO`, `MovieDAO` |
| Member 2 | Review & Rating | `ReviewServlet.java`, `ReviewDAO.java`, `Review.java`, `add-review.jsp`, `reviews.jsp` |
| Member 3 | Movie Catalog & Search | `MovieServlet.java`, `MovieDAO.java`, `Movie.java`, `BubbleSortUtil.java`, `movies.jsp` |
| Member 4 | User Profile & History | `ProfileServlet.java`, `UserDAO.java`, `RecentlyWatchedStack.java`, `profile.jsp` |
| Member 5 | Rental & Transaction | `RentalServlet.java`, `RentalDAO.java`, `QueueManager.java`, `Rental.java` |
| Member 6 | User Authentication | `LoginServlet.java`, `RegisterServlet.java`, `UserDAO.java`, `login.jsp`, `register.jsp` |

**Shared by all:** `FileHandler.java` · `pom.xml`

---

<div align="center">

Made with ☕ and Java · Group Project — IT25103999

</div>
