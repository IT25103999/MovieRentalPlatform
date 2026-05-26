package com.movierental.servlet;

import com.movierental.dao.UserDAO;
import com.movierental.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() {
        String dataPath = getServletContext().getInitParameter("data.path")
                .replace("${user.home}", System.getProperty("user.home")) + "users.txt";
        userDAO = new UserDAO(dataPath);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");

        if (password == null || password.length() < 8 || !password.matches(".*[^a-zA-Z0-9].*")) {
            request.setAttribute("error", "Password must be at least 8 characters long and contain at least one symbol");
            request.getRequestDispatcher("/pages/register.jsp").forward(request, response);
            return;
        }

        if (userDAO.getUserByUsername(username) != null) {
            request.setAttribute("error", "Username already exists");
            request.getRequestDispatcher("/pages/register.jsp").forward(request, response);
            return;
        }

        User user = new User(null, username, password, email, fullName, "CUSTOMER");

        if (userDAO.createUser(user)) {
            request.setAttribute("success", "Registration successful! Please login.");
            request.getRequestDispatcher("/pages/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Registration failed");
            request.getRequestDispatcher("/pages/register.jsp").forward(request, response);
        }
    }
}
