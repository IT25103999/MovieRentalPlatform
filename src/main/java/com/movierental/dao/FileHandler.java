package com.movierental.dao;

import java.io.*;
import java.util.*;

public class FileHandler {

    public static List<String> readAllLines(String filePath) throws IOException {
        List<String> lines = new ArrayList<>();
        File file = new File(filePath);

        if (!file.exists()) {
            file.getParentFile().mkdirs();
            file.createNewFile();
            return lines;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    lines.add(line);
                }
            }
        }
        return lines;
    }

    public static void writeAllLines(String filePath, List<String> lines) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (String line : lines) {
                writer.write(line);
                writer.newLine();
            }
        }
    }

    public static void appendLine(String filePath, String line) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(line);
            writer.newLine();
        }
    }

    public static String getNextId(String filePath, String prefix) throws IOException {
        List<String> lines = readAllLines(filePath);
        int maxId = 0;

        for (String line : lines) {
            if (line.startsWith(prefix)) {
                String[] parts = line.split("\\|");
                if (parts.length > 0 && parts[0].startsWith(prefix)) {
                    try {
                        int id = Integer.parseInt(parts[0].substring(prefix.length()));
                        if (id > maxId) maxId = id;
                    } catch (NumberFormatException e) {}
                }
            }
        }
        return prefix + String.format("%03d", maxId + 1);
    }
}
