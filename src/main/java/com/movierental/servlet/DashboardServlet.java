package com.movierental.servlet;

import com.movierental.dao.MovieDAO;
import com.movierental.dao.RentalDAO;
import com.movierental.model.Movie;
import com.movierental.model.Rental;
import com.movierental.model.RentalRequest;
import com.movierental.utils.QueueManager;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet({"/dashboard", "/customer-dashboard"})
public class DashboardServlet extends HttpServlet {
    private MovieDAO movieDAO;
    private RentalDAO rentalDAO;
    private QueueManager queueManager;

    @Override
    public void init() {
        String basePath = getServletContext().getInitParameter("data.path")
                .replace("${user.home}", System.getProperty("user.home"));
        String moviePath = basePath + "movies.txt";
        String rentalPath = basePath + "rentals.txt";
        String queuePath = basePath + "queue.txt";
        movieDAO = new MovieDAO(moviePath);
        rentalDAO = new RentalDAO(rentalPath, moviePath);
        queueManager = new QueueManager(queuePath);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        String userType = (String) session.getAttribute("userType");

        // Check if user is logged in
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
            return;
        }

        // If admin, redirect to admin panel
        if ("ADMIN".equals(userType)) {
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        }

        // Get data for customer dashboard
        List<Movie> featuredMovies = movieDAO.getAllMovies();
        if (featuredMovies.size() > 6) {
            featuredMovies = featuredMovies.subList(0, 6);
        }

        List<Rental> activeRentals = rentalDAO.getActiveRentals(userId);
        List<Rental> rentalHistory = rentalDAO.getUserRentalHistory(userId);

        // QueueManager is now file-backed (no stale in-memory state).
        // getAllRequests() always reads fresh PENDING items from disk.
        List<RentalRequest> pendingRequests = queueManager.getAllRequests()
                .stream()
                .filter(r -> r.getUserId().equals(userId))
                .collect(Collectors.toList());

        request.setAttribute("username", username);
        request.setAttribute("featuredMovies", featuredMovies);
        request.setAttribute("activeRentals", activeRentals);
        request.setAttribute("rentalHistory", rentalHistory);
        request.setAttribute("activeRentalsCount", activeRentals.size());
        request.setAttribute("totalRentals", rentalHistory.size());
        request.setAttribute("pendingRequests", pendingRequests);

        request.getRequestDispatcher("/pages/dashboard.jsp").forward(request, response);
    }
}
