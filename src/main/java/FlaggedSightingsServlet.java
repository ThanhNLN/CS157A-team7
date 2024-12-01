import java.io.IOException;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.example.Sighting;
import com.google.gson.Gson;

@WebServlet("/getFlaggedSightings")
public class FlaggedSightingsServlet extends HttpServlet {
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String dUser = "root";
		String pwd = System.getenv("DB_PASSWORD");
		List<Sighting> sightings = new ArrayList<>();

		try {
			java.sql.Connection con;
			try {
				Class.forName("com.mysql.jdbc.Driver");
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
			con = DriverManager.getConnection("jdbc:mysql://localhost:3306/?autoReconnect=true&useSSL=false", dUser,
					pwd);
			Statement statement = con.createStatement();
			String fetchSightingsSQL = "SELECT * FROM myflorabase.flag f JOIN myflorabase.sighting s ON f.sighting_id = s.sighting_id";
			ResultSet rs = statement.executeQuery(fetchSightingsSQL);
			while (rs.next()) {
				int sightingId = rs.getInt("sighting_id");
				int plantId = rs.getInt("plant_id");
				int userId = rs.getInt("user_id");
				int locationId = rs.getInt("location_id");
				String description = rs.getString("description");
				double radius = rs.getDouble("radius");
				Date date = rs.getDate("date");
				byte[] photo = rs.getBytes("photo");
				String reason = rs.getString("reason");
				Sighting curSighting = new Sighting(sightingId, plantId, userId, locationId, description, radius, date);
				curSighting.setPhoto(photo);
				sightings.add(curSighting);
			}
			rs.close();
			statement.close();
			con.close();
			Gson gson = new Gson();
	        String jsonResponse = gson.toJson(sightings);
	        response.setContentType("application/json");
	        response.setCharacterEncoding("UTF-8");
	        response.getWriter().write(jsonResponse);
	        
		} catch (SQLException e) {
			System.out.println("SQLException caught: " + e.getMessage());
		}
	}
}
