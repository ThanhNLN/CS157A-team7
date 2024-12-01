<%@ page import="java.sql.*, com.example.User, com.example.Plant, com.example.Filter, java.util.List, java.util.ArrayList"%>
<html>
<head>
<link rel="stylesheet" type="text/css" href="./css/modals.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/style.css">
</head>
<%
	HttpSession curSession = request.getSession(false);
	User user = (User) curSession.getAttribute("user"); 
	String dUser; // assumes database name is the same as username
	dUser = "root";
	String pwd = System.getenv("DB_PASSWORD");

	if (pwd == null) {
	    System.out.println("DB_PASSWORD environment variable is not set.");
	}

	List<Plant> plants = new ArrayList<>();
	try {
		java.sql.Connection con;
		Class.forName("com.mysql.jdbc.Driver");
		con = DriverManager.getConnection("jdbc:mysql://localhost:3306/?autoReconnect=true&useSSL=false", dUser, pwd);
		Statement statement = con.createStatement();
		
		String getAllPlantNames = "SELECT * FROM myflorabase.plant";
		ResultSet rs = statement.executeQuery(getAllPlantNames);
		while (rs.next()){
			int plantId = rs.getInt("plant_id");
			String name = rs.getString("name");
			String scientificName = rs.getString("scientific_name");
			String description = rs.getString("description");
			boolean poisonous = rs.getBoolean("poisonous");
			boolean invasive = rs.getBoolean("invasive");
			boolean endangered = rs.getBoolean("endangered");
			Plant plant = new Plant(plantId, name, scientificName, description, poisonous, invasive, endangered);
			plants.add(plant);
		}

		rs.close();
		statement.close();
		con.close();
	} catch (SQLException e) {
		System.out.println("SQLException caught: " + e.getMessage());
	}
%>
<script defer>
	
	
</script>

<div id="filterModal" class="modal">
	<div id="filterModalContent" class="modal-content">
		<div class="centered-column">
			<h1 id="modalTitle" class="pageTitle"></h1>
			<form id="filterForm" onsubmit="submitFilter(event)" method="POST">
				<div class="form-group" id="filter-name-group">
					<label class="required textfield-label" for="filterName">Filter Name</label> 
					<input type="text" id="filterName" name="filterName" placeholder="Give this filter a name" required/>
				</div>
				<div class="form-group">
					<label class="required" for="filterColor">Filter Color</label> 
					<select id="filterColor" name="filterColor" required>
						<option value="">--Please choose a color--</option>
						<option value="red">Red</option>
						<option value="orange">Orange</option>
						<option value="yellow">Yellow</option>
						<option value="green">Green</option>
						<option value="blue">Blue</option>
						<option value="purple">Purple</option>
					</select>
				</div>
				<div class="form-group">
					<label for="search-bar">Add Plants to the filter</label>
					*insert search bar*
				</div>
				<div class="input-span">
					<%for (Plant p : plants) {%>
						<label class="checkbox-label prevent-select"> 
							<input type="checkbox" name="selectedPlants" value="<%=p.getPlantId()%>"> 
							<span class="checkbox"></span> 
						<%=p.getName()%></label>
					<%}%>
				</div>
				<span class="button-group" id="filter-button-group">
					<button id="reportButton" class="major-button primary-button" type="submit">Save</button>
					<button class="major-button secondary-button" type="button" onclick="closeNewFilterModal()">Cancel</button>
				</span>
			</form>
		</div>
	</div>
</div>
</html>
