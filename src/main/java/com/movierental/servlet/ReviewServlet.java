package com.movierental.servlet;

import com.movierental.dao.MovieDAO;
import com.movierental.dao.ReviewDAO;
import com.movierental.model.Review;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet({"/reviews", "/reviews/*", "/review/*"})
public class ReviewServlet extends HttpServlet {
    private ReviewDAO reviewDAO;
    private MovieDAO movieDAO;

    @Override
    public void init() {
        String basePath = getServletContext().getInitParameter("data.path")
                .replace("${user.home}", System.getProperty("user.home"));
        String moviePath = basePath + "movies.txt";
        String reviewPath = basePath + "reviews.txt";
        movieDAO = new MovieDAO(moviePath);
        reviewDAO = new ReviewDAO(reviewPath, movieDAO);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getPathInfo();
        if (path == null || path.equals("/")) {
            request.getRequestDispatcher("/pages/all-reviews.jsp").forward(request, response);
        } else if (path.equals("/list")) {
            String movieId = request.getParameter("movieId");
            request.setAttribute("reviews", reviewDAO.getReviewsByMovie(movieId));
            request.setAttribute("movieId", movieId);
            request.getRequestDispatcher("/pages/reviews.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
            return;
        }

        String path = request.getPathInfo(); // /add, /edit, or /delete

        if ("/add".equals(path)) {
            String movieId = request.getParameter("movieId");
            String ratingParam = request.getParameter("rating");
            int rating = (ratingParam != null && !ratingParam.isEmpty()) ? Integer.parseInt(ratingParam) : 1;
            String comment = request.getParameter("comment");

            if (reviewDAO.hasUserReviewed(userId, movieId)) {
                session.setAttribute("error", "You have already reviewed this movie!");
            } else {
                Review review = new Review(null, movieId, userId, username, rating, comment);
                if (reviewDAO.addReview(review)) {
                    session.setAttribute("success", "Review added successfully!");
                } else {
                    session.setAttribute("error", "Failed to add review. Please try again.");
                }
            }
            // Redirect back to the reviews page so user can see their review
            response.sendRedirect(request.getContextPath() + "/pages/reviews.jsp?movieId=" + movieId);

        } else if ("/edit".equals(path)) {
            String reviewId = request.getParameter("reviewId");
            String movieId  = request.getParameter("movieId");
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");

            if (reviewDAO.updateReview(reviewId, rating, comment)) {
                session.setAttribute("success", "Review updated successfully!");
            } else {
                session.setAttribute("error", "Failed to update review.");
            }
            
            if (movieId != null && !movieId.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/pages/reviews.jsp?movieId=" + movieId);
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            }

        } else if ("/delete".equals(path)) {
            String reviewId = request.getParameter("reviewId");
            String movieId  = request.getParameter("movieId");

            if (reviewDAO.deleteReview(reviewId)) {
                session.setAttribute("success", "Review deleted.");
            } else {
                session.setAttribute("error", "Failed to delete review.");
            }
            if (movieId != null && !movieId.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/pages/reviews.jsp?movieId=" + movieId);
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }
}
