package com.movierental.dao;

import com.movierental.model.Review;
import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

public class ReviewDAO {
    private String filePath;
    private MovieDAO movieDAO;

    public ReviewDAO(String filePath, MovieDAO movieDAO) {
        this.filePath = filePath;
        this.movieDAO = movieDAO;
        try {
            File file = new File(filePath);
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                file.createNewFile();
            }
        } catch (IOException e) {}
    }

    public boolean addReview(Review review) {
        try {
            String reviewId = "REV" + System.currentTimeMillis();
            java.lang.reflect.Field field = Review.class.getDeclaredField("reviewId");
            field.setAccessible(true);
            field.set(review, reviewId);
            FileHandler.appendLine(filePath, review.toString());
            movieDAO.updateMovieRating(review.getMovieId(), review.getRating());
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Review> getReviewsByMovie(String movieId) {
        List<Review> reviews = new ArrayList<>();
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                Review review = Review.fromString(line);
                if (review.getMovieId().equals(movieId)) {
                    reviews.add(review);
                }
            }
        } catch (IOException e) {}
        return reviews;
    }

    public double getAverageRating(String movieId) {
        List<Review> reviews = getReviewsByMovie(movieId);
        if (reviews.isEmpty()) return 0;
        return reviews.stream().mapToInt(Review::getRating).average().orElse(0);
    }

    public Review getReviewByUserAndMovie(String userId, String movieId) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                Review review = Review.fromString(line);
                if (review.getUserId().equals(userId) && review.getMovieId().equals(movieId)) {
                    return review;
                }
            }
        } catch (IOException e) {}
        return null;
    }

    public List<Review> getReviewsByUser(String userId) {
        List<Review> userReviews = new ArrayList<>();
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                Review review = Review.fromString(line);
                if (review.getUserId().equals(userId)) {
                    userReviews.add(review);
                }
            }
        } catch (IOException e) {}
        return userReviews;
    }

    public Review getReviewById(String reviewId) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                Review review = Review.fromString(line);
                if (review.getReviewId().equals(reviewId)) {
                    return review;
                }
            }
        } catch (IOException e) {}
        return null;
    }

    public boolean updateReview(String reviewId, int newRating, String newComment) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (int i = 0; i < lines.size(); i++) {
                Review review = Review.fromString(lines.get(i));
                if (review.getReviewId().equals(reviewId)) {
                    review.setRating(newRating);
                    review.setComment(newComment);
                    review.setEdited(true);
                    lines.set(i, review.toString());
                    FileHandler.writeAllLines(filePath, lines);
                    movieDAO.updateMovieRating(review.getMovieId(), newRating);
                    return true;
                }
            }
        } catch (IOException e) {}
        return false;
    }

    public boolean deleteReview(String reviewId) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (int i = 0; i < lines.size(); i++) {
                Review review = Review.fromString(lines.get(i));
                if (review.getReviewId().equals(reviewId)) {
                    lines.remove(i);
                    FileHandler.writeAllLines(filePath, lines);
                    return true;
                }
            }
        } catch (IOException e) {}
        return false;
    }

    public int deleteReviewsOlderThan(int years) {
        int deleted = 0;
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            List<String> newLines = new ArrayList<>();
            for (String line : lines) {
                Review review = Review.fromString(line);
                if (!review.isOlderThan(years)) {
                    newLines.add(line);
                } else {
                    deleted++;
                }
            }
            FileHandler.writeAllLines(filePath, newLines);
        } catch (IOException e) {}
        return deleted;
    }

    public List<Review> getAllReviews() {
        List<Review> reviews = new ArrayList<>();
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                reviews.add(Review.fromString(line));
            }
        } catch (IOException e) {}
        return reviews;
    }

    public boolean hasUserReviewed(String userId, String movieId) {
        return getReviewByUserAndMovie(userId, movieId) != null;
    }
}
