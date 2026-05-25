package com.movierental.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

private class RentalRequest {
    private String requestId;
    private String userId;
    private String movieId;
    private String movieTitle;
    private LocalDateTime requestTime;
    private String status;
    private int rentalDays;

    public RentalRequest(String requestId, String userId, String movieId,
                         String movieTitle, int rentalDays) {
        this.requestId = requestId;
        this.userId = userId;
        this.movieId = movieId;
        this.movieTitle = movieTitle;
        this.requestTime = LocalDateTime.now();
        this.status = "PENDING";
        this.rentalDays = rentalDays;
    }

    public String getRequestId() { return requestId; }
    public String getUserId() { return userId; }
    public String getMovieId() { return movieId; }
    public String getMovieTitle() { return movieTitle; }
    public LocalDateTime getRequestTime() { return requestTime; }
    public String getStatus() { return status; }
    public int getRentalDays() { return rentalDays; }

    public void setStatus(String status) { this.status = status; }

    public String getFormattedTime() {
        return requestTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    @Override
    public String toString() {
        return requestId + "|" + userId + "|" + movieId + "|" + movieTitle + "|" +
                requestTime + "|" + status + "|" + rentalDays;
    }

    public static RentalRequest fromString(String line) {
        String[] parts = line.split("\\|");
        RentalRequest req = new RentalRequest(parts[0], parts[1], parts[2],
                parts[3], Integer.parseInt(parts[6]));
        req.requestTime = LocalDateTime.parse(parts[4]);
        req.status = parts[5];
        return req;
    }
}
