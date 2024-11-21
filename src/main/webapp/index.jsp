<%@ page import="java.sql.*, java.io.IOException"%>
<%
// Getting database credentials from environment variables
String dbUser = "root";
String dbPassword = System.getenv("DB_PASSWORD");
String dbUrl = "jdbc:mysql://localhost:3306/myFlorabase?autoReconnect=true&useSSL=false";

// SQL statements for creating tables
String createLocationTableSQL = "CREATE TABLE `Location` (" + "`location_id` INT AUTO_INCREMENT NOT NULL, "
		+ "`latitude` DOUBLE NOT NULL, " + "`longitude` DOUBLE NOT NULL, " + "`name` VARCHAR(1000), "
		+ "PRIMARY KEY (`location_id`)" + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
String createSightingTableSQL = "CREATE TABLE `Sighting` (" + "`sighting_id` INT AUTO_INCREMENT NOT NULL, "
		+ "`plant_id` INT NOT NULL, " + "`user_id` INT NOT NULL, " + "`location_id` INT NOT NULL, "
		+ "`description` TEXT, " + "`date` DATE, " + "`photo` MEDIUMBLOB, " + "`radius` INT, "
		+ "PRIMARY KEY (`sighting_id`, `plant_id`, `user_id`, `location_id`)"
		+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
String createPlantTableSQL = "CREATE TABLE `Plant` (" + "`plant_id` INT AUTO_INCREMENT NOT NULL, "
		+ "`name` VARCHAR(100) NOT NULL, " + "`scientific_name` VARCHAR(100) NOT NULL, " + "`description` TEXT, "
		+ "`poisonous` BOOLEAN, " + "`invasive` BOOLEAN, " + "`endangered` BOOLEAN, " + "PRIMARY KEY (`plant_id`)"
		+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
String createUserTableSQL = "CREATE TABLE `User` (" + "`user_id` INT AUTO_INCREMENT PRIMARY KEY, "
		+ "`username` VARCHAR(30) NOT NULL, " + "`password` VARCHAR(45) DEFAULT NULL, "
		+ "`profile_pic` MEDIUMBLOB DEFAULT NULL, " + "`description` VARCHAR(500) DEFAULT NULL, "
		+ "`isAdmin` TINYINT(1) DEFAULT 0" + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
String createMapPreferenceTableSQL = "CREATE TABLE `MapPreference` (" + "`preference_id` INT AUTO_INCREMENT,"
		+ "`user_id` int NOT NULL," + "`filter_id` int NOT NULL," + "`location_id` int NOT NULL,"
		+ "`zoom` double DEFAULT 100," + "PRIMARY KEY (`preference_id`,`user_id`,`filter_id`,`location_id`)"
		+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
String createFilterTableSQL = "CREATE TABLE `Filter` (" + "`filter_id` INT AUTO_INCREMENT NOT NULL,"
		+ "`color` varchar(45) DEFAULT NULL," + "`filter_name` varchar(255) NOT NULL," + "PRIMARY KEY (`filter_id`)"
		+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
String createReportsTableSQL = "CREATE TABLE `Reports` (" + "`user_id` int NOT NULL," + "`sighting_id` int NOT NULL,"
		+ "`date` date DEFAULT NULL," + "`name` varchar(100) DEFAULT NULL," + "PRIMARY KEY (`user_id`,`sighting_id`)"
		+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
String createAllergicTableSQL = "CREATE TABLE `Allergic` (" + "`user_id` int NOT NULL," + "`plant_id` int NOT NULL,"
		+ "PRIMARY KEY (`user_id`, `plant_id`)" + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
String createEditsTableSQL = "CREATE TABLE `Edits` (" + "`user_id` int NOT NULL," + "`sighting_id` int NOT NULL,"
		+ "`edit_date` date NOT NULL," + "PRIMARY KEY (`user_id`, `sighting_id`)"
		+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
String createWithinTableSQL = "CREATE TABLE `Within` (" + "`plant_id` int NOT NULL," + "`filter_id` int NOT NULL,"
		+ "PRIMARY KEY (`plant_id`, `filter_id`)"
		+ ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
String createFlagTableSQL = "CREATE TABLE `Flag` (" + "`flag_id` INT AUTO_INCREMENT NOT NULL,"
		+ "`user_id` int NOT NULL," + "`sighting_id` int NOT NULL," + "`reason` VARCHAR(500) DEFAULT NULL,"
		+ "PRIMARY KEY (`flag_id`)" + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";

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

		statement.executeUpdate(createUserTableSQL);
		statement.executeUpdate(createMapPreferenceTableSQL);
		statement.executeUpdate(createFilterTableSQL);
		statement.executeUpdate(createLocationTableSQL);
		statement.executeUpdate(createSightingTableSQL);
		statement.executeUpdate(createPlantTableSQL);
		statement.executeUpdate(createReportsTableSQL);
		statement.executeUpdate(createAllergicTableSQL);
		statement.executeUpdate(createEditsTableSQL);
		statement.executeUpdate(createWithinTableSQL);
		statement.executeUpdate(createFlagTableSQL);

		statement.executeUpdate("INSERT INTO myflorabase.user (username, password, profile_pic, description, isAdmin)"
		+ "VALUES ('user1', 'root', NULL, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', true);");
		statement.executeUpdate("INSERT INTO myflorabase.user (username, password, profile_pic, description, isAdmin)"
		+ "VALUES ('user2', 'root', NULL, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', false);");
		out.println("Initial entries in table \"myFlorabase\": <br/>");

		statement.executeUpdate("INSERT INTO myflorabase.filter (color, filter_name) VALUES ('green', 'All')");
		statement.executeUpdate(
		"INSERT INTO myflorabase.location (latitude, longitude, name) VALUES ('37.3352', '121.8811', 'SJSU')");
		statement.executeUpdate(
		"INSERT INTO myflorabase.mappreference (user_id, filter_id, location_id, zoom) VALUES ('1', '1', 1, 125)");
		statement.executeUpdate(
		"INSERT INTO myflorabase.sighting (sighting_id, plant_id, user_id, location_id, description, date, photo, radius) VALUES (1, 1, 1, 1, 'Roses are red, violets are blue', '2024-11-11', null, 2)");
		statement.executeUpdate(
		"INSERT INTO myflorabase.plant (plant_id, name, scientific_name, description, poisonous, invasive, endangered) VALUES (1, 'Rose', 'Rosa rubiginosa', null, true, true, true)");
		statement.executeUpdate(
		"INSERT INTO myflorabase.sighting (sighting_id, plant_id, user_id, location_id, description, date, photo, radius) VALUES (2, 1, 2, 1, 'Found more roses', '2024-11-12', null, 2)");
		out.println("Initial entries in table \"myFlorabase\": <br/>");

		ResultSet rs = statement.executeQuery("SELECT * FROM User");
		while (rs.next()) {
	out.println("<tr>" + "<td>" + rs.getString(1) + "</td>" + "<td>" + rs.getString(3) + "</td>" + "<td>"
			+ rs.getString(4) + "</td>" + "</tr>");
		}
		rs.close();
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
%>
<!DOCTYPE html>
<html>
<head>
<title>Database Setup</title>
</head>
<body>
	<h1>Database Initialization</h1>
</body>
</html>