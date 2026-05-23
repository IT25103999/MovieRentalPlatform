package com.movierental.model;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class Review {
    private String reviewId;
    private String movieId;
    private String userId;
    private String username;
    private int rating;
    private String comment;
    private LocalDate reviewDate;
    private boolean isEdited;

    public Review(String reviewId, String movieId, String userId,
                  String username, int rating, String comment) {
        this.reviewId = reviewId;
        this.movieId = movieId;
        this.userId = userId;
        this.username = username;
        this.rating = rating;
        this.comment = comment;
        this.reviewDate = LocalDate.now();
        this.isEdited = false;
    }

    public String getReviewId() { return reviewId; }
    public String getMovieId() { return movieId; }
    public String getUserId() { return userId; }
    public String getUsername() { return username; }
    public int getRating() { return rating; }
    public String getComment() { return comment; }
    public LocalDate getReviewDate() { return reviewDate; }
    public boolean isEdited() { return isEdited; }

    public void setRating(int rating) { this.rating = rating; }
    public void setComment(String comment) { this.comment = comment; }
    public void setEdited(boolean edited) { this.isEdited = edited; }

    public String getStarRating() {
        StringBuilder stars = new StringBuilder();
        for (int i = 0; i < rating; i++) stars.append("★");
        for (int i = rating; i < 5; i++) stars.append("☆");
        return stars.toString();
    }

    public boolean isOlderThan(int years) {
        return reviewDate.isBefore(LocalDate.now().minusYears(years));
    }

    public String getFormattedDate() {
        return reviewDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }

    @Override
    public String toString() {
        return reviewId + "|" + movieId + "|" + userId + "|" + username + "|" +
                rating + "|" + comment + "|" + reviewDate + "|" + isEdited;
    }

    public static Review fromString(String line) {
        // Limit to 8 parts so any "|" inside the comment (index 5) doesn't get split
        String[] parts = line.split("\\|", 8);
        Review review = new Review(parts[0], parts[1], parts[2], parts[3],
                Integer.parseInt(parts[4]), parts[5]);
        review.reviewDate = LocalDate.parse(parts[6]);
        review.isEdited = Boolean.parseBoolean(parts[7]);
        return review;
    }
}
