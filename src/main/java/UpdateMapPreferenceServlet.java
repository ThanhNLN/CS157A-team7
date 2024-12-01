import java.io.IOException;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.example.User;

@WebServlet("/updateMapPreference")
public class UpdateMapPreferenceServlet extends HttpServlet {
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		String preferenceId = request.getParameter("preferenceId");
		
		HttpSession session = request.getSession(false);
		User user = (User) session.getAttribute("user");
//		String filterId = request.getParameter("filterId");
//		String locationId = request.getParameter("locationId");
		String zoom = request.getParameter("zoom");
		
		String databaseUser = "root";
		String databasePassword = System.getenv("DB_PASSWORD");
		try {
			java.sql.Connection con;
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/?autoReconnect=true&useSSL=false", databaseUser, databasePassword);
            // creating a new MapPreference
            // only updating individual attributes
            if (zoom != null) {
            	String sql = "UPDATE myflorabase.user SET zoom = ? WHERE user_id = ?;";
                try (PreparedStatement statement = con.prepareStatement(sql)) {
                    statement.setInt(1, Integer.parseInt(zoom));
                    statement.setInt(2,user.getUserId()); 

                    int rowsUpdated = statement.executeUpdate(); 
                    response.getWriter().write(rowsUpdated + " row(s) updated."); 
                }
            }
            
            con.close();
		} catch(SQLException e) {
            System.out.println("SQLException caught: " + e.getMessage());
        } catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
}