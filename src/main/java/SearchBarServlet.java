import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.example.PlantSighting;
import com.google.gson.Gson;

@WebServlet("/SearchBarServlet")
public class SearchBarServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchQuery = request.getParameter("searchQuery");
        
        // Validate input
        if (searchQuery == null || searchQuery.trim().isEmpty()) {
            request.setAttribute("errorTitle", "Search Error");
            request.setAttribute("errorMessage", "Please enter a plant name or scientific name to search.");
            RequestDispatcher rd = request.getRequestDispatcher("sightings.jsp");
            rd.forward(request, response);
            return;
        }

        searchQuery = searchQuery.trim();
        ArrayList<PlantSighting> results = new ArrayList<>();
        Connection con = null;

        try {
            // Connect to database
            String dbUser = "root";
            String dbPassword = System.getenv("DB_PASSWORD");
            String dbUrl = "jdbc:mysql://localhost:3306/myFlorabase?useSSL=false";

            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

            // SQL query with natural join
            String sql = "SELECT Plant.name, Plant.plant_id, Plant.scientific_name, Plant.description, " +
                         "Plant.poisonous, Plant.invasive, Plant.endangered, " +
                         "User.username, Sighting.date, Location.name, Location.latitude, Location.longitude " +
                         "FROM Plant " +
                         "JOIN Sighting ON Plant.plant_id = Sighting.plant_id " +
                         "JOIN User ON Sighting.user_id = User.user_id " +
                         "JOIN Location ON Sighting.location_id = Location.location_id " +
                         "WHERE Plant.name LIKE ? OR Plant.scientific_name LIKE ?";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, "%" + searchQuery + "%");
                ps.setString(2, "%" + searchQuery + "%");
                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    PlantSighting sighting = new PlantSighting(
                            rs.getString("name"),
                            rs.getInt("plant_id"),
                            rs.getString("scientific_name"),
                            rs.getString("description"),
                            rs.getBoolean("poisonous"),
                            rs.getBoolean("invasive"),
                            rs.getBoolean("endangered"),
                            rs.getString("username"),
                            rs.getDate("date"),
                            rs.getString("name"), // Location name
                            rs.getDouble("latitude"),
                            rs.getDouble("longitude")
                    );
                    results.add(sighting);
                }
            }

            if (results.isEmpty()) {
                // Handle no results
                request.setAttribute("errorTitle", "Search Error");
                request.setAttribute("errorMessage", "No results found for " + searchQuery + ". Please try again.");
                RequestDispatcher rd = request.getRequestDispatcher("sightings.jsp");
                rd.forward(request, response);
            } else {
                // Pass results as JSON
                response.setContentType("application/json");
                response.getWriter().write(new Gson().toJson(results));
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Database error");
        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
