package com.movierental.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private String userId;
    private String username;
    private String password;
    private String email;
    private String fullName;
    private String phone;
    private String address;
    private String userType;
    private LocalDateTime regDate;
    private boolean active;

    public User(String userId, String username, String password, String email,
                String fullName, String userType) {
        this.userId = userId;
        this.username = username;
        this.password = password;
        this.email = email;
        this.fullName = fullName;
        this.userType = userType;
        this.regDate = LocalDateTime.now();
        this.active = true;
        this.phone = "";
        this.address = "";
    }

    // Getters
    public String getUserId() { return userId; }
    public String getUsername() { return username; }
    public String getPassword() { return password; }
    public String getEmail() { return email; }
    public String getFullName() { return fullName; }
    public String getPhone() { return phone; }
    public String getAddress() { return address; }
    public String getUserType() { return userType; }
    public LocalDateTime getRegDate() { return regDate; }
    public boolean isActive() { return active; }

    // Setters
    public void setUserId(String userId) { this.userId = userId; }
    public void setUsername(String username) { this.username = username; }
    public void setPassword(String password) { this.password = password; }
    public void setEmail(String email) { this.email = email; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public void setPhone(String phone) { this.phone = phone; }
    public void setAddress(String address) { this.address = address; }
    public void setUserType(String userType) { this.userType = userType; }
    public void setActive(boolean active) { this.active = active; }

    @Override
    public String toString() {
        return userId + "|" + username + "|" + password + "|" + email + "|" +
                fullName + "|" + (phone != null ? phone : "") + "|" +
                (address != null ? address : "") + "|" + userType + "|" +
                regDate + "|" + active;
    }

    public static User fromString(String line) {
        String[] parts = line.split("\\|");
        User user = new User(parts[0], parts[1], parts[2], parts[3],
                parts[4], parts[7]);
        if (parts.length > 5) user.setPhone(parts[5]);
        if (parts.length > 6) user.setAddress(parts[6]);
        // Restore regDate from file (parts[8]) instead of defaulting to now()
        if (parts.length > 8 && !parts[8].isEmpty()) {
            try {
                user.regDate = java.time.LocalDateTime.parse(parts[8]);
            } catch (Exception e) {
                // keep the now() default if parse fails
            }
        }
        if (parts.length > 9) user.active = Boolean.parseBoolean(parts[9]);
        return user;
    }
}
