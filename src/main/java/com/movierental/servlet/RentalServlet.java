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

@WebServlet("/rent")
public class RentalServlet extends HttpServlet {
    public MovieDAO movieDAO;
    public RentalDAO rentalDAO;
    public QueueManager queueManager;

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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");

        // Check if user is logged in
        if (userId == null) {
            session.setAttribute("error", "Please login to rent movies");
            response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
            return;
        }

        String movieId = request.getParameter("movieId");
        String daysParam = request.getParameter("days");

        // Validate parameters
        if (movieId == null || movieId.isEmpty()) {
            session.setAttribute("error", "Invalid movie selection");
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        int days = 3; // Default
        if (daysParam != null && !daysParam.isEmpty()) {
            try {
                days = Integer.parseInt(daysParam);
            } catch (NumberFormatException e) {
                days = 3;
            }
        }

        // Get movie details
        Movie movie = movieDAO.getMovieById(movieId);
        if (movie == null) {
            session.setAttribute("error", "Movie not found");
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        System.out.println("=== Rental Request ===");
        System.out.println("User: " + username + " (" + userId + ")");
        System.out.println("Movie: " + movie.getTitle());
        System.out.println("Days: " + days);
        System.out.println("Available copies: " + movie.getAvailableCopies());

        // Check if movie is available
        if (movie.isAvailable()) {
            // Rent immediately
            boolean rentSuccess = movieDAO.rentMovie(movieId);

            if (rentSuccess) {
                // Create rental record
                Rental rental = new Rental(null, userId, movieId, movie.getTitle(), days, movie.getRentalPrice());
                boolean rentalCreated = rentalDAO.createRental(rental);

                if (rentalCreated) {
                    session.setAttribute("success", "Successfully rented \"" + movie.getTitle() + "\" for " + days + " days!");
                    System.out.println("Rental successful!");
                } else {
                    // Rollback - return the copy
                    movieDAO.returnMovie(movieId);
                    session.setAttribute("error", "Failed to create rental record");
                    System.out.println("Rental creation FAILED!");
                }
            } else {
                session.setAttribute("error", "Failed to rent movie. Please try again.");
                System.out.println("Movie rent FAILED!");
            }
        } else {
            // Add to queue (waitlist)
            String requestId = "REQ" + System.currentTimeMillis();
            RentalRequest rentalRequest = new RentalRequest(requestId, userId, movieId, movie.getTitle(), days);
            queueManager.addRequest(rentalRequest);
            int queuePos = queueManager.size();
            session.setAttribute("success", "Movie \"" + movie.getTitle() + "\" is currently unavailable. You have been added to the waitlist (Queue position: #" + queuePos + ")");
            System.out.println("Added to queue. Queue size: " + queuePos);
        }

        response.sendRedirect(request.getContextPath() + "/dashboard");
    }
}
