package com.movierental.utils;

import com.movierental.model.Movie;
import java.util.ArrayList;
import java.util.List;

/**
 * Algorithm: Bubble Sort
 * Sorts a list of movies by rating (descending) using the Bubble Sort algorithm.
 *
 * How Bubble Sort works:
 *  - Makes repeated passes through the list.
 *  - On each pass, compares adjacent elements and swaps them if they are in
 *    the wrong order (lower rating before higher rating).
 *  - After each pass, the next-largest element "bubbles up" to its correct position.
 *  - Stops early if a full pass completes with no swaps (already sorted).
 *
 * Time complexity:  O(n²) worst/average,  O(n) best (already sorted).
 * Space complexity: O(n) — works on a copy of the input list.
 */
public class BubbleSortUtil {

    /**
     * Sort movies by rating descending (highest rated first).
     * Returns a new list; the original is not modified.
     */
    public static List<Movie> sortByRatingDescending(List<Movie> movies) {
        List<Movie> sorted = new ArrayList<>(movies);
        int n = sorted.size();

        for (int pass = 0; pass < n - 1; pass++) {
            boolean swapped = false;

            // Each pass bubbles the largest unsorted rating to the front
            for (int i = 0; i < n - 1 - pass; i++) {
                Movie current = sorted.get(i);
                Movie next    = sorted.get(i + 1);

                // If current has a LOWER rating than next, swap them
                if (current.getRating() < next.getRating()) {
                    sorted.set(i,     next);
                    sorted.set(i + 1, current);
                    swapped = true;
                }
            }

            // Early exit: if no swaps occurred the list is already sorted
            if (!swapped) break;
        }

        return sorted;
    }

    /**
     * Sort movies by rating ascending (lowest rated first).
     */
    public static List<Movie> sortByRatingAscending(List<Movie> movies) {
        List<Movie> sorted = new ArrayList<>(movies);
        int n = sorted.size();

        for (int pass = 0; pass < n - 1; pass++) {
            boolean swapped = false;

            for (int i = 0; i < n - 1 - pass; i++) {
                Movie current = sorted.get(i);
                Movie next    = sorted.get(i + 1);

                if (current.getRating() > next.getRating()) {
                    sorted.set(i,     next);
                    sorted.set(i + 1, current);
                    swapped = true;
                }
            }

            if (!swapped) break;
        }

        return sorted;
    }
}
