<%@ page
	import="java.sql.*, java.util.Properties, com.google.gson.Gson, java.io.FileInputStream, java.io.IOException, java.util.HashMap, java.util.List, java.util.ArrayList, com.example.Sighting, com.example.User, com.example.Plant, java.util.Date"%>
<%
String apiKey = System.getenv("GOOGLE_MAPS_API_KEY");
HttpSession curSession = request.getSession(false);
User user = (User) curSession.getAttribute("user");
String userJson = new Gson().toJson(user);
%>
<!DOCTYPE html>
<html>
<head>
<title>Admin Page</title>
<!-- Link to External CSS -->
<link rel="icon" href="assets/myFlorabase_Logo_No_Text.svg"
	type="image/svg">
<link rel="stylesheet" type="text/css" href="./css/modals.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap"
	rel="stylesheet">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
	<jsp:include page="WEB-INF/components/header.jsp"></jsp:include>
	<div id="sightingsPage" class="adminPage">
		<h1 id="flaggedSightingsTitle" class="pageTitle">Investigate
			Flagged Sightings</h1>
		<div id="sightingsList"></div>
		<!-- Modal Structure -->
		<jsp:include page="WEB-INF/components/modal.jsp"></jsp:include>
		<div id="popupContainer"></div>
	</div>

	<script src="./js/buttons.js"></script>
	<script src="./js/modal.js"></script>
	<script>
	window.addEventListener("load", function() {
        var sightingsListContainer = document.getElementById('sightingsList');
        fetch("/myFlorabase/getFlaggedSightings")
        .then(response => {
          return response.json();
        })
        .then(sightings => {
          console.log(sightings);  
          if (sightings.length === 0) {
        	  const noFlaggedSightingsMsg = document.createElement('p');
        	  noFlaggedSightingsMsg.textContent = "There are currently no flagged sightings.";
        	  const sightingsList = document.getElementById("sightingsList");
        	  sightingsList.appendChild(noFlaggedSightingsMsg);
          } else {
        	  sightings.forEach(sighting => {
            	  fetch("/myFlorabase/getSightingInfo?userId=" + sighting.userId + "&plantId=" + sighting.plantId + "&locationId=" + sighting.locationId, {
            		  method: 'GET',
            		})
            	  .then(response => {
            		  return response.json();
            	  })
            	  .then(info => {
            		  console.log(info);
            		  // info[0] = user, info[1] = plant, info[2] = location
            		  fetch("/myFlorabase/getFlaggedReason?sightingId=" + sighting.sightingId, {
            			  method: 'GET'
            			  })
            		  .then(response => {
            			  return response.text()
            		  })
            		  .then(reason => {
            			  console.log(reason);
            			  const curUser = <%=userJson%>;
            			  console.log(info);
            			  const sightingComponent = createSighting(sighting, info[0], info[1], info[2], curUser, reason);
                    	  sightingsListContainer.appendChild(sightingComponent);
            		  })
            		  })
            	  })
          }
          })
        })
		
        
        function createSighting(sighting, user, plant, location, curUser, reason) {
		console.log(user);
        	const sightingComponent = document.createElement('div');
        	const headerContainer = document.createElement('div');
        	  sightingComponent.classList.add('prevent-select', 'sightings-component');
        	  const container = document.createElement('span');
        	  headerContainer.classList.add('header-container');

        	  const sightingPhoto = document.createElement('img');
        	  sightingPhoto.src = "/myFlorabase/getImage?condition=sighting_id&conditionValue=" + sighting.sightingId + "&imageAttributeName=photo" + "&table=sighting"; 
        	  sightingPhoto.width = 110;
        	  sightingPhoto.height = 100;
        	  sightingPhoto.classList.add('sighting-photo');
			  container.appendChild(sightingPhoto);

        	  const sightingDetails = document.createElement('div');
        	  sightingDetails.classList.add('sightings-component');

        	  const headerRow = document.createElement('span');
        	  headerRow.classList.add('section-title-with-button', 'sighting-row');

        	  const headerTitle = document.createElement('h3');
        	  headerTitle.classList.add('sighting-header');
        	  headerTitle.textContent = plant.name; 

        	  const iconRow = document.createElement('span');
        	  iconRow.classList.add('icon-row');

        	  const trashButton = document.createElement('button');
        	  trashButton.classList.add('icon-button');
        	  const trashIcon = document.createElement('img');
        	  trashIcon.src = 'assets/trash_icon.svg';
        	  trashIcon.width = 20;
        	  trashIcon.height = 20;
        	  trashIcon.classList.add(curUser.isAdmin || curUser.username === user.username ? 'icon-shown' : 'icon-hidden');
        	  trashIcon.addEventListener('mouseover', function() {
        		  changeImage(this, 'assets/trash_icon_hover.svg');
        		});

        		trashIcon.addEventListener('mouseout', function() {
        		  changeImage(this, 'assets/trash_icon.svg');
        		});

        		trashIcon.addEventListener('click', function() {
        		  changeImage(this, 'assets/trash_icon_hover.svg');
        		  deleteSighting(sighting);
        		});
        	  trashButton.appendChild(trashIcon);
        	  
        	  const flagButton = document.createElement('button');
        	  flagButton.classList.add('icon-button');
        	  const flagIcon = document.createElement('img');
        	  flagIcon.src = 'assets/flag_icon.svg';
        	  flagIcon.width = 20;
        	  flagIcon.height = 20;
        	  flagIcon.addEventListener('mouseover', function() {
        		  changeImage(this, 'assets/flag_icon_hover.svg');
        		});

        		flagIcon.addEventListener('mouseout', function() {
        		  changeImage(this, 'assets/flag_icon.svg');
        		});

        		flagIcon.addEventListener('click', function() {
        		  changeImage(this, 'assets/flag_icon_hover.svg');
        		  unFlagSighting(sighting, curUser);
        		});
        	  flagButton.appendChild(flagIcon);

        	  iconRow.appendChild(trashButton);
        	  iconRow.appendChild(flagButton);

        	  headerRow.appendChild(headerTitle);
        	  headerRow.appendChild(iconRow);
        	  headerContainer.appendChild(headerRow);

        	  const sightingInfo = document.createElement('div');

        	  const plantId = document.createElement('p');
        	  plantId.classList.add('sighting-row');
        	  plantId.textContent = 'PlantID: ' + plant.plantId;

        	  const spottedBy = document.createElement('span');
        	  spottedBy.classList.add('sighting-row', 'sentence');
        	  
        	  const spottedByText = document.createElement('p');
        	  spottedByText.textContent = 'Spotted by';
        	  const username = document.createElement('p');
        	  username.classList.add(user.isAdmin ? 'isAdmin' : 'isRegular');
        	  username.id = "profileUsername";
        	  username.textContent = user.username;
        	  
        	  const spottedOn = document.createElement('p');
        	  spottedOn.textContent = "on " + sighting.date;
        	  
        	  spottedBy.appendChild(spottedByText);
        	  spottedBy.appendChild(username);
        	  spottedBy.appendChild(spottedOn);

        	  sightingInfo.appendChild(plantId);
        	  sightingInfo.appendChild(spottedBy);
        	  headerContainer.appendChild(sightingInfo);
        	  container.appendChild(headerContainer);

        	  const scientificNameRow = document.createElement('span');
        	  scientificNameRow.classList.add('sighting-row');
        	  const scientificNameIcon = document.createElement('img');
        	  scientificNameIcon.src = 'assets/scientific_name_icon.svg';
        	  scientificNameIcon.width = 20;
        	  scientificNameIcon.height = 15;
        	  const scientificName = document.createElement('p');
        	  scientificName.textContent = plant.scientificName;
        	  scientificNameRow.appendChild(scientificNameIcon);
        	  scientificNameRow.appendChild(scientificName);

        	  const locationRow = document.createElement('span');
        	  locationRow.classList.add('sighting-row');
        	  const locationIcon = document.createElement('img');
        	  locationIcon.src = 'assets/location_icon.svg';
        	  locationIcon.width = 20;
        	  locationIcon.height = 17;
        	  const locationText = document.createElement('p');
        	  locationText.textContent = location.name; 
        	  locationRow.appendChild(locationIcon);
        	  locationRow.appendChild(locationText);

        	  const descriptionLabel = document.createElement('p');
        	  descriptionLabel.classList.add('sighting-row', 'description-label');
        	  descriptionLabel.textContent = 'Description';

        	  const description = document.createElement('p');
        	  description.classList.add('sighting-row');
        	  description.textContent = sighting.description;
        	  
        	  const reasonLabel = document.createElement('p');
        	  reasonLabel.classList.add('sighting-row', 'description-label');
        	  reasonLabel.textContent = 'Reason for Flag';
        	  
        	  const reasonMsg = document.createElement('p');
        	  description.classList.add('sighting-row');
        	  reasonMsg.textContent = reason;

        	  const tagRow = document.createElement('span');
        	  tagRow.classList.add('tag-row');
        	  const poisonousTag = document.createElement('span');
        	  poisonousTag.classList.add(plant.poisonous ? 'icon-shown' : 'icon-hidden');
        	  poisonousTag.classList.add('tag');
        	  poisonousTag.classList.add('poisonous');
        	  const poisonousText = document.createElement('p');
        	  poisonousText.id = 'tagText';
        	  poisonousText.textContent = 'Poisonous';
        	  poisonousTag.appendChild(poisonousText);

        	  const invasiveTag = document.createElement('span');
        	  invasiveTag.classList.add(plant.invasive ? 'icon-shown' : 'icon-hidden');
        	  invasiveTag.classList.add('tag');
        	  invasiveTag.classList.add('invasive');
        	  const invasiveText = document.createElement('p');
        	  invasiveText.id = 'tagText';
        	  invasiveText.textContent = 'Invasive';
        	  invasiveTag.appendChild(invasiveText);

        	  const endangeredTag = document.createElement('span');
        	  endangeredTag.classList.add(plant.endangered ? 'icon-shown' : 'icon-hidden');
        	  endangeredTag.classList.add('tag');
        	  endangeredTag.classList.add('endangered');
        	  const endangeredText = document.createElement('p');
        	  endangeredText.id = 'tagText';
        	  endangeredText.textContent = 'Endangered';
        	  endangeredTag.appendChild(endangeredText);

        	  tagRow.appendChild(poisonousTag);
        	  tagRow.appendChild(invasiveTag);
        	  tagRow.appendChild(endangeredTag);

        	  sightingDetails.appendChild(container);
        	  sightingDetails.appendChild(scientificNameRow);
        	  sightingDetails.appendChild(locationRow);
        	  sightingDetails.appendChild(descriptionLabel);
        	  sightingDetails.appendChild(description);
        	  sightingDetails.appendChild(reasonLabel);
        	  sightingDetails.appendChild(reasonMsg);
        	  sightingDetails.appendChild(tagRow);

        	  sightingComponent.appendChild(sightingDetails);

        	  return sightingComponent;
        }
        
        function changeImage(curImg, newImage) {
    		curImg.src = newImage;
    	}

    	function editSighting(latitude, longitude, sighting, plant) {
    		const location = new google.maps.LatLng(latitude, longitude);
    		openModal(location, sighting, plant);
    	}
    	
    	function deleteSighting(sighting) {
    		createPopup(sighting, "Are you sure you want to delete this sighting?", "Delete", "Cancel", function() {
    			const dateValue = new Date(sighting.date);
        		const year = dateValue.getFullYear();
        		const month = String(dateValue.getMonth() + 1).padStart(2, '0');
        		const day = String(dateValue.getDate()).padStart(2, '0');
        		const formattedDate = year + "-" + month + "-" + day;
        		sighting.date = formattedDate;
        		fetch('/myFlorabase/deleteSighting', {
        			method: 'POST',
        			headers: {
        		        'Content-Type': 'application/json'
        		    },
        			body: JSON.stringify(sighting)
        		})
        			.then(response => response.text())
        			.then(data => {
        				console.log("Successfully deleted sighting");
        				window.location.reload();
        			})
        			.catch(error => console.error('Error:', error)); 
    		}, false);
    	}
    	
    	function unFlagSighting(sighting) {
    		fetch("/myFlorabase/unflagSighting", {
    			method: 'POST',
    			headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'sightingId=' + sighting.sightingId
    		})
    		.then(response => response.text())
			                .then(data => {
			                    createPopup(sighting, "This sighting has been unflagged.", "Close", "", false);
			                })
			                .catch(error => console.error('Error:', error));
    	}
    </script>

	<!-- Load the Google Maps JavaScript API -->
	<script>
        // Expose the API key to the external JavaScript file
       var GOOGLE_MAPS_API_KEY = "<%=apiKey%>";

	</script>

	<script async
		src="https://maps.googleapis.com/maps/api/js?key=<%=apiKey%>&callback=initMap">
		
	</script>

	<!-- Link to External JavaScript -->
	<script src="./js/custom.js"></script>
</body>
</html>
