import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.net.ssl.HttpsURLConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import com.example.Plant;
import com.example.User;

import com.example.Plant;
import com.example.User;

@MultipartConfig
@WebServlet("/AddLogServlet")
public class AddLogServlet extends HttpServlet {
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");

		String plantName = request.getParameter("plantName");
		String date = request.getParameter("date");
		String description = request.getParameter("description");
		int radius = Integer.parseInt(request.getParameter("radius"));
		double latitude = Double.parseDouble(request.getParameter("latitude"));
		double longitude = Double.parseDouble(request.getParameter("longitude"));
		Part photoPart = request.getPart("photo");	

		HttpSession session = request.getSession(false);
		User user = (User) session.getAttribute("user");
		int userId = user.getUserId();

		String locationName = getLocationName(latitude, longitude);
		Plant plant = getPlantInformation(plantName);
		String databaseUser = "root";
		String databasePassword = System.getenv("DB_PASSWORD");
		java.sql.Connection con = null;

		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			con = DriverManager.getConnection(
				"jdbc:mysql://localhost:3306/myFlorabase?autoReconnect=true&useSSL=false",
				databaseUser,
				databasePassword
			);

			int locationId = getOrInsertLocation(con, locationName, latitude, longitude);
			int plantId = getOrInsertPlant(con, plant);

			plant.setPlantId(plantId);
			byte[] photoBytes = readPhotoBytes(photoPart);
			insertSighting(con, plantId, userId, locationId, description, date, photoBytes, radius);

		} catch (SQLException e) {
			System.out.println("SQLException caught: " + e.getMessage());
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			System.out.println("MySQL JDBC Driver not found: " + e.getMessage());
			e.printStackTrace();
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (SQLException e) {
					System.out.println("Failed to close the connection: " + e.getMessage());
				}
			}
		}
		response.setContentType("text/plain");
		response.setCharacterEncoding("UTF-8");
		response.getWriter().write("Log received and processed successfully.");
	}

	private String getLocationName(double latitude, double longitude) {
		String locationName = "";
		try {
			String apiUrlLocation = String.format("https://nominatim.openstreetmap.org/reverse?lat=%s&lon=%s&format=json",
					URLEncoder.encode("" + latitude, "UTF-8"),
					URLEncoder.encode("" + longitude, "UTF-8"));
			URL urlLocation = new URL(apiUrlLocation);
			HttpURLConnection connectionLocation = (HttpURLConnection) urlLocation.openConnection();
			connectionLocation.setRequestMethod("GET");
			connectionLocation.setRequestProperty("User-Agent", "Mozilla/5.0");

			int responseCodeLocation = connectionLocation.getResponseCode();
			if (responseCodeLocation == HttpURLConnection.HTTP_OK) {
				BufferedReader in = new BufferedReader(new InputStreamReader(connectionLocation.getInputStream()));
				String inputLine;
				StringBuilder responseContent = new StringBuilder();

				while ((inputLine = in.readLine()) != null) {
					responseContent.append(inputLine);
				}
				in.close();

				String responseStr = responseContent.toString();
				int startIndex = responseStr.indexOf("\"display_name\":\"");
				if (startIndex != -1) {
					startIndex += 16;
					int endIndex = responseStr.indexOf("\"", startIndex);
					if (endIndex != -1) {
						locationName = responseStr.substring(startIndex, endIndex).replace("\\u0026", "&");
					}
				}
				System.out.println("Location: " + locationName);
			} else {
				System.out.println("GET request failed.");
			}
		} catch (Exception e) {
			System.out.println("Error during reverse geocoding: " + e.getMessage());
			e.printStackTrace();
		}
		return locationName;
	}

	public Plant getPlantInformation(String plantName) {
		String scientificName = "";
		String description = "";
		boolean poisonous = false;
		boolean invasive = false;
		boolean endangered = false;

		String prompt = "Provide the scientific name, a brief description, and details on whether the plant is poisonous, "
				+ "invasive, or endangered for " + plantName + ". Format the output with only the following labels in all caps: "
				+ "'SCIENTIFIC NAME:', 'DESCRIPTION:', 'POISONOUS:', 'INVASIVE:', 'ENDANGERED:'. "
				+ "For the 'POISONOUS:', 'INVASIVE:', and 'ENDANGERED:' labels, ensure that the values are strictly 'true' or 'false' with no additional text. "
				+ "The description should include a summary of what the plant is, and a note if people with pollen allergies "
				+ "or sensitivities should avoid it. Ensure the output is in plain text only, with no bolding or special formatting. "
				+ "Additionally, guarantee that each label ('SCIENTIFIC NAME:', 'DESCRIPTION:', 'POISONOUS:', 'INVASIVE:', 'ENDANGERED:') "
				+ "appears only once with a single corresponding value. Maintain this structure consistently every time, "
				+ "regardless of the plant information provided.";
		prompt = prompt.replace("\"", "\\\"");

		String jsonBody = "{"
				+ "\"contents\": [{"
				+ "\"parts\": [{\"text\": \"" + prompt + "\"}]"
				+ "}]"
				+ "}";

		try {
			URL url = new URL("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=" + System.getenv("GEMINI_KEY"));

			HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
			conn.setDoOutput(true);

			try (OutputStream os = conn.getOutputStream()) {
				byte[] input = jsonBody.getBytes("UTF-8");
				os.write(input, 0, input.length);
			}

			InputStream is = conn.getInputStream();
			BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
			StringBuilder responseStrBuilder = new StringBuilder();
			String line;

			while ((line = reader.readLine()) != null) {
				responseStrBuilder.append(line.trim());
			}

			reader.close();
			conn.disconnect();

			String responseStr = responseStrBuilder.toString();
			String generatedText = "";

			int textStart = responseStr.indexOf("\"text\": \"");
			if (textStart != -1) {
				textStart += "\"text\": \"".length();
				int textEnd = responseStr.indexOf("\"", textStart);
				if (textEnd != -1) {
					generatedText = responseStr.substring(textStart, textEnd);
					generatedText = generatedText.replace("\\n", "\n");
				}
			}

			BufferedReader textReader = new BufferedReader(new StringReader(generatedText));
			String currentLine;
			while ((currentLine = textReader.readLine()) != null) {
				currentLine = currentLine.trim();
				if (currentLine.startsWith("SCIENTIFIC NAME:")) {
					scientificName = currentLine.substring("SCIENTIFIC NAME:".length()).trim();
				} else if (currentLine.startsWith("DESCRIPTION:")) {
					description = currentLine.substring("DESCRIPTION:".length()).trim();
				} else if (currentLine.startsWith("POISONOUS:")) {
					String val = currentLine.substring("POISONOUS:".length()).trim().toLowerCase();
					poisonous = val.equals("true");
				} else if (currentLine.startsWith("INVASIVE:")) {
					String val = currentLine.substring("INVASIVE:".length()).trim().toLowerCase();
					invasive = val.equals("true");
				} else if (currentLine.startsWith("ENDANGERED:")) {
					String val = currentLine.substring("ENDANGERED:".length()).trim().toLowerCase();
					endangered = val.equals("true");
				}
			}
			textReader.close();
		} catch (Exception e) {
			System.out.println("Error communicating with Gemini API: " + e.getMessage());
			e.printStackTrace();
		}

		Plant plant = new Plant(0, plantName, scientificName, description, poisonous, invasive, endangered);
		return plant;
	}

	private int getOrInsertLocation(java.sql.Connection con, String locationName, double latitude, double longitude) throws SQLException {
		int locationId = 0;
		String selectLocationSQL = "SELECT location_id FROM Location WHERE name = ?";
		try (PreparedStatement selectLocationStatement = con.prepareStatement(selectLocationSQL)) {
			selectLocationStatement.setString(1, locationName);
			try (ResultSet resultSet = selectLocationStatement.executeQuery()) {
				if (resultSet.next()) {
					locationId = resultSet.getInt("location_id");
					System.out.println("Existing location found with ID: " + locationId);
				} else {
					String insertLocationSQL = "INSERT INTO Location (latitude, longitude, name) VALUES (?, ?, ?)";
					try (PreparedStatement insertLocationStatement = con.prepareStatement(insertLocationSQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
						insertLocationStatement.setDouble(1, latitude);
						insertLocationStatement.setDouble(2, longitude);
						insertLocationStatement.setString(3, locationName);
						insertLocationStatement.executeUpdate();

						try (ResultSet generatedKeys = insertLocationStatement.getGeneratedKeys()) {
							if (generatedKeys.next()) {
								locationId = generatedKeys.getInt(1);
								System.out.println("New location inserted with ID: " + locationId);
							}
						}
					}
				}
			}
		}
		return locationId;
	}

	public int getOrInsertPlant(java.sql.Connection con, Plant plant) throws SQLException {
		int plantId = 0;
		String selectPlantSQL = "SELECT plant_id FROM Plant WHERE name = ?";
		try (PreparedStatement selectPlantStatement = con.prepareStatement(selectPlantSQL)) {
			selectPlantStatement.setString(1, plant.getName());
			try (ResultSet resultSet = selectPlantStatement.executeQuery()) {
				if (resultSet.next()) {
					plantId = resultSet.getInt("plant_id");
					System.out.println("Existing plant found with ID: " + plantId);
				} else {
					String insertPlantSQL = "INSERT INTO Plant (name, scientific_name, description, poisonous, invasive, endangered) VALUES (?, ?, ?, ?, ?, ?)";
					try (PreparedStatement insertPlantStatement = con.prepareStatement(insertPlantSQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
						insertPlantStatement.setString(1, plant.getName());
						insertPlantStatement.setString(2, plant.getScientificName());
						insertPlantStatement.setString(3, plant.getDescription());
						insertPlantStatement.setBoolean(4, plant.isPoisonous());
						insertPlantStatement.setBoolean(5, plant.isInvasive());
						insertPlantStatement.setBoolean(6, plant.isEndangered());
						insertPlantStatement.executeUpdate();

						try (ResultSet generatedKeys = insertPlantStatement.getGeneratedKeys()) {
							if (generatedKeys.next()) {
								plantId = generatedKeys.getInt(1);
								System.out.println("New plant inserted with ID: " + plantId);
							}
						}
					}
				}
			}
		}
		return plantId;
	}

	private byte[] readPhotoBytes(Part photoPart) throws IOException {
		byte[] photoBytes = new byte[(int) photoPart.getSize()];
		try (InputStream photoInputStream = photoPart.getInputStream()) {
			int bytesRead = photoInputStream.read(photoBytes);
			if (bytesRead != photoBytes.length) {
				System.out.println("Warning: Not all photo bytes were read.");
			}
		}
		return photoBytes;
	}

	private void insertSighting(java.sql.Connection con, int plantId, int userId, int locationId, String description, String date, byte[] photoBytes, int radius) throws SQLException {
		String insertSightingSQL = "INSERT INTO Sighting (plant_id, user_id, location_id, description, date, photo, radius) VALUES (?, ?, ?, ?, ?, ?, ?)";
		try (PreparedStatement insertStatement = con.prepareStatement(insertSightingSQL)) {
			insertStatement.setInt(1, plantId);
			insertStatement.setInt(2, userId);
			insertStatement.setInt(3, locationId);
			insertStatement.setString(4, description);
			insertStatement.setString(5, date);
			insertStatement.setBytes(6, photoBytes);
			insertStatement.setInt(7, radius);
			insertStatement.executeUpdate();
			System.out.println("Sighting inserted successfully.");
		}
	}
}