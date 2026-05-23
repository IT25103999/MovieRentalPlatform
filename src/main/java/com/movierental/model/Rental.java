package com.movierental.model;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class Rental implements Serializable {
    private static final long serialVersionUID = 1L;

    private String rentalId;
    private String userId;
    private String movieId;
    private String movieTitle;
    private LocalDate rentDate;
    private LocalDate dueDate;
    private LocalDate returnDate;
    private double rentalPrice;
    private String status; // ACTIVE, COMPLETED, CANCELLED

    // Constructor
    public Rental(String rentalId, String userId, String movieId, String movieTitle,
                  int days, double rentalPrice) {
        this.rentalId = rentalId;
        this.userId = userId;
        this.movieId = movieId;
        this.movieTitle = movieTitle;
        this.rentDate = LocalDate.now();
        this.dueDate = LocalDate.now().plusDays(days);
        this.rentalPrice = rentalPrice;
        this.status = "ACTIVE";
        this.returnDate = null;
    }

    // ========== GETTERS ==========
    public String getRentalId() { return rentalId; }
    public String getUserId() { return userId; }
    public String getMovieId() { return movieId; }
    public String getMovieTitle() { return movieTitle; }
    public LocalDate getRentDate() { return rentDate; }
    public LocalDate getDueDate() { return dueDate; }
    public LocalDate getReturnDate() { return returnDate; }
    public double getRentalPrice() { return rentalPrice; }
    public String getStatus() { return status; }

    // ========== SETTERS ==========
    public void setRentalId(String rentalId) { this.rentalId = rentalId; }
    public void setUserId(String userId) { this.userId = userId; }
    public void setMovieId(String movieId) { this.movieId = movieId; }
    public void setMovieTitle(String movieTitle) { this.movieTitle = movieTitle; }
    public void setRentDate(LocalDate rentDate) { this.rentDate = rentDate; }
    public void setDueDate(LocalDate dueDate) { this.dueDate = dueDate; }
    public void setReturnDate(LocalDate returnDate) { this.returnDate = returnDate; }
    public void setRentalPrice(double rentalPrice) { this.rentalPrice = rentalPrice; }
    public void setStatus(String status) { this.status = status; }

    // ========== BUSINESS METHODS ==========
    public boolean isOverdue() {
        return status.equals("ACTIVE") && LocalDate.now().isAfter(dueDate);
    }

    public double calculateFine() {
        if (!isOverdue()) return 0;
        long daysLate = java.time.temporal.ChronoUnit.DAYS.between(dueDate, LocalDate.now());
        return daysLate * 1.0; // $1 per day late
    }

    public boolean extendRental(int extraDays) {
        if (status.equals("ACTIVE")) {
            this.dueDate = this.dueDate.plusDays(extraDays);
            return true;
        }
        return false;
    }

    public boolean cancelRental() {
        if (status.equals("ACTIVE") && rentDate.isAfter(LocalDate.now().minusDays(1))) {
            this.status = "CANCELLED";
            return true;
        }
        return false;
    }

    public String getFormattedRentDate() {
        return rentDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }

    public String getFormattedDueDate() {
        return dueDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }

    // ========== FILE STORAGE METHODS ==========
    @Override
    public String toString() {
        return rentalId + "|" + userId + "|" + movieId + "|" + movieTitle + "|" +
                rentDate + "|" + dueDate + "|" + (returnDate != null ? returnDate : "") + "|" +
                rentalPrice + "|" + status;
    }

    public static Rental fromString(String line) {
        String[] parts = line.split("\\|");
        if (parts.length < 9) {
            System.err.println("Invalid rental line: " + line);
            return null;
        }

        int days = 3; // default
        try {
            LocalDate rent = LocalDate.parse(parts[4]);
            LocalDate due = LocalDate.parse(parts[5]);
            days = (int) java.time.temporal.ChronoUnit.DAYS.between(rent, due);
        } catch (Exception e) {
            days = 3;
        }

        Rental rental = new Rental(parts[0], parts[1], parts[2], parts[3],
                days, Double.parseDouble(parts[7]));
        rental.rentDate = LocalDate.parse(parts[4]);
        rental.dueDate = LocalDate.parse(parts[5]);
        if (parts[6] != null && !parts[6].isEmpty()) {
            rental.returnDate = LocalDate.parse(parts[6]);
        }
        rental.status = parts[8];
        return rental;
    }
}
