package com.movierental.utils;

import com.movierental.model.Movie;
import com.movierental.model.RentalRequest;
import com.movierental.dao.FileHandler;
import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

/**
 * File-backed FIFO queue for rental requests.
 *
 * Every public method reads from / writes to the file directly —
 * there is NO in-memory state.  This means the queue is always
 * consistent regardless of how many servlet instances exist or
 * when Tomcat was last restarted.
 */
public class QueueManager {

    private final String filePath;

    public QueueManager(String filePath) {
        this.filePath = filePath;
        // Ensure the file exists
        File f = new File(filePath);
        if (!f.exists()) {
            f.getParentFile().mkdirs();
            try { f.createNewFile(); } catch (IOException e) { e.printStackTrace(); }
        }
    }

    // -----------------------------------------------------------------------
    // Public API
    // -----------------------------------------------------------------------

    /** Add a new PENDING request to the end of the queue (append to file). */
    public void addRequest(RentalRequest request) {
        try {
            FileHandler.appendLine(filePath, request.toString());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Find the first PENDING request in the file, mark it PROCESSED,
     * rewrite the file, and return it.  Returns null if the queue is empty.
     */
    public RentalRequest processNext() {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (int i = 0; i < lines.size(); i++) {
                String line = lines.get(i);
                if (line.trim().isEmpty()) continue;
                RentalRequest r = RentalRequest.fromString(line);
                if ("PENDING".equals(r.getStatus())) {
                    r.setStatus("PROCESSED");
                    lines.set(i, r.toString());
                    FileHandler.writeAllLines(filePath, lines);
                    return r;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Returns all PENDING requests (the live queue), in FIFO order.
     * Reads fresh from disk every call.
     */
    public List<RentalRequest> getAllRequests() {
        return getAllRequestsFromFile().stream()
                .filter(r -> "PENDING".equals(r.getStatus()))
                .collect(Collectors.toList());
    }

    /**
     * Returns ALL requests from the file (PENDING + PROCESSED + any other status).
     * Use this for admin history views.
     */
    public List<RentalRequest> getAllRequestsFromFile() {
        List<RentalRequest> all = new ArrayList<>();
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                if (!line.trim().isEmpty()) {
                    all.add(RentalRequest.fromString(line));
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return all;
    }

    /**
     * Remove a request by ID regardless of status.
     * Returns true if the record was found and deleted.
     */
    public boolean removeRequest(String requestId) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            boolean found = false;
            List<String> updated = new ArrayList<>();
            for (String line : lines) {
                if (!line.trim().isEmpty()) {
                    RentalRequest r = RentalRequest.fromString(line);
                    if (r.getRequestId().equals(requestId)) {
                        found = true; // skip (delete)
                    } else {
                        updated.add(line);
                    }
                }
            }
            if (found) {
                FileHandler.writeAllLines(filePath, updated);
                return true;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Number of PENDING requests currently in the queue. */
    public int size() {
        return getAllRequests().size();
    }

    public boolean isEmpty() {
        return getAllRequests().isEmpty();
    }

    /** Delete every record from the file. */
    public void clearQueue() {
        try {
            FileHandler.writeAllLines(filePath, new ArrayList<>());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // -----------------------------------------------------------------------
    // Utility: insertion-sort movies by rating descending
    // -----------------------------------------------------------------------
    public static List<Movie> insertionSortByRating(List<Movie> movies) {
        List<Movie> sorted = new ArrayList<>(movies);
        for (int i = 1; i < sorted.size(); i++) {
            Movie key = sorted.get(i);
            int j = i - 1;
            while (j >= 0 && sorted.get(j).getRating() < key.getRating()) {
                sorted.set(j + 1, sorted.get(j));
                j--;
            }
            sorted.set(j + 1, key);
        }
        return sorted;
    }
}
