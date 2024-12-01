import java.io.IOException;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/unflagSighting")
public class UnflagSightingServlet extends HttpServlet {
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String sightingId = request.getParameter("sightingId");
		String databaseUser = "root";
		String databasePassword = System.getenv("DB_PASSWORD");
		try {
			java.sql.Connection con;
			Class.forName("com.mysql.jdbc.Driver");
			con = DriverManager.getConnection("jdbc:mysql://localhost:3306/?autoReconnect=true&useSSL=false",
					databaseUser, databasePassword);
			String sql = "DELETE FROM myflorabase.flag WHERE sighting_id = ?";
			try (PreparedStatement statement = con.prepareStatement(sql)) {
				statement.setString(1, sightingId);
				int rowsUpdated = statement.executeUpdate();
				response.getWriter().write(rowsUpdated + " row(s) updated.");
			}
			con.close();
		} catch (SQLException e) {
			System.out.println("SQLException caught: " + e.getMessage());
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
}