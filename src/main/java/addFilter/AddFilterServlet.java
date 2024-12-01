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

		
		FilterDao fDao = new FilterDao();
		String successLog = fDao.addNewFilter(user, filterName, selectedValues, filterColor);

		response.setContentType("text/plain");
		response.setCharacterEncoding("UTF-8");

		response.getWriter().write(successLog);


	}

}
