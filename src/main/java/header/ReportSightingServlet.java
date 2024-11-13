package header;

import java.io.*;
import javax.servlet.http.*;

import com.example.User;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.*;

@WebServlet("/report")
public class ReportSightingServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public ReportSightingServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {

		request.setAttribute("reportSightingActive", "active"); // set active header tab

		// set profile outline color
		HttpSession curSession = request.getSession(false);
		if (curSession == null || curSession.getAttribute("user") == null) {
			request.setAttribute("errorTitle", "You were logged out!");
			request.setAttribute("errorMessage", "Please Sign In again.");
			request.getRequestDispatcher("login.jsp").forward(request, response);
			response.sendRedirect("login.jsp");
		} else {
			User user = (User) curSession.getAttribute("user");

			if (user.isAdmin()) {
				request.setAttribute("userType", "admin");
			} else {
				request.setAttribute("userType", "user");
			}
			RequestDispatcher dispatcher = request.getRequestDispatcher("sightings.jsp");
			dispatcher.forward(request, response);
			response.sendRedirect("sightings.jsp");
		}

	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {

	}

	public void destroy() {
	}
}