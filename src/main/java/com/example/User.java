package com.example;

public class User {
	private int userId;
	private String username;
	private String password;
	private byte[] profilePic;
	private String description;
	private boolean isAdmin;
	private int zoom;
	private int location_id;
	
	public User(int userId, String username, String password, String description, boolean isAdmin, int zoom, int location_id) {
		this.setUserId(userId);
		this.setUsername(username);
		this.setPassword(password);
		this.setDescription(description != null ? description : username + " has not described themself yet.");
		this.setAdmin(isAdmin);
		this.setZoom(zoom);
		this.setLocation_id(location_id);
	}
	
	public User(int userId, String username, String password, String description, boolean isAdmin) {
		this.setUserId(userId);
		this.setUsername(username);
		this.setPassword(password);
		this.setDescription(description != null ? description : username + " has not described themself yet.");
		this.setAdmin(isAdmin);
	}
	
	public User(String username, String password, boolean isAdmin) {
		this.setUserId(userId);
		this.setUsername(username);
		this.setPassword(password);
		this.setDescription(description != null ? description : username + " has not described themself yet.");
		this.setAdmin(isAdmin);
	}
	
	public int getUserId() {
		return userId;
	}
	
	public void setUserId(int userId) {
		this.userId = userId;
	}
	
	public String getUsername() {
		return username;
	}
	
	public void setUsername(String username) {
		this.username = username;
	}
	
	public byte[] getProfilePic() {
		return profilePic;
	}
	
	public void setProfilePic(byte[] profilePic) {
		this.profilePic = profilePic;
	}
	
	public String getDescription() {
		return description;
	}
	
	public void setDescription(String description) {
		this.description = description;
	}
	
	public boolean isAdmin() {
		return isAdmin;
	}
	
	public void setAdmin(boolean isAdmin) {
		this.isAdmin = isAdmin;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public int getZoom() {
		return zoom;
	}

	public void setZoom(int zoom) {
		this.zoom = zoom;
	}

	public int getLocation_id() {
		return location_id;
	}

	public void setLocation_id(int location_id) {
		this.location_id = location_id;
	}
}