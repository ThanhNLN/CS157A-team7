package header;

import java.io.*;
import javax.servlet.http.*;

import com.example.User;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.*;

@WebServlet("/sightings")
public class generalSightingsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public generalSightingsServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {

		request.setAttribute("generalSightingActive", "active"); // set active header tab

		// set profile outline color
		HttpSession curSession = request.getSession(false);

		if (curSession == null || curSession.getAttribute("user") == null) {
			request.setAttribute("errorTitle", "You were logged out!");
			request.setAttribute("errorMessage", "Please Sign In again.");
			request.getRequestDispatcher("login.jsp").forward(request, response);
		} else {
			User user = (User) curSession.getAttribute("user");

			if (user.isAdmin()) {
				request.setAttribute("userType", "admin");
			} else {
				request.setAttribute("userType", "user");
			}

			RequestDispatcher dispatcher = request.getRequestDispatcher("sightings.jsp"); // this needs to be changed to
																							// the correct jsp file?
																							// using sightings.jsp as
																							// temporary test
			dispatcher.forward(request, response);
		}

	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {

	}

	public void destroy() {
	}
}