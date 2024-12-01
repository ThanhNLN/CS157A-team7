import java.io.IOException;
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

import com.example.Plant;
import com.google.gson.Gson;

@WebServlet("/getPlant")
public class PlantServlet extends HttpServlet {
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String plantName = request.getParameter("plantName");
		String dUser = "root";
		String pwd = System.getenv("DB_PASSWORD");
		Plant plant = null;
		List<Object> pkg = new ArrayList<>();

		try {
			java.sql.Connection con;
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection("jdbc:mysql://localhost:3306/?autoReconnect=true&useSSL=false", dUser,
					pwd);
			Statement statement = con.createStatement();
			String fetchPlantSQL = "SELECT * FROM myflorabase.plant WHERE name = '" + plantName + "'";
			ResultSet rs = statement.executeQuery(fetchPlantSQL);
			if (rs.next()) {
				int plantId = rs.getInt("plant_id");
				String name = rs.getString("name");
				String scientificName = rs.getString("scientific_name");
				String description = rs.getString("description");
				boolean poisonous = rs.getBoolean("poisonous");
				boolean invasive = rs.getBoolean("invasive");
				boolean endangered = rs.getBoolean("endangered");
				plant = new Plant(plantId, name, scientificName, description, poisonous, invasive, endangered);
				pkg.add(plant);
			}
			rs.close();
			statement.close();
			con.close();
			Gson gson = new Gson();
			String jsonResponse = gson.toJson(pkg);
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			response.getWriter().write(jsonResponse);
		} catch (SQLException | ClassNotFoundException e) {
			System.out.println("SQLException caught: " + e.getMessage());
		}
	}
}
