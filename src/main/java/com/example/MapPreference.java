package com.example;

public class MapPreference {
	private int preferenceId;
	private int zoom;
	
	public MapPreference(int preferenceId, int zoom) {
		this.setPreferenceId(preferenceId);
		this.setZoom(zoom);
	}

	public int getPreferenceId() {
		return preferenceId;
	}

	public void setPreferenceId(int preferenceId) {
		this.preferenceId = preferenceId;
	}

	public int getZoom() {
		return zoom;
	}

	public void setZoom(int zoom) {
		this.zoom = zoom;
	}
}