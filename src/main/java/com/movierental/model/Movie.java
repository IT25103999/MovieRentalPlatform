package com.movierental.model;

import java.io.Serializable;

public class Movie implements Serializable {
    private static final long serialVersionUID = 1L;

    private String movieId;
    private String title;
    private String director;
    private String genre;
    private int releaseYear;
    private double rating;
    private int totalRatings;
    private int availableCopies;
    private int totalCopies;
    private double rentalPrice;
    private String description;
    private boolean active;
    private String posterUrl;

    // Constructor
    public Movie(String movieId, String title, String director, String genre,
                 int releaseYear, int totalCopies, double rentalPrice) {
        this.movieId = movieId;
        this.title = title;
        this.director = director;
        this.genre = genre;
        this.releaseYear = releaseYear;
        this.totalCopies = totalCopies;
        this.availableCopies = totalCopies;
        this.rentalPrice = rentalPrice;
        this.rating = 0.0;
        this.totalRatings = 0;
        this.active = true;
        this.description = "";
        this.posterUrl = "";
    }

    // ========== GETTERS ==========
    public String getMovieId() { return movieId; }
    public String getTitle() { return title; }
    public String getDirector() { return director; }
    public String getGenre() { return genre; }
    public int getReleaseYear() { return releaseYear; }
    public double getRating() { return rating; }
    public int getTotalRatings() { return totalRatings; }
    public int getAvailableCopies() { return availableCopies; }
    public int getTotalCopies() { return totalCopies; }
    public double getRentalPrice() { return rentalPrice; }
    public String getDescription() { return description; }
    public boolean isActive() { return active; }
    public String getPosterUrl() { return posterUrl; }

    // ========== SETTERS ==========
    public void setMovieId(String movieId) { this.movieId = movieId; }
    public void setTitle(String title) { this.title = title; }
    public void setDirector(String director) { this.director = director; }
    public void setGenre(String genre) { this.genre = genre; }
    public void setReleaseYear(int releaseYear) { this.releaseYear = releaseYear; }
    public void setRating(double rating) { this.rating = rating; }
    public void setTotalRatings(int totalRatings) { this.totalRatings = totalRatings; }
    public void setAvailableCopies(int availableCopies) { this.availableCopies = availableCopies; }
    public void setTotalCopies(int totalCopies) {
        // Adjust availableCopies proportionally: keep the same number rented.
        int rented = this.totalCopies - this.availableCopies;
        if (rented < 0) rented = 0;
        this.totalCopies = totalCopies;
        this.availableCopies = Math.max(0, totalCopies - rented);
    }
    public void setRentalPrice(double rentalPrice) { this.rentalPrice = rentalPrice; }
    public void setDescription(String description) { this.description = description; }
    public void setActive(boolean active) { this.active = active; }
    public void setPosterUrl(String posterUrl) { this.posterUrl = posterUrl; }

    // ========== BUSINESS METHODS ==========
    public boolean isAvailable() {
        return availableCopies > 0 && active;
    }

    public boolean rentMovie() {
        if (availableCopies > 0) {
            availableCopies--;
            return true;
        }
        return false;
    }

    public void returnMovie() {
        if (availableCopies < totalCopies) {
            availableCopies++;
        }
    }

    public void addRating(int newRating) {
        double total = this.rating * this.totalRatings;
        this.totalRatings++;
        this.rating = (total + newRating) / this.totalRatings;
    }

    // Get poster URL with fallback
    public String getPosterUrlOrDefault() {
        if (posterUrl != null && !posterUrl.isEmpty()) {
            return posterUrl;
        }
        switch(title) {
            case "Inception":
                return "https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg";
            case "The Dark Knight":
                return "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg";
            case "Interstellar":
                return "https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg";
            case "Parasite":
                return "https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg";
            case "The Godfather":
                return "https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg";
            case "Pulp Fiction":
                return "https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg";
            case "The Matrix":
                return "https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg";
            case "Goodfellas":
                return "https://image.tmdb.org/t/p/w500/aKuFiU82s5ISJpGZp7YkIr3kCUd.jpg";
            default:
                return "";
        }
    }

    // ========== FILE STORAGE METHODS ==========
    @Override
    public String toString() {
        return movieId + "|" + title + "|" + director + "|" + genre + "|" +
                releaseYear + "|" + rating + "|" + totalRatings + "|" +
                availableCopies + "|" + totalCopies + "|" + rentalPrice + "|" +
                (description != null ? description : "") + "|" + active + "|" +
                (posterUrl != null ? posterUrl : "");
    }

    public static Movie fromString(String line) {
        String[] parts = line.split("\\|");
        Movie movie = new Movie(parts[0], parts[1], parts[2], parts[3],
                Integer.parseInt(parts[4]),
                Integer.parseInt(parts[8]),
                Double.parseDouble(parts[9]));
        movie.setRating(Double.parseDouble(parts[5]));
        movie.setTotalRatings(Integer.parseInt(parts[6]));
        movie.setAvailableCopies(Integer.parseInt(parts[7]));
        if (parts.length > 10) movie.setDescription(parts[10]);
        if (parts.length > 11) movie.setActive(Boolean.parseBoolean(parts[11]));
        if (parts.length > 12 && !parts[12].isEmpty()) movie.setPosterUrl(parts[12]);
        return movie;
    }
}
