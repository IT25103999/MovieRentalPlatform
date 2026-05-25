package com.movierental.servlet;


import com.movierental.dao.UserDAO;
import com.movierental.model.Rental;
import com.movierental.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private UserDAO userDAO;
    private RentalDAO rentalDAO;

    @Override
    public void init() {
        String basePath = getServletContext().getInitParameter("data.path")
                .replace("${user.home}", System.getProperty("user.home"));
        String userPath = basePath + "users.txt";
        String rentalPath = basePath + "rentals.txt";
        String moviePath = basePath + "movies.txt";
        userDAO = new UserDAO(userPath);
        rentalDAO = new RentalDAO(rentalPath, moviePath);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
            return;
        }

        User user = userDAO.getUserById(userId);
        List<Rental> rentals = rentalDAO.getUserRentalHistory(userId);

        request.setAttribute("user", user);
        request.setAttribute("rentals", rentals);
        request.getRequestDispatcher("/pages/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String action = request.getParameter("action");

        User user = userDAO.getUserById(userId);

        if ("update".equals(action)) {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            if (fullName != null && !fullName.trim().isEmpty()) user.setFullName(fullName.trim());
            user.setEmail(email);
            user.setPhone(phone);
            user.setAddress(address);
            if (userDAO.updateUser(user)) {
                session.setAttribute("success", "Profile updated!");
            } else {
                session.setAttribute("error", "Failed to update profile.");
            }
        } else if ("changePassword".equals(action)) {
            String oldPass = request.getParameter("oldPassword");
            String newPass = request.getParameter("newPassword");
            if (user.getPassword().equals(oldPass)) {
                user.setPassword(newPass);
                userDAO.updateUser(user);
                session.setAttribute("success", "Password changed!");
            } else {
                session.setAttribute("error", "Wrong password!");
            }
        } else if ("deactivate".equals(action)) {
            user.setActive(false);
            userDAO.updateUser(user);
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/");
            return;
        } else if ("deleteData".equals(action)) {
            // Remove all user rentals, reviews, then deactivate account
            String basePath2 = getServletContext().getInitParameter("data.path")
                    .replace("${user.home}", System.getProperty("user.home"));
            com.movierental.dao.ReviewDAO reviewDAO2 = new com.movierental.dao.ReviewDAO(
                basePath2 + "reviews.txt",
                new com.movierental.dao.MovieDAO(basePath2 + "movies.txt"));
            for (com.movierental.model.Review rev : reviewDAO2.getReviewsByUser(userId)) {
                reviewDAO2.deleteReview(rev.getReviewId());
            }
            // Cancel all active rentals
            for (com.movierental.model.Rental r : rentalDAO.getActiveRentals(userId)) {
                rentalDAO.cancelRental(r.getRentalId());
            }
            // Deactivate account
            user.setActive(false);
            userDAO.updateUser(user);
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/");
            return;
        } else if ("extendRental".equals(action)) {
            String rentalId = request.getParameter("rentalId");
            int extraDays = Integer.parseInt(request.getParameter("extraDays"));
            if (rentalDAO.extendRental(rentalId, extraDays)) {
                session.setAttribute("success", "Rental extended!");
            }
        } else if ("cancelRental".equals(action)) {
            String rentalId = request.getParameter("rentalId");
            if (rentalDAO.cancelRental(rentalId)) {
                session.setAttribute("success", "Rental cancelled!");
            }
        } else if ("returnRental".equals(action)) {
            String rentalId = request.getParameter("rentalId");
            if (rentalDAO.returnRental(rentalId)) {
                session.setAttribute("success", "Rental returned!");
            }
        }

        String redirectTo = request.getParameter("redirectTo");
        String redirectUrl = "dashboard".equals(redirectTo)
            ? request.getContextPath() + "/dashboard"
            : request.getContextPath() + "/profile";

        response.sendRedirect(redirectUrl);
    }
}
