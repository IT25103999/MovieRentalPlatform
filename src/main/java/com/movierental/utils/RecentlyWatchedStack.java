package com.movierental.utils;

import com.movierental.model.Movie;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

/**
 * Data Structure: Stack
 * Manages a per-user "recently watched" history using a LIFO Stack.
 * The most recently viewed movie is always on top (index 0 when displayed).
 * Stored in the HTTP session so it persists across page loads for the session lifetime.
 */
public class RecentlyWatchedStack implements Serializable {

    private static final long serialVersionUID = 1L;
    private static final int MAX_SIZE = 10;
    private static final String SESSION_KEY = "recentlyWatchedStack";

    // Core data structure: Java's Stack (LIFO)
    private final Stack<String> movieIdStack = new Stack<>();

    /**
     * Push a movie ID onto the stack when a user views a movie.
     * If the movie is already in the stack it is removed first (no duplicates).
     * If the stack exceeds MAX_SIZE the bottom element is trimmed.
     */
    public void push(String movieId) {
        if (movieId == null || movieId.isEmpty()) return;

        // Remove duplicate if present (so it moves to top)
        movieIdStack.remove(movieId);

        // Push to top of stack
        movieIdStack.push(movieId);

        // Trim oldest entry from bottom if over capacity
        if (movieIdStack.size() > MAX_SIZE) {
            movieIdStack.remove(0); // remove bottom (oldest)
        }
    }

    /**
     * Peek at the most recently watched movie ID without removing it.
     */
    public String peekLatest() {
        return movieIdStack.isEmpty() ? null : movieIdStack.peek();
    }

    /**
     * Return the stack contents as an ordered list (most recent first)
     * by iterating from top to bottom.
     */
    public List<String> getMovieIdsRecentFirst() {
        List<String> result = new ArrayList<>();
        // Iterate from top (most recent) to bottom (oldest)
        for (int i = movieIdStack.size() - 1; i >= 0; i--) {
            result.add(movieIdStack.get(i));
        }
        return result;
    }

    /**
     * Resolve movie IDs to Movie objects using a lookup list,
     * preserving the most-recent-first order.
     */
    public List<Movie> resolveMovies(List<Movie> allMovies) {
        List<String> ids = getMovieIdsRecentFirst();
        List<Movie> result = new ArrayList<>();
        for (String id : ids) {
            for (Movie m : allMovies) {
                if (m.getMovieId().equals(id)) {
                    result.add(m);
                    break;
                }
            }
        }
        return result;
    }

    public int size() {
        return movieIdStack.size();
    }

    public boolean isEmpty() {
        return movieIdStack.isEmpty();
    }

    public void clear() {
        movieIdStack.clear();
    }

    /** Retrieve (or create) the stack stored in the session. */
    public static RecentlyWatchedStack fromSession(javax.servlet.http.HttpSession session) {
        if (session == null) return new RecentlyWatchedStack();
        RecentlyWatchedStack stack =
                (RecentlyWatchedStack) session.getAttribute(SESSION_KEY);
        if (stack == null) {
            stack = new RecentlyWatchedStack();
            session.setAttribute(SESSION_KEY, stack);
        }
        return stack;
    }

    /** Save the stack back into the session (call after push/pop). */
    public void saveToSession(javax.servlet.http.HttpSession session) {
        if (session != null) {
            session.setAttribute(SESSION_KEY, this);
        }
    }
}
