package com.movierental.servlet;

import com.movierental.dao.MovieDAO;
import com.movierental.model.Movie;
import com.movierental.utils.BubbleSortUtil;
import com.movierental.utils.RecentlyWatchedStack;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/movies/*")
public class MovieServlet extends HttpServlet {
    private MovieDAO movieDAO;

    @Override
    public void init() {
        String dataPath = getServletContext().getInitParameter("data.path")
                .replace("${user.home}", System.getProperty("user.home")) + "movies.txt";
        movieDAO = new MovieDAO(dataPath);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getPathInfo();

        // Handle /movies (list all)
        if (path == null || path.equals("/")) {
            List<Movie> movies = movieDAO.getAllMovies();

            String genre = request.getParameter("genre");
            if (genre != null && !genre.isEmpty()) {
                movies = movieDAO.getMoviesByGenre(genre);
            }

            String keyword = request.getParameter("q");
            if (keyword != null && !keyword.isEmpty()) {
                movies = movieDAO.searchMovies(keyword);
            }

            // Algorithm: Bubble Sort — sort movies by rating descending
            movies = BubbleSortUtil.sortByRatingDescending(movies);

            request.setAttribute("movies", movies);
            request.getRequestDispatcher("/pages/movies.jsp").forward(request, response);
            return;
        }

        // Handle /movies/{id} (single movie detail)
        String movieId = path.substring(1);
        Movie movie = movieDAO.getMovieById(movieId);
        if (movie != null) {
            // Data Structure: Stack — push this movie onto the user's recently watched stack
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("userId") != null) {
                RecentlyWatchedStack stack = RecentlyWatchedStack.fromSession(session);
                stack.push(movieId);
                stack.saveToSession(session);
            }

            request.setAttribute("movie", movie);
            request.getRequestDispatcher("/pages/movie-details.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/movies");
        }
    }
}
