package com.movierental.dao;

import com.movierental.model.Rental;
import java.io.*;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

public class RentalDAO {
    private String filePath;
    private String movieFilePath;

    public RentalDAO(String filePath, String movieFilePath) {
        this.filePath = filePath;
        this.movieFilePath = movieFilePath;
        try {
            File file = new File(filePath);
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                file.createNewFile();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // CREATE - Add new rental
    public boolean createRental(Rental rental) {
        try {
            // Generate unique rental ID
            String rentalId = "RENT" + System.currentTimeMillis();

            // Use reflection to set rentalId (since it's private)
            java.lang.reflect.Field field = Rental.class.getDeclaredField("rentalId");
            field.setAccessible(true);
            field.set(rental, rentalId);

            // Append to file
            FileHandler.appendLine(filePath, rental.toString());
            System.out.println("Rental saved: " + rentalId + " - " + rental.getMovieTitle());
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - Get all rentals
    public List<Rental> getAllRentals() {
        List<Rental> rentals = new ArrayList<>();
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                if (!line.trim().isEmpty()) {
                    Rental rental = Rental.fromString(line);
                    if (rental != null) rentals.add(rental);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return rentals;
    }

    // READ - Get rentals by user ID
    public List<Rental> getUserRentalHistory(String userId) {
        return getAllRentals().stream()
                .filter(r -> r.getUserId().equals(userId))
                .sorted((a, b) -> b.getRentDate().compareTo(a.getRentDate()))
                .collect(Collectors.toList());
    }

    // READ - Get active rentals for a user
    public List<Rental> getActiveRentals(String userId) {
        return getUserRentalHistory(userId).stream()
                .filter(r -> r.getStatus().equals("ACTIVE"))
                .collect(Collectors.toList());
    }

    // READ - Get rental by ID
    public Rental getRentalById(String rentalId) {
        return getAllRentals().stream()
                .filter(r -> r.getRentalId().equals(rentalId))
                .findFirst()
                .orElse(null);
    }

    // UPDATE - Update rental
    public boolean updateRental(Rental rental) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (int i = 0; i < lines.size(); i++) {
                Rental existing = Rental.fromString(lines.get(i));
                if (existing.getRentalId().equals(rental.getRentalId())) {
                    lines.set(i, rental.toString());
                    FileHandler.writeAllLines(filePath, lines);
                    return true;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    // UPDATE - Return a rental
    public boolean returnRental(String rentalId) {
        Rental rental = getRentalById(rentalId);
        if (rental != null && rental.getStatus().equals("ACTIVE")) {
            rental.setReturnDate(LocalDate.now());
            rental.setStatus("COMPLETED");

            // Return the movie copy
            MovieDAO movieDAO = new MovieDAO(movieFilePath);
            movieDAO.returnMovie(rental.getMovieId());

            return updateRental(rental);
        }
        return false;
    }

    // UPDATE - Extend rental period
    public boolean extendRental(String rentalId, int extraDays) {
        Rental rental = getRentalById(rentalId);
        if (rental != null && rental.getStatus().equals("ACTIVE")) {
            boolean extended = rental.extendRental(extraDays);
            if (extended) {
                return updateRental(rental);
            }
        }
        return false;
    }

    // UPDATE - Cancel rental
    public boolean cancelRental(String rentalId) {
        Rental rental = getRentalById(rentalId);
        if (rental != null && rental.getStatus().equals("ACTIVE")) {
            // Only allow cancellation if rented within last day
            if (rental.getRentDate().isAfter(LocalDate.now().minusDays(1))) {
                rental.setStatus("CANCELLED");

                // Return the movie copy
                MovieDAO movieDAO = new MovieDAO(movieFilePath);
                movieDAO.returnMovie(rental.getMovieId());

                return updateRental(rental);
            }
        }
        return false;
    }

    // Helper - Get active rentals count
    public long getActiveRentalsCount() {
        return getAllRentals().stream()
                .filter(r -> r.getStatus().equals("ACTIVE"))
                .count();
    }

    // Helper - Get total revenue
    public double getTotalRevenue() {
        return getAllRentals().stream()
                .filter(r -> r.getStatus().equals("COMPLETED"))
                .mapToDouble(Rental::getRentalPrice)
                .sum();
    }

    // Helper - Get most popular movies
    public Map<String, Long> getMostPopularMovies() {
        return getAllRentals().stream()
                .filter(r -> r.getStatus().equals("COMPLETED") || r.getStatus().equals("ACTIVE"))
                .collect(Collectors.groupingBy(Rental::getMovieTitle, Collectors.counting()));
    }
}
