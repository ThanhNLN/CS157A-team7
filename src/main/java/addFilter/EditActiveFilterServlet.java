package addFilter;

import com.example.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Enumeration;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.example.User;

@WebServlet("/EditActiveFilterServlet")
@MultipartConfig
public class EditActiveFilterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public EditActiveFilterServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
//		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");

		String[] activeFilters = request.getParameterValues("activeFilters");
		String[] inactiveFilters = request.getParameterValues("inactiveFilters");

		// checking the values:
		if (activeFilters != null) {
			for (String value : activeFilters) {
				System.out.println("Active filter_id: " + Integer.parseInt(value));
			}
		}
		if (inactiveFilters != null) {
			for (String value : inactiveFilters) {
				System.out.println("Inactive filter_id: " + Integer.parseInt(value));
			}
		}
		
//		HttpSession session = request.getSession(false);
//		User user = (User) session.getAttribute("user");

		String databaseUser = "root";
		String databasePassword = System.getenv("DB_PASSWORD");

		java.sql.Connection con = null;

		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			con = DriverManager.getConnection("jdbc:mysql://localhost:3306/myFlorabase?autoReconnect=true&useSSL=false",
					databaseUser, databasePassword);

			String activateFiltersSQL = "UPDATE myflorabase.filter SET active=1 WHERE filter_id = ?;";
			PreparedStatement ps = con.prepareStatement(activateFiltersSQL);
			if (activeFilters != null) {
				for (String value : activeFilters) {
					ps.setInt(1, Integer.parseInt(value));
					ps.executeUpdate();
				}
			}
			
			String deactivateFiltersSQL = "UPDATE myflorabase.filter SET active=0 WHERE filter_id = ?;";
			PreparedStatement ps2 = con.prepareStatement(deactivateFiltersSQL);
			if (inactiveFilters != null) {
				for (String value : inactiveFilters) {
					ps2.setInt(1, Integer.parseInt(value));
					ps2.executeUpdate();
				}
			}
			
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

}
