package addFilter;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.example.User;
import com.google.gson.Gson;

/**
 * Servlet implementation class EditFilterServlet
 */
@WebServlet("/EditFilterServlet")
@MultipartConfig
public class EditFilterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public EditFilterServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String filterId = request.getParameter("filter_id");
		System.out.println(filterId);
		
		FilterDao fDao = new FilterDao();
		String[] plants = fDao.getAFiltersPlants(filterId);

        // Set content type to JSON
        response.setContentType("application/json");

        // Create a Gson object for converting the array to JSON
        Gson gson = new Gson();

        // Convert the array to JSON and write it in the response
        PrintWriter out = response.getWriter();
        out.println(gson.toJson(plants));
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");

		String filterName = request.getParameter("filterName");

		String[] selectedValues = request.getParameterValues("selectedPlants");

		String filterColor = request.getParameter("filterColor");
		
		String filterId =request.getParameter("filterId");
		
		HttpSession session = request.getSession(false);
		User user = (User) session.getAttribute("user");

		FilterDao fDao = new FilterDao();
		String successLog = fDao.editFilter(user, filterId, filterName, selectedValues, filterColor);
		
		response.setContentType("text/plain");
		response.setCharacterEncoding("UTF-8");

		response.getWriter().write(successLog);
	}

}
