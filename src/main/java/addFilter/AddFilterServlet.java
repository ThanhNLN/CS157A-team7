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

@WebServlet("/AddFilterServlet")
@MultipartConfig
public class AddFilterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AddFilterServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
//		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");

		String filterName = request.getParameter("filterName");

		String[] selectedValues = request.getParameterValues("selectedPlants");

		String filterColor = request.getParameter("filterColor");

		HttpSession session = request.getSession(false);
		User user = (User) session.getAttribute("user");

		String databaseUser = "root";
		String databasePassword = System.getenv("DB_PASSWORD");

		java.sql.Connection con = null;

		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			con = DriverManager.getConnection("jdbc:mysql://localhost:3306/myFlorabase?autoReconnect=true&useSSL=false",
					databaseUser, databasePassword);

			// checking the values:
			System.out.println("Filter Name: " + filterName);
			System.out.println("Filter Color: " + filterColor);
			if (selectedValues != null) {
				for (String value : selectedValues) {
					System.out.println("Selected value: " + value);
				}
			}

			Filter filter = new Filter(filterColor, filterName);

			// add new entry into filter
			String insertNewFilterSQL = "INSERT INTO myflorabase.filter (color, filter_name) VALUES (?, ?);";
			try {
				PreparedStatement ps = con.prepareStatement(insertNewFilterSQL);
				ps.setString(1, filter.getColor());
				ps.setString(2, filter.getFilterName());
				ps.executeUpdate();

				// get filter_id
				String getFilterId = "SELECT LAST_INSERT_ID();";

				try {
					PreparedStatement ps2 = con.prepareStatement(getFilterId);
					ResultSet resultSet = ps2.executeQuery();
					if (resultSet.next()) {
						int filterId = resultSet.getInt("LAST_INSERT_ID()");
						filter.setFilterId(filterId);

						try {
							// add to user_filter,
							String addUserFilterSQL = "INSERT INTO myflorabase.user_filter (user_id, filter_id) VALUES (?,?);";
							PreparedStatement ps3 = con.prepareStatement(addUserFilterSQL);
							ps3.setInt(1, user.getUserId());
							ps3.setInt(2, filter.getFilterId());
							ps3.executeUpdate();

							// add entries to within (filter and plants)
							String addPlantsToFilter = "INSERT INTO myflorabase.within (filter_id, plant_id) VALUES (?,?);";
							PreparedStatement ps4 = con.prepareStatement(addPlantsToFilter);
							ps4.setInt(1, filter.getFilterId());
							for (String value : selectedValues) {
								ps4.setInt(2, Integer.parseInt(value));
								ps4.executeUpdate();
							}
						} catch (SQLException e) {
							System.out.println("SQLException caught: " + e.getMessage());
							e.printStackTrace();
						}
					}
				} catch (SQLException e) {
					System.out.println("SQLException caught: " + e.getMessage());
					e.printStackTrace();
				}
			} catch (SQLException e) {
				System.out.println("SQLException caught: " + e.getMessage());
				e.printStackTrace();
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
