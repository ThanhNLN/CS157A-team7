package addFilter;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.example.Filter;
import com.example.User;

public class FilterDao {
	private String dburl = "jdbc:mysql://localhost:3306/myflorabase";
	private String dbuname = "root";
	private String dbpwd = System.getenv("DB_PASSWORD");
	private String dbdriver = "com.mysql.jdbc.Driver";

	public void loadDriver(String dbdriver) {
		try {
			Class.forName(dbdriver);
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}

	public Connection getConnection() {
		Connection con = null;
		try {

			con = DriverManager.getConnection(dburl, dbuname, dbpwd);
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return con;
	}

	public boolean checkForExistingFilterName(User curUser, String filterName) {
		loadDriver(dbdriver);
		Connection con = getConnection();

		String s = "SELECT * FROM myflorabase.user_filter uf, myflorabase.filter f WHERE user_id ='"
				+ curUser.getUserId() + "' AND uf.filter_id = f.filter_id AND filter_name ='" + filterName + "';";
		try {
			PreparedStatement ps = con.prepareStatement(s);
			ResultSet resultSet = ps.executeQuery();
			if (resultSet.isBeforeFirst()) {
				return false;
			}

		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public String addNewFilter(User user, String filterName, String[] selectedValues, String filterColor) {
		loadDriver(dbdriver);
		Connection con = getConnection();

		try {

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
							return e.getMessage();
						}
					}
				} catch (SQLException e) {
					System.out.println("SQLException caught: " + e.getMessage());
					e.printStackTrace();
					return e.getMessage();

				}
			} catch (SQLException e) {
				System.out.println("SQLException caught: " + e.getMessage());
				e.printStackTrace();
				return e.getMessage();

			}

		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (SQLException e) {
					System.out.println("Failed to close the connection: " + e.getMessage());
					return e.getMessage();
				}
			}
		}
		return "New filter added successfully!";
	}

	public String deleteFilter(User user, String filter_id) {
		loadDriver(dbdriver);
		Connection con = getConnection();
		
		String successLog = "";
		try {
			
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
                    successLog = "Delete filter successful.";
                    
                } else {
                    // If any operation fails, rollback the transaction
                    con.rollback();
                    successLog = "Delete filter failed. Rolling back changes.";
                   
                }
				
				return successLog;
				
			} catch(SQLException e) {
				con.rollback();
				System.out.println("Error deleting filter: " + e.getMessage());
				return e.getMessage();
			}
			
			
			
		} catch (SQLException e) {
			System.out.println("SQLException caught: " + e.getMessage());
			e.printStackTrace();
			return e.getMessage();
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (SQLException e) {
					System.out.println("Failed to close the connection: " + e.getMessage());
					return e.getMessage();
				}
			}
		}
	}

}
