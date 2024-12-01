import java.io.IOException;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
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

@WebServlet("/getFlaggedReason")
public class FetchFlaggedReasonServlet extends HttpServlet {
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String dUser = "root";
		String pwd = System.getenv("DB_PASSWORD");
		String sightingId = request.getParameter("sightingId");

		try {
			java.sql.Connection con;
			try {
				Class.forName("com.mysql.jdbc.Driver");
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
			con = DriverManager.getConnection("jdbc:mysql://localhost:3306/?autoReconnect=true&useSSL=false", dUser,
					pwd);
			String fetchFlaggedReasonSQL = "SELECT reason FROM myflorabase.flag WHERE sighting_id = ?";
			try (PreparedStatement statement = con.prepareStatement(fetchFlaggedReasonSQL)) {
				statement.setInt(1, Integer.parseInt(sightingId));
				try (ResultSet rs = statement.executeQuery()) {
					StringBuilder reasons = new StringBuilder();
					while (rs.next()) {
						reasons.append(rs.getString("reason")).append("\n");
					}
					response.getWriter().write(reasons.toString());
				}
			}
			con.close();
		} catch (SQLException e) {
			System.out.println("SQLException caught: " + e.getMessage());
		}
	}
}
