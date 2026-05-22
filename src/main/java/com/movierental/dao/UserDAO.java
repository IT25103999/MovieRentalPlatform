package com.movierental.dao;

import com.movierental.model.User;
import java.io.*;
import java.util.*;

public class UserDAO {
    private String filePath;

    public UserDAO(String filePath) {
        this.filePath = filePath;
        try {
            File file = new File(filePath);
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                file.createNewFile();
                createDefaultAdmin();
                createSampleUser();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void createDefaultAdmin() throws IOException {
        User admin = new User(null, "admin", "admin123", "admin@movie.com",
                "System Admin", "ADMIN");
        createUser(admin);
    }

    private void createSampleUser() throws IOException {
        User user = new User(null, "john", "pass123", "john@email.com",
                "John Doe", "CUSTOMER");
        createUser(user);
    }

    public boolean createUser(User user) {
        try {
            if (getUserByUsername(user.getUsername()) != null) return false;
            String prefix = user.getUserType().equals("ADMIN") ? "ADM" : "USR";
            String nextId = FileHandler.getNextId(filePath, prefix);
            user.setUserId(nextId);
            FileHandler.appendLine(filePath, user.toString());
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public User getUserByUsername(String username) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                User user = User.fromString(line);
                if (user.getUsername().equals(username) && user.isActive()) {
                    return user;
                }
            }
        } catch (IOException e) {}
        return null;
    }

    public User getUserById(String userId) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                User user = User.fromString(line);
                if (user.getUserId().equals(userId) && user.isActive()) {
                    return user;
                }
            }
        } catch (IOException e) {}
        return null;
    }

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                User user = User.fromString(line);
                if (user.isActive()) users.add(user);
            }
        } catch (IOException e) {}
        return users;
    }

    /** Returns ALL users (active and inactive) for admin management views. */
    public List<User> getAllUsersAll() {
        List<User> users = new ArrayList<>();
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                if (!line.trim().isEmpty()) {
                    users.add(User.fromString(line));
                }
            }
        } catch (IOException e) {}
        return users;
    }

    public boolean updateUser(User user) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (int i = 0; i < lines.size(); i++) {
                User existing = User.fromString(lines.get(i));
                if (existing.getUserId().equals(user.getUserId())) {
                    lines.set(i, user.toString());
                    FileHandler.writeAllLines(filePath, lines);
                    return true;
                }
            }
        } catch (IOException e) {}
        return false;
    }

    public boolean deleteUser(String userId) {
        User user = getUserById(userId);
        if (user != null) {
            user.setActive(false);
            return updateUser(user);
        }
        return false;
    }

    public User validateLogin(String username, String password) {
        try {
            List<String> lines = FileHandler.readAllLines(filePath);
            for (String line : lines) {
                User user = User.fromString(line);
                if (user.getUsername().equals(username) &&
                        user.getPassword().equals(password) &&
                        user.isActive()) {
                    return user;
                }
            }
        } catch (IOException e) {}
        return null;
    }
}
