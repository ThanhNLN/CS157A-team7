package addFilter;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.example.Filter;
import com.example.Sighting;
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

		String successLog = "";

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

			con.setAutoCommit(false);

			// add new entry into filter
			String insertNewFilterSQL = "INSERT INTO myflorabase.filter (color, filter_name) VALUES (?, ?);";

			try {
				PreparedStatement ps = con.prepareStatement(insertNewFilterSQL);
				ps.setString(1, filter.getColor());
				ps.setString(2, filter.getFilterName());
				int filter_row = ps.executeUpdate();

				// get filter_id
				String getFilterId = "SELECT LAST_INSERT_ID();";

				int user_filter_row = 0;

				PreparedStatement ps2 = con.prepareStatement(getFilterId);
				ResultSet resultSet = ps2.executeQuery();
				if (resultSet.next()) {
					int filterId = resultSet.getInt("LAST_INSERT_ID()");
					filter.setFilterId(filterId);

					// add to user_filter,
					String addUserFilterSQL = "INSERT INTO myflorabase.user_filter (user_id, filter_id) VALUES (?,?);";
					PreparedStatement ps3 = con.prepareStatement(addUserFilterSQL);
					ps3.setInt(1, user.getUserId());
					ps3.setInt(2, filter.getFilterId());
					user_filter_row = ps3.executeUpdate();

					// add entries to within (filter and plants)
					String addPlantsToFilter = "INSERT INTO myflorabase.within (filter_id, plant_id) VALUES (?,?);";
					PreparedStatement ps4 = con.prepareStatement(addPlantsToFilter);
					ps4.setInt(1, filter.getFilterId());
					for (String value : selectedValues) {
						ps4.setInt(2, Integer.parseInt(value));
						int within_rows = ps4.executeUpdate();
						if (within_rows == 0) {
							throw new SQLException();
						}
					}

				}

				// ensure all operation successful
				if (user_filter_row == 1 && filter_row == 1) {
					// If successful, commit the transaction
					con.commit();
					successLog = "Added new filter successfully.";

				} else {
					// If any operation fails, rollback the transaction
					con.rollback();
					successLog = "Adding new filter failed. Rolling back changes.";

				}

			} catch (SQLException e) {
				con.rollback();
				System.out.println("Error adding new filter: " + e.getMessage());
				successLog = e.getMessage();
			}

		} catch (SQLException e) {
			System.out.println("SQLException caught: " + e.getMessage());
			e.printStackTrace();
			successLog = e.getMessage();

		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (SQLException e) {
					System.out.println("Failed to close the connection: " + e.getMessage());
					successLog = e.getMessage();
				}
			}
		}
		return successLog;
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
					System.out.println("Record(s) found in `user_filter` with user_id= " + user.getUserId()
							+ " and filter_id=" + Integer.parseInt(filter_id) + " deleted sucessfully.");
				} else {
					System.out.println("No record found in `user_filter` with user_id= " + user.getUserId()
							+ " and filter_id=" + Integer.parseInt(filter_id));
				}

				// remove from filter
				String deleteFilterSQL = "DELETE FROM myflorabase.filter WHERE filter_id=?;";
				PreparedStatement ps2 = con.prepareStatement(deleteFilterSQL);
				ps2.setInt(1, Integer.parseInt(filter_id));
				int filter_rows = ps2.executeUpdate();

				if (filter_rows > 0) {
					System.out.println("Record(s) found in `filter` with filter_id=" + Integer.parseInt(filter_id)
							+ " deleted sucessfully.");
				} else {
					System.out.println("No record found in `filter` with filter_id=" + Integer.parseInt(filter_id));
				}

				// remove from within
				String deleteWithinSQL = "DELETE FROM myflorabase.within WHERE filter_id=?;";
				PreparedStatement ps3 = con.prepareStatement(deleteWithinSQL);
				ps3.setInt(1, Integer.parseInt(filter_id));
				int within_rows = ps3.executeUpdate();

				if (within_rows > 0) {
					System.out.println("Record(s) found in `within` with filter_id=" + Integer.parseInt(filter_id)
							+ " deleted sucessfully.");
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

			} catch (SQLException e) {
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
		return successLog;
	}

	public String editActiveFilters(String[] activeFilters, String[] inactiveFilters) {
		loadDriver(dbdriver);
		Connection con = getConnection();

		String successLog = "active filters updated";

		try {
			con.setAutoCommit(false);

			try {

				int updatedRows = 0;
				String activateFiltersSQL = "UPDATE myflorabase.filter SET active=1 WHERE filter_id = ?;";
				PreparedStatement ps = con.prepareStatement(activateFiltersSQL);
				if (activeFilters != null) {
					for (String value : activeFilters) {
						ps.setInt(1, Integer.parseInt(value));
						updatedRows += ps.executeUpdate();
					}
				}

				String deactivateFiltersSQL = "UPDATE myflorabase.filter SET active=0 WHERE filter_id = ?;";
				PreparedStatement ps2 = con.prepareStatement(deactivateFiltersSQL);
				if (inactiveFilters != null) {
					for (String value : inactiveFilters) {
						ps2.setInt(1, Integer.parseInt(value));
						updatedRows += ps2.executeUpdate();
					}
				}

				// ensure all operation successful
				if (updatedRows > 0) {
					// If successful, commit the transaction
					con.commit();
					successLog = "Change active filter(s) successful.";

				} else {
					// If any operation fails, rollback the transaction
					con.rollback();
					successLog = "Change active filter(s) failed. Rolling back changes.";

				}

			} catch (SQLException e) {
				con.rollback();
				System.out.println("Error changing active filters: " + e.getMessage());
				successLog = e.getMessage();
			}

		} catch (SQLException e) {
			System.out.println("SQLException caught: " + e.getMessage());
			e.printStackTrace();
			successLog = e.getMessage();
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (SQLException e) {
					System.out.println("Failed to close the connection: " + e.getMessage());
					successLog = e.getMessage();
				}
			}
		}
		return successLog;
	}

	public String[] getAFiltersPlants(String filter_id) {
		loadDriver(dbdriver);
		Connection con = getConnection();
		List<String> plants = new ArrayList<>();

		try {
			String getFilterPlants = "SELECT plant_id FROM myflorabase.within WHERE filter_id = '" + filter_id + "';";
			PreparedStatement ps = con.prepareStatement(getFilterPlants); 
			ResultSet resultSet = ps.executeQuery();
			while (resultSet.next()) {
				String plantId =  resultSet.getInt("plant_id") + "";
				plants.add(plantId);
			}
			

		} catch (SQLException e) {
			System.out.println("SQLException caught: " + e.getMessage());
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

		return (String[]) plants.toArray(new String[0]);
	}

	public String editFilter(User user, String filterId, String filterName, String[] selectedValues, String filterColor) {
		loadDriver(dbdriver);
		Connection con = getConnection();
		String successLog = "";
		
		String deleteSuccess = deleteFilter(user, filterId);
		String addSuccess = addNewFilter(user, filterName, selectedValues, filterColor); // inc filter id, too lazy to actually edit
		
		successLog = deleteSuccess + addSuccess;
		
		return successLog;
	}

}
