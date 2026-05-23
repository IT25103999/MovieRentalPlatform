package com.movierental.servlet;

import com.movierental.dao.*;
import com.movierental.model.*;
import com.movierental.utils.QueueManager;
import com.google.gson.Gson;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet({"/admin", "/admin/*"})
public class AdminServlet extends HttpServlet {
    private MovieDAO movieDAO;
    private UserDAO userDAO;
    private RentalDAO rentalDAO;
    private ReviewDAO reviewDAO;
    private QueueManager queueManager;
    private Gson gson;

    @Override
    public void init() {
        String basePath = getServletContext().getInitParameter("data.path")
                .replace("${user.home}", System.getProperty("user.home"));
        movieDAO = new MovieDAO(basePath + "movies.txt");
        userDAO = new UserDAO(basePath + "users.txt");
        rentalDAO = new RentalDAO(basePath + "rentals.txt", basePath + "movies.txt");
        reviewDAO = new ReviewDAO(basePath + "reviews.txt", movieDAO);
        queueManager = new QueueManager(basePath + "queue.txt");
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String pathInfo = request.getPathInfo();

        // Check if user is admin
        if (!"ADMIN".equals(session.getAttribute("userType"))) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // ========== API ENDPOINTS ==========
        if (pathInfo != null && pathInfo.equals("/api/movie")) {
            String movieId = request.getParameter("id");
            Movie movie = movieDAO.getMovieById(movieId);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            if (movie != null) {
                response.getWriter().write(gson.toJson(movie));
            } else {
                response.getWriter().write("{}");
            }
            return;
        }

        if (pathInfo != null && pathInfo.equals("/api/user")) {
            String userId = request.getParameter("id");
            User user = userDAO.getUserById(userId);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            if (user != null) {
                response.getWriter().write(gson.toJson(user));
            } else {
                response.getWriter().write("{}");
            }
            return;
        }

        // Export CSV
        String exportType = request.getParameter("export");
        if (exportType != null) {
            exportData(response, exportType);
            return;
        }

        // Load dashboard data
        List<Movie> movies = movieDAO.getAllMovies();
        List<User> users = userDAO.getAllUsersAll(); // Show ALL users (incl. inactive) in admin table
        List<RentalRequest> queue = queueManager.getAllRequests();
        List<Rental> rentals = rentalDAO.getAllRentals();
        List<Review> reviews = reviewDAO.getAllReviews();

        long totalMovies = movies.size();
        // Exclude ADMIN accounts from member count — only count CUSTOMER users
        long totalUsers = users.stream().filter(u -> !"ADMIN".equals(u.getUserType())).count();
        long activeRentals = rentals.stream().filter(r -> "ACTIVE".equals(r.getStatus())).count();
        int queueSize = queue.size();
        // Include both COMPLETED and ACTIVE rentals in total revenue (money earned/owed)
        double totalRevenue = rentals.stream()
                .filter(r -> "COMPLETED".equals(r.getStatus()) || "ACTIVE".equals(r.getStatus()))
                .mapToDouble(Rental::getRentalPrice).sum();

        // Count all non-cancelled rentals to find most popular movie
        Map<String, Long> popularMovies = rentals.stream()
                .filter(r -> !"CANCELLED".equals(r.getStatus()))
                .collect(Collectors.groupingBy(Rental::getMovieTitle, Collectors.counting()));
        String topMovie = popularMovies.entrySet().stream().max(Map.Entry.comparingByValue()).map(Map.Entry::getKey).orElse("N/A");

        request.setAttribute("totalMovies", totalMovies);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("activeRentals", activeRentals);
        request.setAttribute("queueSize", queueSize);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("topMovie", topMovie);
        request.setAttribute("totalReviews", (long) reviews.size());
        request.setAttribute("movies", movies);
        request.setAttribute("users", users);
        request.setAttribute("queue", queue);
        request.setAttribute("rentals", rentals);
        request.setAttribute("reviews", reviews);

        request.getRequestDispatcher("/pages/admin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        System.out.println("=== AdminServlet POST received ===");
        System.out.println("Action: " + action);

        // ========== UPDATE MOVIE VIA API ==========
        if (action != null && action.equals("updateMovieApi")) {
            String movieId = request.getParameter("movieId");
            String title = request.getParameter("title");
            String director = request.getParameter("director");
            String genre = request.getParameter("genre");
            int year = Integer.parseInt(request.getParameter("year"));
            int copies = Integer.parseInt(request.getParameter("copies"));
            double price = Double.parseDouble(request.getParameter("price"));
            String posterUrl = request.getParameter("posterUrl");

            System.out.println("Updating movie: " + movieId);
            System.out.println("Title: " + title);

            Movie movie = movieDAO.getMovieById(movieId);
            if (movie != null) {
                movie.setTitle(title);
                movie.setDirector(director);
                movie.setGenre(genre);
                movie.setReleaseYear(year);
                movie.setTotalCopies(copies);
                movie.setRentalPrice(price);
                if (posterUrl != null && !posterUrl.isEmpty()) {
                    movie.setPosterUrl(posterUrl);
                }

                boolean updated = movieDAO.updateMovie(movie);
                response.setContentType("application/json");
                if (updated) {
                    response.getWriter().write("{\"success\":true}");
                    System.out.println("Movie updated successfully!");
                } else {
                    response.getWriter().write("{\"success\":false, \"error\":\"Database update failed\"}");
                    System.out.println("Movie update FAILED!");
                }
            } else {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false, \"error\":\"Movie not found\"}");
                System.out.println("Movie not found: " + movieId);
            }
            return;
        }

        // ========== UPDATE USER VIA API ==========
        if (action != null && action.equals("updateUserApi")) {
            String userId = request.getParameter("userId");
            String username = request.getParameter("username");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String userType = request.getParameter("userType");
            boolean status = Boolean.parseBoolean(request.getParameter("status"));

            User user = userDAO.getUserById(userId);
            if (user != null) {
                user.setUsername(username);
                user.setFullName(fullName);
                user.setEmail(email);
                user.setPhone(phone);
                user.setAddress(address);
                user.setUserType(userType);
                user.setActive(status);

                boolean updated = userDAO.updateUser(user);
                response.setContentType("application/json");
                if (updated) {
                    response.getWriter().write("{\"success\":true}");
                } else {
                    response.getWriter().write("{\"success\":false}");
                }
            } else {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false}");
            }
            return;
        }

        // ========== REGULAR POST ACTIONS ==========
        if ("addMovie".equals(action)) {
            String title = request.getParameter("title");
            String director = request.getParameter("director");
            String genre = request.getParameter("genre");
            int year = Integer.parseInt(request.getParameter("year"));
            int copies = Integer.parseInt(request.getParameter("copies"));
            double price = Double.parseDouble(request.getParameter("price"));
            String posterUrl = request.getParameter("posterUrl");

            Movie movie = new Movie(null, title, director, genre, year, copies, price);
            if (posterUrl != null && !posterUrl.isEmpty()) {
                movie.setPosterUrl(posterUrl);
            }

            if (movieDAO.createMovie(movie)) {
                session.setAttribute("success", "Movie added!");
            } else {
                session.setAttribute("error", "Failed to add movie.");
            }

        } else if ("deleteMovie".equals(action)) {
            String id = request.getParameter("id");
            if (movieDAO.deleteMovie(id)) {
                session.setAttribute("success", "Movie deleted!");
            } else {
                session.setAttribute("error", "Failed to delete movie.");
            }

        } else if ("addUser".equals(action)) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String userType = request.getParameter("userType");

            if (userDAO.getUserByUsername(username) == null) {
                User newUser = new User(null, username, password, email, fullName, userType);
                if (userDAO.createUser(newUser)) {
                    session.setAttribute("success", "User added!");
                } else {
                    session.setAttribute("error", "Failed to add user.");
                }
            } else {
                session.setAttribute("error", "Username already exists!");
            }

        } else if ("deleteUser".equals(action)) {
            String id = request.getParameter("id");
            if (userDAO.deleteUser(id)) {
                session.setAttribute("success", "User deleted!");
            } else {
                session.setAttribute("error", "Failed to delete user.");
            }

        } else if ("returnRental".equals(action)) {
            String rentalId = request.getParameter("rentalId");
            if (rentalDAO.returnRental(rentalId)) {
                session.setAttribute("success", "Rental returned!");
            } else {
                session.setAttribute("error", "Failed to return rental.");
            }

        } else if ("processQueue".equals(action)) {
            // BUG FIX: Check movie availability BEFORE calling processNext().
            // processNext() polls (removes) the item from the queue immediately;
            // if the movie is unavailable we cannot put it back, so the request
            // would be permanently lost.
            List<RentalRequest> pending = queueManager.getAllRequests();
            if (pending.isEmpty()) {
                session.setAttribute("error", "No pending requests.");
            } else {
                RentalRequest next = pending.get(0);
                Movie movie = movieDAO.getMovieById(next.getMovieId());
                if (movie != null && movie.isAvailable()) {
                    RentalRequest req = queueManager.processNext(); // safe to consume now
                    if (movieDAO.rentMovie(req.getMovieId())) {
                        Rental rental = new Rental(null, req.getUserId(), req.getMovieId(),
                                req.getMovieTitle(), req.getRentalDays(),
                                movie.getRentalPrice());
                        rentalDAO.createRental(rental);
                        session.setAttribute("success", "Queue request processed for \"" + req.getMovieTitle() + "\"!");
                    } else {
                        // rentMovie failed after availability check — re-queue as PENDING
                        req.setStatus("PENDING");
                        queueManager.addRequest(req);
                        session.setAttribute("error", "Failed to rent movie. Request re-queued.");
                    }
                } else {
                    session.setAttribute("error", "Movie \"" + next.getMovieTitle() + "\" is still unavailable. Cannot process yet.");
                }
            }

        } else if ("rejectQueue".equals(action)) {
            String requestId = request.getParameter("requestId");
            if (queueManager.removeRequest(requestId)) {
                session.setAttribute("success", "Request rejected!");
            } else {
                session.setAttribute("error", "Failed to reject.");
            }

        } else if ("processAllQueue".equals(action)) {
            // BUG FIX: Peek at each request before consuming it. Only call
            // processNext() when the movie is actually available; otherwise skip
            // so the request stays PENDING in the queue instead of being lost.
            int processed = 0;
            int skipped = 0;
            List<RentalRequest> snapshot = new ArrayList<>(queueManager.getAllRequests());
            for (RentalRequest next : snapshot) {
                Movie movie = movieDAO.getMovieById(next.getMovieId());
                if (movie != null && movie.isAvailable()) {
                    RentalRequest req = queueManager.processNext();
                    if (req != null && movieDAO.rentMovie(req.getMovieId())) {
                        Rental rental = new Rental(null, req.getUserId(), req.getMovieId(),
                                req.getMovieTitle(), req.getRentalDays(),
                                movie.getRentalPrice());
                        rentalDAO.createRental(rental);
                        processed++;
                    } else if (req != null) {
                        // rentMovie failed — re-queue
                        req.setStatus("PENDING");
                        queueManager.addRequest(req);
                        skipped++;
                    }
                } else {
                    skipped++;
                }
            }
            String msg = processed + " request(s) processed!";
            if (skipped > 0) msg += " " + skipped + " skipped (movie unavailable).";
            session.setAttribute("success", msg);

        } else if ("deleteReview".equals(action)) {
            String reviewId = request.getParameter("reviewId");
            if (reviewDAO.deleteReview(reviewId)) {
                session.setAttribute("success", "Review deleted!");
            } else {
                session.setAttribute("error", "Failed to delete review.");
            }

        } else if ("deleteOldReviews".equals(action)) {
            int deleted = reviewDAO.deleteReviewsOlderThan(5);
            session.setAttribute("success", deleted + " old reviews deleted!");
        }

        response.sendRedirect(request.getContextPath() + "/admin");
    }

    private void exportData(HttpServletResponse response, String type) throws IOException {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=" + type + "_export.csv");
        PrintWriter out = response.getWriter();

        if ("movies".equals(type)) {
            out.println("ID,Title,Director,Genre,Year,Rating,Copies,Price");
            for (Movie m : movieDAO.getAllMovies()) {
                out.println(m.getMovieId() + "," + m.getTitle() + "," + m.getDirector() + "," +
                        m.getGenre() + "," + m.getReleaseYear() + "," + m.getRating() + "," +
                        m.getAvailableCopies() + "/" + m.getTotalCopies() + "," + m.getRentalPrice());
            }
        } else if ("users".equals(type)) {
            out.println("ID,Username,FullName,Email,Type,Status");
            for (User u : userDAO.getAllUsers()) {
                out.println(u.getUserId() + "," + u.getUsername() + "," + u.getFullName() + "," +
                        u.getEmail() + "," + u.getUserType() + "," + (u.isActive() ? "Active" : "Inactive"));
            }
        }
    }
}
