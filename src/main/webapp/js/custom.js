let map;
let clickedPosition;
let AdvancedMarkerElement;
const markersMap = new Map(); // Keeps track of markers by coordinates
let infoWindow; // Single InfoWindow instance
//let pollen = "TREE_UPI";

class PollenMapType {
	constructor(tileSize, apiKey) {
		this.tileSize = tileSize;
		this.maxZoom = 16;
		this.minZoom = 3;
		this.apiKey = apiKey;
	}

	getTile(coord, zoom, ownerDocument) {
		const img = ownerDocument.createElement("img");
		const mapType = pollen;
		const normalizedCoord = this.getNormalizedCoord(coord, zoom);
		if (!normalizedCoord) {
			return null;
		}
		const { x, y } = normalizedCoord;
		const key = this.apiKey;

		img.style.opacity = 0.8;
		img.style.width = this.tileSize.width + "px";
		img.style.height = this.tileSize.height + "px";
		img.src = `https://pollen.googleapis.com/v1/mapTypes/${mapType}/heatmapTiles/${zoom}/${x}/${y}?key=${key}`;
		return img;
	}

	releaseTile(tile) {}

	getNormalizedCoord(coord, zoom) {
		let { x, y } = coord;
		const tileRange = 1 << zoom;

		if (y < 0 || y >= tileRange) {
			return null;
		}

		x = ((x % tileRange) + tileRange) % tileRange;
		return { x, y };
	}
}

function updatePollenMapType(map, apiKey) {
	map.overlayMapTypes.removeAt(0);
	const newPollenMapType = new PollenMapType(new google.maps.Size(256, 256), apiKey);
	map.overlayMapTypes.insertAt(0, newPollenMapType);
}

function attachInfoWindow(marker, content) {
	marker.addListener('click', function () {
		if (infoWindow) {
			infoWindow.close();
		}

		infoWindow = new google.maps.InfoWindow({
			content: content
		});

		google.maps.event.addListener(infoWindow, 'closeclick', function () {
			infoWindow = null;
		});

		infoWindow.open(map, marker);
	});
}

async function initMap() {
	const position = { lat: 37.3352, lng: -121.8811 };
	//@ts-ignore
	const { Map } = await google.maps.importLibrary("maps");
	AdvancedMarkerElement = (await google.maps.importLibrary("marker")).AdvancedMarkerElement;

	map = new Map(document.getElementById("map"), {
		zoom: 16,
		center: position,
		mapId: "DEMO_MAP_ID",
	});

	const marker = new AdvancedMarkerElement({
		map: map,
		position: position,
		title: "SJSU",
	});

	attachInfoWindow(marker, `
		<div>
			<h3>SJSU</h3>
			<p>Location: San Jose State University</p>
			<p>Reported by: Admin</p>
		</div>
	`);

	map.addListener('click', function (event) {
		clickedPosition = event.latLng;
		openModal(clickedPosition);
	});

	const apiKey = window.GOOGLE_MAPS_API_KEY;

	if (!apiKey) {
		console.error("Google Maps API key is not found.");
		return;
	}

	updateMapWithSightings();
}

async function updateMapWithSightings() {
	const searchQuery = getSearchQuery(); // Get search query from the search bar

	try {
		// Fetch all sightings
		const response = await fetch("/myFlorabase/getSightings");
		const sightings = await response.json();
		console.log(sightings);
		let sightingsArray = [];

		let filterArray = [];
		if (!searchQuery) {
			const filterResponse = await fetch("/myFlorabase/GetFilterServlet", {
				method: 'GET'
			});
			filterArray = await filterResponse.json();
			console.log(filterArray);
		}
						
		// Remove any existing markers from the map
		markersMap.forEach(markerData => {
			markerData.marker.setMap(null);
		});
		markersMap.clear();

		// Add markers based on the fetched sightings
		for (const sighting of sightings) {
			try {
				const infoResponse = await fetch(`/myFlorabase/getSightingInfo?userId=${sighting.userId}&plantId=${sighting.plantId}&locationId=${sighting.locationId}`, {
					method: 'GET',
				});
				const info = await infoResponse.json();
				console.log(info);
				sightingsArray.push(info);

				const location = { lat: info[2].latitude, lng: info[2].longitude };
				const locationKey = `${location.lat},${location.lng}`;
				const plantName = info[1].name;
				const sightingDescription = sighting.description;
				const plantDescription = info[1].description;

				// Filter based on search query
				if (searchQuery && !plantName.toLowerCase().includes(searchQuery.toLowerCase())) {
					continue;
				}
				
				if (!searchQuery && filterArray.length > 0 && filterArray.includes(plantName)) {
					console.log(`Filtered out plant: ${plantName}`);
					continue;
				}

				let locationHeader = `
					<div>
						<h3>Location: ${info[2].name} (Location ID: ${info[2].locationId})</h3>
						<p>Latitude: ${info[2].latitude}, Longitude: ${info[2].longitude}</p>
						<hr/>
					</div>`;

				let infoContent = `
					<div>
						<h3>Plant Name: ${plantName}</h3>
						<p>Scientific Name: ${info[1].scientificName}</p>
						<p>Reported By: ${info[0].username}</p>
						<p>Sighting Description: ${sightingDescription}</p>
						<p>Plant Description: ${plantDescription}</p>
					</div>`;

				if (sighting.photo && sighting.photo.length > 0) {
					const photoBase64 = arrayBufferToBase64(sighting.photo);
					infoContent += `<img src="data:image/jpeg;base64,${photoBase64}" alt="Sighting Photo" style="max-width: 200px; max-height: 200px;"/>`;
				}

				// Combine and remove existing marker if there's already one at this location
				if (markersMap.has(locationKey)) {
					const existingMarkerData = markersMap.get(locationKey);
					const combinedContent = existingMarkerData.infoContent + '<hr/>' + infoContent;
					existingMarkerData.marker.setMap(null);
					markersMap.delete(locationKey);
					infoContent = combinedContent;
				} else {
					infoContent = locationHeader + infoContent;
				}

				// Create and store a new marker
				const newMarker = new AdvancedMarkerElement({
					map: map,
					position: location,
					title: plantName,
				});
				console.log('Marker added for location:', info[2].name);

				markersMap.set(locationKey, {
					marker: newMarker,
					infoContent: infoContent
				});
				attachInfoWindow(newMarker, infoContent);
			} catch (error) {
				console.error("Issue with fetching from getSightingInfo:", error);
			}
		}
		console.log("Parsed Sightings Array: ", sightingsArray);
	} catch (error) {
		console.error("Issue with fetching sightings:", error);
	}
	
	// Commented out the pollen-related map overlay initialization
	// const pollenMapType = new PollenMapType(new google.maps.Size(256, 256), apiKey);
	// map.overlayMapTypes.insertAt(0, pollenMapType);

	// Commented out pollen map type update listeners
	/*
	document.getElementById("tree").addEventListener("click", function() {
		pollen = "TREE_UPI";
		updatePollenMapType(map, apiKey);
	});
	document.getElementById("grass").addEventListener("click", function() {
		pollen = "GRASS_UPI";
		updatePollenMapType(map, apiKey);
	});
	document.getElementById("weed").addEventListener("click", function() {
		pollen = "WEED_UPI";
		updatePollenMapType(map, apiKey);
	});
	document.getElementById("none").addEventListener("click", function() {
		map.overlayMapTypes.removeAt(0);
	});
	*/
}

function getSearchQuery() {
	const searchBar = document.getElementById("searchBar");
	return searchBar ? searchBar.value : "";
}

document.getElementById("searchBar").addEventListener("keyup", function (event) {
	if (event.key === "Enter") {
		updateMapWithSightings();
	}
});

// Helper function to convert byte array to base64 string
function arrayBufferToBase64(buffer) {
	let binary = '';
	const bytes = new Uint8Array(buffer);
	for (let i = 0; i < bytes.byteLength; i++) {
		binary += String.fromCharCode(bytes[i]);
	}
	return btoa(binary);
}

window.initMap = initMap;
console.log("bruh1");
initMap();