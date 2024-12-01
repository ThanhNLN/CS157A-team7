package com.example;

import java.util.Date;

public class PlantSighting {
    private String name; // Plant name
    private int plantId; // Plant ID
    private String scientificName; // Scientific name of the plant
    private String description; // Description of the plant
    private boolean poisonous; // Is the plant poisonous
    private boolean invasive; // Is the plant invasive
    private boolean endangered; // Is the plant endangered
    private String username; // User who reported the sighting
    private Date date; // Date of the sighting
    private String locationName; // Name of the location
    private double latitude; // Latitude of the sighting
    private double longitude; // Longitude of the sighting

    // Constructor
    public PlantSighting(String name, int plantId, String scientificName, String description, boolean poisonous,
                         boolean invasive, boolean endangered, String username, Date date, String locationName,
                         double latitude, double longitude) {
        this.name = name;
        this.plantId = plantId;
        this.scientificName = scientificName;
        this.description = description;
        this.poisonous = poisonous;
        this.invasive = invasive;
        this.endangered = endangered;
        this.username = username;
        this.date = date;
        this.locationName = locationName;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    // Getters and Setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getPlantId() {
        return plantId;
    }

    public void setPlantId(int plantId) {
        this.plantId = plantId;
    }

    public String getScientificName() {
        return scientificName;
    }

    public void setScientificName(String scientificName) {
        this.scientificName = scientificName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isPoisonous() {
        return poisonous;
    }

    public void setPoisonous(boolean poisonous) {
        this.poisonous = poisonous;
    }

    public boolean isInvasive() {
        return invasive;
    }

    public void setInvasive(boolean invasive) {
        this.invasive = invasive;
    }

    public boolean isEndangered() {
        return endangered;
    }

    public void setEndangered(boolean endangered) {
        this.endangered = endangered;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    @Override
    public String toString() {
        return "PlantSighting{" +
                "name='" + name + '\'' +
                ", plantId=" + plantId +
                ", scientificName='" + scientificName + '\'' +
                ", description='" + description + '\'' +
                ", poisonous=" + poisonous +
                ", invasive=" + invasive +
                ", endangered=" + endangered +
                ", username='" + username + '\'' +
                ", date=" + date +
                ", locationName='" + locationName + '\'' +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                '}';
    }
}
