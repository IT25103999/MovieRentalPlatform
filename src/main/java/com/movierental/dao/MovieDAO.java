package com.movierental.dao;
//sasidu
import com.movierental.model.Movie;
import java.io.*;
import java.util.*;

public class MovieDAO {
    private String filePath;

    public MovieDAO(String filePath) {
        this.filePath = filePath;
        try {
            File file = new File(filePath);
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                file.createNewFile();
                addSampleMovies();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void addSampleMovies() throws IOException {
        Movie[] sample = {
                new Movie(null, "Inception", "Christopher Nolan", "Sci-Fi", 2010, 5, 4.99),
                new Movie(null, "The Dark Knight", "Christopher Nolan", "Action", 2008, 3, 4.99),
                new Movie(null, "Interstellar", "Christopher Nolan", "Sci-Fi", 2014, 4, 5.99),
                new Movie(null, "Parasite", "Bong Joon-ho", "Thriller", 2019, 3, 3.99),
                new Movie(null, "The Godfather", "Francis Ford Coppola", "Drama", 1972, 2, 3.99),
                new Movie(null, "Pulp Fiction", "Quentin Tarantino", "Crime", 1994, 5, 4.99),
                new Movie(null, "The Matrix", "Wachowski Sisters", "Sci-Fi", 1999, 4, 4.99)
        };
        for (Movie m : sample) {
            createMovie(m);
        }
    }

    public boolean createMovie(Movie movie) {
        try {
            String nextId = FileHandler.getNextId(filePath, "MOV");
            movie.setMovieId(nextId);
            FileHandler.appendLine(filePath, movie.toString());
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Movie> getAllMovies() {
        List<Movie> movies = new ArrayList<>();
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                Movie movie = Movie.fromString(line);
                if (movie.isActive()) {
                    movies.add(movie);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return movies;
    }

    public Movie getMovieById(String id) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                Movie movie = Movie.fromString(line);
                if (movie.getMovieId().equals(id) && movie.isActive()) {
                    return movie;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Movie> searchMovies(String keyword) {
        List<Movie> results = new ArrayList<>();
        for (Movie movie : getAllMovies()) {
            if (movie.getTitle().toLowerCase().contains(keyword.toLowerCase()) ||
                    movie.getDirector().toLowerCase().contains(keyword.toLowerCase())) {
                results.add(movie);
            }
        }
        return results;
    }

    public List<Movie> getMoviesByGenre(String genre) {
        List<Movie> results = new ArrayList<>();
        for (Movie movie : getAllMovies()) {
            if (movie.getGenre().equalsIgnoreCase(genre)) {
                results.add(movie);
            }
        }
        return results;
    }

    public boolean updateMovie(Movie movie) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (int i = 0; i < lines.size(); i++) {
                Movie existing = Movie.fromString(lines.get(i));
                if (existing.getMovieId().equals(movie.getMovieId())) {
                    lines.set(i, movie.toString());
                    FileHandler.writeAllLines(filePath, lines);
                    return true;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteMovie(String id) {
        Movie movie = getMovieById(id);
        if (movie != null) {
            movie.setActive(false);
            return updateMovie(movie);
        }
        return false;
    }

    public boolean rentMovie(String movieId) {
        Movie movie = getMovieById(movieId);
        if (movie != null && movie.rentMovie()) {
            return updateMovie(movie);
        }
        return false;
    }

    public boolean returnMovie(String movieId) {
        Movie movie = getMovieById(movieId);
        if (movie != null) {
            movie.returnMovie();
            return updateMovie(movie);
        }
        return false;
    }

    public void updateMovieRating(String movieId, int newRating) {
        Movie movie = getMovieById(movieId);
        if (movie != null) {
            movie.addRating(newRating);
            updateMovie(movie);
        }
    }
}
