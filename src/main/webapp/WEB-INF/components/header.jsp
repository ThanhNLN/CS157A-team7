
<%@ page
	import="java.sql.*, com.example.User, java.util.List, java.util.ArrayList"%>

<link rel="stylesheet" href="css/header.css">
<header class="prevent-select">
	<%
	HttpSession curSession = request.getSession(false);
	User user = (User) curSession.getAttribute("user");
	if (user == null) {
		request.setAttribute("generalSightingActive", "active");
	}
	%>

	<span id="navbar"> <img id="logo-img"
		src='assets/myFlorabase_Logo_No_Text.svg' />
		<h1 id="headerText" class="header-text">myFlorabase</h1> <span
		class="topnav" id="right-Topnav">
			<button id="admin" onClick="adminPage()"
				style="display: <%=user != null && user.isAdmin() ? "inline" : "none"%>"
				class="${adminPageActive}-admin hover-underline-animation-admin header-text">Admin
				Page</button>
			<button id="sightings" onClick="sightings()"
				class="${generalSightingActive}-<%=user != null && user.isAdmin() ? "admin" : "regular"%> hover-underline-animation-<%=user != null && user.isAdmin() ? "admin" : "regular"%> header-text">Sightings</button>
			<%
			if (user != null) {
			%>
			<button id="mySightings" onClick="mySightings()"
				class="${mySightingActive}-<%=user.isAdmin() ? "admin" : "regular"%> hover-underline-animation-<%=user.isAdmin() ? "admin" : "regular"%> header-text">My
				Sightings</button> <%
 } else {
 %>
			<button id="loginHeaderButton" onClick="login()"
				class="regular hover-underline-animation-regular header-text">Login</button>
			<%
			}
			%>
	</span> <%
 if (user != null) {
 %> <span id="profile-container" class="profile-dropdown">
			<button id="profile-button"
				class="<%=user.isAdmin() ? "admin" : "regular"%>"
				onClick="profile()">
				<img id="profile-img"
					src="/myFlorabase/getImage?condition=user_id&conditionValue=<%=user.getUserId()%>&imageAttributeName=profile_pic&table=user"
					alt="Profile picture">
			</button>
			<div id="profile-underline"
				class="${profileActive}-<%=user.isAdmin() ? "admin" : "regular"%>"></div>

			<div class="profile-dropdown-content">
				<button class="profile-dropdown-button" onClick="profile()">Profile</button>
				<button class="profile-dropdown-button" onClick="logOut()">Log
					Out</button>
			</div>
	</span> <%
 }
 %>

	</span>


</header>
<script>
	function adminPage() {
		window.location = 'admin'; // TODO: create servlet to load the correct page
	}
	function sightings() {
		window.location = 'sightings';
	}

	function mySightings() {
		window.location = 'mySightings';
	}

	function reportSightings() {
		window.location = 'report';
	}

	function profile() {
		window.location = 'profile';
	}
	
	function login() {
		window.location = 'login';
	}

	function logOut() {
		window.location = 'logout';
	}
</script>

