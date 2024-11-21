import java.io.IOException;
import java.io.InputStream;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import com.example.Plant;

@MultipartConfig
@WebServlet("/editSighting")
public class EditSightingServlet extends HttpServlet {
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		int sightingId = Integer.parseInt(request.getParameter("sightingId"));
		int plantId = Integer.parseInt(request.getParameter("plantId"));
		int userId = Integer.parseInt(request.getParameter("userId"));
		String plantName = request.getParameter("plantName");
		String date = request.getParameter("date");
		String description = request.getParameter("description");
		String radius = request.getParameter("radius");
		Part photo = request.getPart("photo");
		
		AddLogServlet addLogServlet = new AddLogServlet();
		Plant plant = addLogServlet.getPlantInformation(plantName);

		String databaseUser = "root";
		String databasePassword = System.getenv("DB_PASSWORD");
		try {
			java.sql.Connection con;
			Class.forName("com.mysql.cj.jdbc.Driver");
			con = DriverManager.getConnection(
				"jdbc:mysql://localhost:3306/myFlorabase?autoReconnect=true&useSSL=false",
				databaseUser,
				databasePassword
			);
			
			plantId = addLogServlet.getOrInsertPlant(con, plant);
			plant.setPlantId(plantId);
			
			String sql = "UPDATE myflorabase.sighting SET plant_id = " + plantId
					+ (date != null ? ", date = '" + date + "'" : "")
					+ (description != null ? ", description = '" + description + "'" : "")
					+ (radius != null ? ", radius = " + Integer.parseInt(radius) : "");
			
			InputStream imageInputStream = null;
			if (photo != null) {
				sql = sql + ", photo = ?";
				imageInputStream = photo.getInputStream();
			} 
			sql = sql + " WHERE sighting_id = " + sightingId + ";";
			try (PreparedStatement statement = con.prepareStatement(sql)) {
				if (photo != null) {
					statement.setBlob(1, imageInputStream);
				}
				int rowsUpdated = statement.executeUpdate();
				response.getWriter().write(rowsUpdated + " row(s) updated.");
				if (imageInputStream != null) {
					imageInputStream.close();
				}
			}
			
			String editSql = "INSERT INTO myflorabase.edits (user_id, sighting_id, edit_date) VALUES (?, ?, ?);";
			try (PreparedStatement editStatement = con.prepareStatement(editSql)) {
				editStatement.setInt(1, userId);
				editStatement.setInt(2, sightingId);
				editStatement.setDate(3, new java.sql.Date(System.currentTimeMillis()));
				editStatement.executeUpdate();
			}
			
			con.close();
		} catch (SQLException e) {
			System.out.println("SQLException caught: " + e.getMessage());
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		} finally {
			if (photo != null) {
				photo.delete();
			}
		}
	}
}