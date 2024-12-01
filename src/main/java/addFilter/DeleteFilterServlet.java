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

@WebServlet("/DeleteFilterServlet")
public class DeleteFilterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public DeleteFilterServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
//		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		
		String filter_id = request.getParameter("filter_id");
		
		HttpSession session = request.getSession(false);
		User user = (User) session.getAttribute("user");

		String databaseUser = "root";
		String databasePassword = System.getenv("DB_PASSWORD");

		java.sql.Connection con = null;

		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			con = DriverManager.getConnection("jdbc:mysql://localhost:3306/myFlorabase?autoReconnect=true&useSSL=false",
					databaseUser, databasePassword);
			
			con.setAutoCommit(false);
			
			try {
				// remove from user_filter table
				String deleteUserFilterSQL = "DELETE FROM myflorabase.user_filter WHERE user_id =? and filter_id=?;";
				PreparedStatement ps = con.prepareStatement(deleteUserFilterSQL);
				ps.setInt(1, user.getUserId());
				ps.setInt(2, Integer.parseInt(filter_id));
				int user_filter_rows = ps.executeUpdate();
				
				if (user_filter_rows > 0) {
					System.out.println("Record(s) found in `user_filter` with user_id= "+ user.getUserId() + " and filter_id=" + Integer.parseInt(filter_id) + " deleted sucessfully.");
				} else {
					System.out.println("No record found in `user_filter` with user_id= "+ user.getUserId() + " and filter_id=" + Integer.parseInt(filter_id));
				}
				
				// remove from filter
				String deleteFilterSQL = "DELETE FROM myflorabase.filter WHERE filter_id=?;";
				PreparedStatement ps2 = con.prepareStatement(deleteFilterSQL);
				ps2.setInt(1, Integer.parseInt(filter_id));
				int filter_rows = ps2.executeUpdate();
				
				if (filter_rows > 0) {
					System.out.println("Record(s) found in `filter` with filter_id=" + Integer.parseInt(filter_id) + " deleted sucessfully.");
				} else {
					System.out.println("No record found in `filter` with filter_id=" + Integer.parseInt(filter_id));
				}
				
				// remove from within
				String deleteWithinSQL = "DELETE FROM myflorabase.within WHERE filter_id=?;";
				PreparedStatement ps3 = con.prepareStatement(deleteWithinSQL);
				ps3.setInt(1, Integer.parseInt(filter_id));
				int within_rows = ps3.executeUpdate();
				
				if (within_rows > 0) {
					System.out.println("Record(s) found in `within` with filter_id=" + Integer.parseInt(filter_id) + " deleted sucessfully.");
				} else {
					System.out.println("No record found in `within` with filter_id=" + Integer.parseInt(filter_id));
				}
				
				// ensure all operation successful
				if (user_filter_rows == 1 && filter_rows == 1 && within_rows > 0) {
                    // If successful, commit the transaction
                    con.commit();
                    System.out.println("Delete filter successful.");
                } else {
                    // If any operation fails, rollback the transaction
                    con.rollback();
                    System.out.println("Delete filter failed. Rolling back changes.");
                }
				
			} catch(SQLException e) {
				con.rollback();
				System.out.println("Error deleting filter: " + e.getMessage());
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
