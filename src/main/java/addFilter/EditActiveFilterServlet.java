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

		FilterDao fDao = new FilterDao();
		String successLog = fDao.editActiveFilters(activeFilters, inactiveFilters);

		response.setContentType("text/plain");
		response.setCharacterEncoding("UTF-8");
		response.getWriter().write(successLog);
	}

}
