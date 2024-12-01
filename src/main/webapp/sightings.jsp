<%@ page
	import="java.sql.*, java.util.Properties, com.google.gson.Gson, java.io.FileInputStream, java.io.IOException, java.util.HashMap, java.util.List, java.util.ArrayList, com.example.Sighting, com.example.User, com.example.Plant, java.util.Date"%>
<%
//Getting database credentials from environment variables
String dbUser = "root";
String dbPassword = System.getenv("DB_PASSWORD");
String dbUrl = "jdbc:mysql://localhost:3306/myFlorabase?autoReconnect=true&useSSL=false";

	// SQL statements for creating tables
	String createLocationTableSQL = "CREATE TABLE `Location` ("
			+ "`location_id` INT AUTO_INCREMENT NOT NULL, "
			+ "`latitude` DOUBLE NOT NULL, "
			+ "`longitude` DOUBLE NOT NULL, "
			+ "`name` VARCHAR(1000), "
			+ "PRIMARY KEY (`location_id`)"
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
	String createSightingTableSQL = "CREATE TABLE `Sighting` ("
			+ "`sighting_id` INT AUTO_INCREMENT NOT NULL, "
			+ "`plant_id` INT NOT NULL, "
			+ "`user_id` INT NOT NULL, "
			+ "`location_id` INT NOT NULL, "
			+ "`description` TEXT, "
			+ "`date` DATE, "
			+ "`photo` MEDIUMBLOB, "
			+ "`radius` INT, "
			+ "PRIMARY KEY (`sighting_id`, `plant_id`, `user_id`, `location_id`)"
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
	String createPlantTableSQL = "CREATE TABLE `Plant` ("
			+ "`plant_id` INT AUTO_INCREMENT NOT NULL, "
			+ "`name` VARCHAR(100) NOT NULL, "
			+ "`scientific_name` VARCHAR(100) NOT NULL, "
			+ "`description` TEXT, "
			+ "`poisonous` BOOLEAN, "
			+ "`invasive` BOOLEAN, "
			+ "`endangered` BOOLEAN, "
			+ "PRIMARY KEY (`plant_id`)"
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
	String createUserTableSQL = "CREATE TABLE `User` ("
			+ "`user_id` INT AUTO_INCREMENT PRIMARY KEY, "
			+ "`username` VARCHAR(30) NOT NULL, "
			+ "`password` VARCHAR(45) DEFAULT NULL, "
			+ "`profile_pic` MEDIUMBLOB DEFAULT NULL, "
			+ "`description` VARCHAR(500) DEFAULT NULL, "
			+ "`isAdmin` TINYINT(1) DEFAULT 0,"
			+ "`zoom` int NOT NULL DEFAULT 100,"
			+ "`location_id` int NOT NULL DEFAULT '1'"
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
	String createFilterTableSQL = "CREATE TABLE `Filter` ("
			+ "`filter_id` INT AUTO_INCREMENT NOT NULL,"
			+ "`color` varchar(45) DEFAULT NULL,"
			+ "`filter_name` varchar(255) NOT NULL,"
			+ "`active` tinyint NOT NULL DEFAULT '1',"
			+ "PRIMARY KEY (`filter_id`)"
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
	String createReportsTableSQL = "CREATE TABLE `Reports` ("
			+ "`user_id` int NOT NULL,"
			+ "`sighting_id` int NOT NULL,"
			+ "`date` date DEFAULT NULL,"
			+ "`name` varchar(100) DEFAULT NULL,"
			+ "PRIMARY KEY (`user_id`,`sighting_id`)"
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
	String createAllergicTableSQL = "CREATE TABLE `Allergic` ("
			+ "`user_id` int NOT NULL,"
			+ "`plant_id` int NOT NULL,"
			+ "PRIMARY KEY (`user_id`, `plant_id`)"
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
	String createEditsTableSQL = "CREATE TABLE `Edits` ("
			+ "`user_id` int NOT NULL,"
			+ "`sighting_id` int NOT NULL,"
			+ "`edit_date` date NOT NULL,"
			+ "PRIMARY KEY (`user_id`, `sighting_id`)"
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
	String createWithinTableSQL = "CREATE TABLE `Within` ("
			+ "`plant_id` int NOT NULL,"
			+ "`filter_id` int NOT NULL,"
			+ "PRIMARY KEY (`plant_id`, `filter_id`)"
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
	String createFlagTableSQL = "CREATE TABLE `Flag` (" 
			+ "`flag_id` INT AUTO_INCREMENT NOT NULL,"
			+ "`user_id` int NOT NULL," 
			+ "`sighting_id` int NOT NULL," 
			+ "`reason` VARCHAR(500) DEFAULT NULL,"
			+ "PRIMARY KEY (`flag_id`)" 
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
	String createUser_FilterTableSQL = "CREATE TABLE `user_filter` ("
			+ "`user_id` int NOT NULL,"
			+ "`filter_id` int NOT NULL,"
			+ "PRIMARY KEY (`user_id`,`filter_id`)"
			+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";

Connection con = null;
try {
	Class.forName("com.mysql.cj.jdbc.Driver");
	con = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
	try (Statement statement = con.createStatement()) {
		statement.executeUpdate("DROP SCHEMA IF EXISTS myFlorabase");
		statement.executeUpdate("CREATE SCHEMA myFlorabase");
		statement.executeUpdate("USE myFlorabase");

			statement.executeUpdate("DROP TABLE IF EXISTS Member");
			statement.executeUpdate("DROP TABLE IF EXISTS Users");
			statement.executeUpdate("DROP TABLE IF EXISTS MapPreference");
			statement.executeUpdate("DROP TABLE IF EXISTS Filter");
			statement.executeUpdate("DROP TABLE IF EXISTS Location");
			statement.executeUpdate("DROP TABLE IF EXISTS Sighting");
			statement.executeUpdate("DROP TABLE IF EXISTS Plant");
			statement.executeUpdate("DROP TABLE IF EXISTS Reports");
			statement.executeUpdate("DROP TABLE IF EXISTS Allergic");
			statement.executeUpdate("DROP TABLE IF EXISTS Edits");
			statement.executeUpdate("DROP TABLE IF EXISTS Within");
			statement.executeUpdate("DROP TABLE IF EXISTS Flag");
			statement.executeUpdate("DROP TABLE IF EXISTS User_Filter");


			statement.executeUpdate(createUserTableSQL);
			statement.executeUpdate(createFilterTableSQL);
			statement.executeUpdate(createLocationTableSQL);
			statement.executeUpdate(createSightingTableSQL);
			statement.executeUpdate(createPlantTableSQL);
			statement.executeUpdate(createReportsTableSQL);
			statement.executeUpdate(createAllergicTableSQL);
			statement.executeUpdate(createEditsTableSQL);
			statement.executeUpdate(createWithinTableSQL);
			statement.executeUpdate(createFlagTableSQL);
			statement.executeUpdate(createUser_FilterTableSQL);

		statement.executeUpdate("INSERT INTO myflorabase.user (username, password, profile_pic, description, isAdmin)"
		+ "VALUES ('user1', 'root', NULL, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', true);");
		statement.executeUpdate("INSERT INTO myflorabase.user (username, password, profile_pic, description, isAdmin)"
		+ "VALUES ('user2', 'root', NULL, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', false);");

			statement.executeUpdate("INSERT INTO myflorabase.filter (color, filter_name) VALUES ('green', 'All')");
			
			statement.executeUpdate("INSERT INTO myflorabase.location (latitude, longitude, name) VALUES ('37.3352', '121.8811', 'SJSU')");
			
			statement.executeUpdate("INSERT INTO myflorabase.sighting (sighting_id, plant_id, user_id, location_id, description, date, photo, radius) VALUES (1, 1, 1, 1, 'Roses are red, violets are blue', '2024-11-11', null, 2)");
			
			statement.executeUpdate("INSERT INTO myflorabase.plant (plant_id, name, scientific_name, description, poisonous, invasive, endangered) VALUES (1, 'Rose', 'Rosa rubiginosa', null, true, true, true)");
			
			statement.executeUpdate("INSERT INTO myflorabase.sighting (sighting_id, plant_id, user_id, location_id, description, date, photo, radius) VALUES (2, 1, 2, 1, 'Found more roses', '2024-11-12', null, 2)");
			
			statement.executeUpdate("INSERT INTO myflorabase.user_filter (user_id, filter_id) VALUES (1, 1)");
			statement.executeUpdate("INSERT INTO myflorabase.user_filter (user_id, filter_id) VALUES (2, 1)");

		statement.close();
		con.close();
	}
} catch (SQLException e) {
	out.println("SQLException caught: " + e.getMessage());
} catch (ClassNotFoundException e) {
	out.println("<p>MySQL JDBC Driver not found: " + e.getMessage() + "</p>");
	e.printStackTrace();
} finally {
	if (con != null) {
		try {
	con.close();
		} catch (SQLException e) {
	out.println("<p>Failed to close the connection: " + e.getMessage() + "</p>");
		}
	}
}

String apiKey = System.getenv("GOOGLE_MAPS_API_KEY");
HttpSession curSession = request.getSession(false);
User user = (User) curSession.getAttribute("user");
String userJson = new Gson().toJson(user);
boolean sightingsPage = true;
if (request.getAttribute("mySightingActive") != null) {
	sightingsPage = false;
}
%>
<!DOCTYPE html>
<html>
<head>
<title><%=sightingsPage ? "Sightings" : "My Sightings"%></title>
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
	<div id="sightingsPage" class="sightingsPage">
		<div id="header"><jsp:include
				page="WEB-INF/components/header.jsp"></jsp:include></div>


		<div id="sightingsDiv">
			<div>
				<div id="map" class="column"></div>
				<div id="container">
					<button class="major-button secondary-button" type="button"
						id="tree">Tree</button>
					<button class="major-button secondary-button" type="button"
						id="grass">Grass</button>
					<button class="major-button secondary-button" type="button"
						id="weed">Weed</button>
					<button class="major-button secondary-button" type="button"
						id="none">None</button>
				</div>
			</div>
			<div class="column sightings-column">
				<div class="sightings-component sightings-column-div">
					<span class="sightings-title"><h1 class="pageTitle"><%=sightingsPage ? "Sightings" : "My Sightings"%></h1>
						<div>
							<img src='assets/filter_icon.svg' width="30" height="30"
								onclick="showFilterDropdown()" /> <span id="filterDropdown">
								<div>
									<label class="checkbox-label prevent-select"> <input
										id="mostRecentCheckbox" type="checkbox"
										onchange="dropdownSubmit(this)"> <span
										class="checkbox"></span> Most Recent
									</label> <label class="checkbox-label prevent-select"> <input
										id="oldestCheckbox" type="checkbox"
										onchange="dropdownSubmit(this)"> <span
										class="checkbox"></span> Oldest
									</label> <span id="filterDropdownCloseButton">
										<button class="major-button secondary-button" type="button"
											onclick="hideFilterDropdown()">Close</button>
									</span>
								</div>

							</span>
						</div> </span>
					<!-- Search bar -->
					<%
					if (sightingsPage) {
					%>
					<div class="search-container">
						<form action="SearchBarServlet" method="get">
							<input id="searchBar" type="text" class="icon" name="searchQuery"
								id="searchQuery" placeholder="Search for a specific plant"
								oninput="handleInputSanitization()" required />
						</form>
					</div>
					<%
					} else {
					%>
					<div class="spacer"></div>
					<%
					}
					%>
					<div id="sightingsList"></div>
				</div>



			</div>
		</div>
		<!-- Modal Structure -->
		<jsp:include page="WEB-INF/components/modal.jsp"></jsp:include>
		<!-- Error Box to handle Search -->
		<jsp:include page="WEB-INF/components/errorBox.jsp" />
		<div id="popupContainer"></div>
	</div>

	<script src="./js/buttons.js"></script>
	<script src="./js/modal.js"></script>
	<script>
	
	window.addEventListener("load", function() {
		const isSightingsPage = <%=sightingsPage%>;
		const sightingsListContainer = document.getElementById('sightingsList');
        fetch("/myFlorabase/getSightings")
        .then(response => {
          return response.json();
        })
        .then(sightings => {
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
        		  const curUser = <%=userJson%>;
        		  if (isSightingsPage) {
        			  const sightingComponent = createSighting(sighting, info[0], info[1], info[2], curUser);
                	  sightingsListContainer.appendChild(sightingComponent);
        		  } else {
        			  if (info[0].username === curUser.username) {
        				  const sightingComponent = createSighting(sighting, info[0], info[1], info[2], curUser);
                    	  sightingsListContainer.appendChild(sightingComponent);
        			  }
        		  }
        	  })
        	  .catch(error => {
        		  console.error("Issue with fetching from FetchSightingInfo", error);
        	  });
          });
        })
        .catch(error => {
          console.error("Issue with fetching from FetchSightingsServlet", error);
        });
    })
		
    	function showFilterDropdown() {
		const dropdownContainer = document.getElementById("filterDropdown");
		dropdownContainer.style.display = "block";
	}
	
	function hideFilterDropdown() {
		const dropdownContainer = document.getElementById("filterDropdown");
		dropdownContainer.style.display = "none";
	}
	
	function dropdownSubmit(checkbox) {
		const label = checkbox.closest('label');
		const labelText = label.textContent.trim();
		// check if another checkbox is checked, if so must uncheck it
		const mostRecentCheckbox = document.getElementById("mostRecentCheckbox");
		const oldestCheckbox = document.getElementById("oldestCheckbox");
		if (labelText === "Oldest" && mostRecentCheckbox.checked) {
			mostRecentCheckbox.checked = false;
		} else if (labelText === "Most Recent" && oldestCheckbox.checked) {
			oldestCheckbox.checked = false;
		}
		const sightingsList = document.getElementById("sightingsList");
		const sightingsArr = Array.from(sightingsList.children);
		sightingsArr.sort((a, b) => {
		    const textA = a.childNodes[0].childNodes[0].childNodes[1].childNodes[1].childNodes[1].childNodes[2].childNodes[0].data.trim().slice(3);
		    const textB = b.childNodes[0].childNodes[0].childNodes[1].childNodes[1].childNodes[1].childNodes[2].childNodes[0].data.trim().slice(3);
			const dateA = new Date(textA);
			const dateB = new Date(textB);
			if (labelText === "Most Recent") {
		        return dateB - dateA;
		    } 
			return dateA - dateB;
		});
		console.log(sightingsArr);
		sightingsList.replaceChildren(...sightingsArr);
		hideFilterDropdown();
	}
        
        function createSighting(sighting, user, plant, location, curUser) {
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

        	  const editButton = document.createElement('button');
        	  editButton.classList.add('icon-button');
        	  const editIcon = document.createElement('img');
        	  editIcon.src = 'assets/edit_icon.svg';
        	  editIcon.width = 20;
        	  editIcon.height = 20;
        	  editIcon.classList.add(curUser != null && (curUser.isAdmin || curUser.username === user.username) ? 'icon-shown' : 'icon-hidden');
        	  editIcon.addEventListener('mouseover', function() {
        		  changeImage(this, 'assets/edit_icon_hover.svg');
        		});

        		editIcon.addEventListener('mouseout', function() {
        		  changeImage(this, 'assets/edit_icon.svg');
        		});

        		editIcon.addEventListener('click', function() {
        		  changeImage(this, 'assets/edit_icon_hover.svg');
        		  editSighting(location.latitude, location.longitude, sighting, plant);
        		});
        	  editButton.appendChild(editIcon);

        	  const trashButton = document.createElement('button');
        	  trashButton.classList.add('icon-button');
        	  const trashIcon = document.createElement('img');
        	  trashIcon.src = 'assets/trash_icon.svg';
        	  trashIcon.width = 20;
        	  trashIcon.height = 20;
        	  trashIcon.classList.add(curUser != null && (curUser.isAdmin || curUser.username === user.username) ? 'icon-shown' : 'icon-hidden');
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
        		  flagSighting(sighting, curUser);
        		});
        	  flagButton.appendChild(flagIcon);

        	  iconRow.appendChild(editButton);
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
    	
    	function flagSighting(sighting, curUser) {
    		createPopup(sighting, "Submit a reason for flagging this sighting", "Flag", "Cancel", function(flagReason) {
    			console.log(flagReason);
    		}, true, curUser);
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
