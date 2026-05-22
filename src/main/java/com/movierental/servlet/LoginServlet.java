package com.movierental.servlet;

import com.movierental.dao.UserDAO;
import com.movierental.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet({"/login", "/logout"})
public class LoginServlet extends HttpServlet {
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

        User user = userDAO.validateLogin(username, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userType", user.getUserType());
            session.setAttribute("fullName", user.getFullName());

            if (user.getUserType().equals("ADMIN")) {
                response.sendRedirect(request.getContextPath() + "/admin");
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            }
        } else {
            request.setAttribute("error", "Invalid username or password");
            request.getRequestDispatcher("/pages/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getRequestURI().contains("logout")) {
            request.getSession().invalidate();
            response.sendRedirect(request.getContextPath() + "/");
        }
    }
}
