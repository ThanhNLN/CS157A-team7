<%@ page
	import="java.sql.*, com.example.User, com.example.MapPreference, com.example.Filter, java.util.List, java.util.ArrayList"%>
<html>
<head>
<title>Profile</title>
<link rel="icon" href="assets/myFlorabase_Logo_No_Text.svg"
	type="image/svg">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap"
	rel="stylesheet">
<link rel="stylesheet" href="css/style.css">
<script src="./js/buttons.js"></script>
</head>
<body>
	<%
	HttpSession curSession = request.getSession(false);
	User user = (User) curSession.getAttribute("user");
	String dUser; // assumes database name is the same as username
	dUser = "root";
	String pwd = System.getenv("DB_PASSWORD");

	if (pwd == null) {
		System.out.println("DB_PASSWORD environment variable is not set.");
	}

	List<Filter> filters = new ArrayList<>();
	try {
		java.sql.Connection con;
		Class.forName("com.mysql.jdbc.Driver");
		con = DriverManager.getConnection("jdbc:mysql://localhost:3306/?autoReconnect=true&useSSL=false", dUser, pwd);
		Statement statement = con.createStatement();
		String sql = "SELECT * FROM myflorabase.user WHERE user_id=" + user.getUserId();
		ResultSet rs = statement.executeQuery(sql);
		if (rs.next()) {
			int userId = rs.getInt("user_id");
			String username = rs.getString("username");
			String password = rs.getString("password");
			String description = rs.getString("description");
			boolean isAdmin = rs.getBoolean("isAdmin");
			int zoom = rs.getInt("zoom");
			int location_id = rs.getInt("location_id");
			user = new User(userId, username, password, description, isAdmin, zoom, location_id);
		}

		String filtersSQL = "SELECT uf.filter_id, color, filter_name, active FROM myflorabase.user_filter uf, myflorabase.filter f WHERE uf.filter_id = f.filter_id AND user_id = '" + user.getUserId() + "'";
		rs = statement.executeQuery(filtersSQL);
		while (rs.next()) {
			int filterId = rs.getInt("filter_id");
			String color = rs.getString("color");
			String filterName = rs.getString("filter_name");
			int active = rs.getInt("active");
			boolean isActive = false;
			if (active == 1){
				isActive = true;
			}
			Filter filter = new Filter(filterId, color, filterName, isActive);
			filters.add(filter);
		}

		rs.close();
		statement.close();
		con.close();
	} catch (SQLException e) {
		System.out.println("SQLException caught: " + e.getMessage());
	}
	%>

	<script defer>

		function changeProfilePic(curProfilePicElement) {
			const fileUpload = document.getElementById('fileUpload');
			fileUpload.click();
			fileUpload.addEventListener("change", (e) => {
				const newProfilePic = event.target.files[0];
	            if (newProfilePic) {
	                const formData = new FormData();
            		formData.append('image', newProfilePic);
            		formData.append('condition', "user_id");
            		formData.append('conditionValue', <%=user.getUserId()%>);
            		formData.append("imageAttributeName", "profile_pic");
            		formData.append("table", "user");
	                const reader = new FileReader();
	                reader.onload = function(e) {
	                    curProfilePicElement.src = e.target.result;
	                };
	                reader.readAsDataURL(newProfilePic);
	                fetch('/myFlorabase/updateImage', {
	                    method: 'POST',
	                    body: formData
	                })
	                .then(response => response.text())  
	                .then(data => {
	                    console.log("File uploaded successfully:", data);
	                })
	                .catch(error => {
	                    console.error("Error uploading file:", error);
	                });
	            }
			})
		}

		function editDescription(button) {
			secondaryButtonClick(button);
			button.style.display = "none";
			const descriptionDiv = document.getElementById("descriptionDiv");
			const description = document.getElementById("description");
			if (description && descriptionDiv) {
				const temp = description.textContent;
				descriptionDiv.removeChild(description);
				const textField = document.createElement("textarea");
				textField.setAttribute("id", "descriptionEditBox");
				descriptionDiv.appendChild(textField);
				textField.focus();
				createSaveCancelButtons(descriptionDiv, "Save", "Cancel",
			            function(saveButton, buttonGroup) {
			                primaryButtonClick(saveButton);
			                const newDescription = textField.value;
			                fetch('/myFlorabase/updateDescription', { 
			                    method: 'POST',
			                    headers: {
			                        'Content-Type': 'application/x-www-form-urlencoded',
			                    },
			                    body: 'description=' + encodeURIComponent(newDescription) + '&userId=' + <%=user.getUserId()%>
			                })
			                .then(response => response.text())
			                .then(data => {
			                    console.log(data);
			                    endEditingDescription(newDescription, button, buttonGroup);
			                })
			                .catch(error => console.error('Error:', error));
			            },
			            function(cancelButton, buttonGroup) {
			                secondaryButtonClick(cancelButton);
			                endEditingDescription(temp, button, buttonGroup);
			            }
			        );
			}
		}

		function endEditingDescription(description, button, span) {
			const descriptionDiv = document.getElementById("descriptionDiv");
			const descriptionEditBox = document.getElementById("descriptionEditBox");
			const descriptionText = document.createElement("p");
			descriptionText.setAttribute("id", "description");
			if (descriptionDiv && span && descriptionEditBox) {
				descriptionText.textContent = description;
				descriptionDiv.removeChild(span);
				descriptionDiv.removeChild(descriptionEditBox);
				descriptionDiv.appendChild(descriptionText);
				button.style.display = "block";
			}
		}
		
		function editFilter(button) {
			secondaryButtonClick(button);
			button.style.display = "none";
			const zoomDiv = document.getElementById("zoomDiv");
			const zoom = document.getElementById("zoom");
			if (zoomDiv && zoom) {
				const temp = Number(zoom.textContent.split("%")[0]);
				zoomDiv.removeChild(zoom);
				const select = document.createElement("select");
				const options = [25, 50, 75, 100, 125, 150, 175, 200];
				for (const option of options) {
					const optionElement = document.createElement("option");
					optionElement.value = option;
					optionElement.textContent = option + "%";
					if (option === temp) {
						optionElement.selected = true;
					}
					select.appendChild(optionElement);
				}
				select.setAttribute("id", "zoomEditBox");
				zoomDiv.appendChild(select);
				createSaveCancelButtons(zoomDiv, "Save", "Cancel",
			            function(saveButton, buttonGroup) {
			                primaryButtonClick(saveButton);
			                const newZoom = select.value;
			                fetch('/myFlorabase/updateMapPreference', { 
			                    method: 'POST',
			                    headers: {
			                        'Content-Type': 'application/x-www-form-urlencoded',
			                    },
			                    body: 'zoom=' + encodeURIComponent(newZoom)<%--  + '&preferenceId=' + <%=mp.getPreferenceId()%> --%>
			                })
			                .then(response => response.text())
			                .then(data => {
			                    console.log(data);
			                    endEditingFilter(newZoom, button, buttonGroup);
			                })
			                .catch(error => console.error('Error:', error));
			            },
			            function(cancelButton, buttonGroup) {
			                secondaryButtonClick(cancelButton);
			                endEditingFilter(temp, button, buttonGroup);
			            }
			        );
			}
		}
		
		function endEditingFilter(zoom, button, span) {
			const zoomDiv = document.getElementById("zoomDiv");
			const zoomEditBox = document.getElementById("zoomEditBox");
			const zoomText = document.createElement("p");
			zoomText.setAttribute("id", "zoom");
			if (zoomDiv && zoomEditBox) {
				zoomText.textContent = zoom + "%";
				zoomDiv.removeChild(span);
				zoomDiv.removeChild(zoomEditBox);
				zoomDiv.appendChild(zoomText);
				button.style.display = "block";
			}
		}
		
		// open the new filter modal
		function newFilter(button, isAllergy) {
			const modalTitle = document.getElementById('modalTitle');			
			modalTitle.textContent = isAllergy ? "Add an Allergy" : "Add a New Filter";
			
			const modal = document.getElementById('filterModal');
			modal.style.display = "block";
		}
		
		// Close the new filter modal
		function closeNewFilterModal() {
			const modal = document.getElementById('filterModal');
			modal.style.display = "none";
			document.getElementById('filterForm').reset();
		}	
		
		// Form Submission for adding new filter
		function submitFilter(event) {
			event.preventDefault();
			
			// filter name
			const filterName = document.getElementById('filterName').value.trim();
			
			// selected plants
			const selectedPlants = document.querySelectorAll('#filterForm input[type="checkbox"]:checked');
			
			if (selectedPlants.length === 0) {
		        alert('Please select at least one plant option.');
		        return;  // Prevent form submission if no checkbox is selected
		    }
			
			// filter color
			const filterColor = document.getElementById('filterColor').value;
			
			// Prepare URL-encoded data
			const formData = new FormData();
			
			// Append the value of each checked checkbox to the FormData object
		    selectedPlants.forEach(function(checkbox) {
		        formData.append('selectedPlants', checkbox.value);
		    });
			
			formData.append('filterName', filterName);
			
			formData.append('filterColor', filterColor);
			
			 // Log each key-value pair in the FormData object
	        for (const [key, value] of formData.entries()) {
	            console.log(key, `:`, value);
	        }
						
			// Send the data to the server
			fetch('/myFlorabase/AddFilterServlet', {
				method: 'POST',
				body: formData // FormData handles setting the correct multipart/form-data header
			})
				.then(response => response.text())
				.then(data => console.log('Server response:', data))
				.catch(error => console.error('Error:', error));

			// Close the new filter modal
						
			closeNewFilterModal();

			setTimeout(function() {
			    location.reload();
			}, 3000);
		}
		
		// activate/deactivate filters
	    function updateActiveFilters() {
	    	
	    	const filterCheckboxes = document.querySelectorAll('.filters-checkbox');
	      	const activeFilters = [];
	      	const inactiveFilters = [];
	        filterCheckboxes.forEach(checkbox => {
	        	if (checkbox.checked) {
	        		activeFilters.push(checkbox.value);  // Store checked values
	        	} else {
	        		inactiveFilters.push(checkbox.value); // Store unchecked values
	        	}
	        }); 
	     	// Prepare URL-encoded data
			const formData = new FormData();
			
			// Append the value of each checked checkbox to the FormData object
		    activeFilters.forEach(value => {
		        formData.append('activeFilters', value);
		    });
			
			// Append the value of each unchecked checkbox to the FormData object
		    inactiveFilters.forEach(value => {
		        formData.append('inactiveFilters', value);
		    });
		    
		 	// Log each key-value pair in the FormData object
	        for (const [key, value] of formData.entries()) {
	            console.log(key, `:`, value);
	        }
						
			// Send the data to the server
			fetch('/myFlorabase/EditActiveFilterServlet', {
				method: 'POST',
				body: formData // FormData handles setting the correct multipart/form-data header
			})
				.then(response => response.text())
				.then(data => console.log('Server response:', data))
				.catch(error => console.error('Error:', error));
			
	    }
	 
		// delete filter
		function deleteFilter(filter_id) {
			fetch('/myFlorabase/DeleteFilterServlet', { 
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'filter_id=' + encodeURIComponent(filter_id)
            })
	            .then(response => response.text())
				.then(data => console.log('Server response:', data))
				.catch(error => console.error('Error:', error));
			
			setTimeout(function() {
			    location.reload();
			}, 3000);
		}
		


		
		
	</script>
	<jsp:include page="WEB-INF/components/header.jsp"></jsp:include>
	<div id="profilePage">
		<input type="file" id="fileUpload" style="display: none;"
			accept="image/*"> <span> <img id="profilePic"
			class="prevent-select <%=user.isAdmin() ? "isAdmin" : "isRegular"%>"
			src="/myFlorabase/getImage?condition=user_id&conditionValue=<%=user.getUserId()%>&imageAttributeName=profile_pic&table=user"
			onclick="changeProfilePic(this)" />
			<h1 class="<%=user.isAdmin() ? "isAdmin" : "isRegular"%>"
				id="profileUsername"><%=user.getUsername()%></h1>
		</span>
		<div id="descriptionDiv">
			<span class="section-title-with-button">
				<h2>Description</h2>
				<button class="secondary-button" onclick="editDescription(this)">Edit</button>
			</span>
			<p id="description"><%=user.getDescription()%></p>
		</div>
		<div id="allergyDiv">
			<span class="section-title-with-button">
				<h2>Allergies</h2>
				<button class="secondary-button" onclick="newFilter(this, true)">Edit</button>
			</span>
			<!-- need to change these to allergies -->
			<%
			for (Filter f : filters) {
			%>
			<label class="checkbox-label prevent-select"> <input
				type="checkbox" checked> <span class="checkbox"></span> <%=f.getFilterName()%></label>
			<%
			}
			%>
		</div>
		<div id="zoomDiv">
			<span class="section-title-with-button">
				<h2>Default Zoom</h2>
				<button class="secondary-button" onclick="editFilter(this)">Edit</button>
			</span>
			<p id="zoom"><%=user.getZoom()%>%
			</p>
		</div>
		<div id="filtersDiv">
			<span class="section-title-with-button">
				<h2>Filters</h2>
				<button class="secondary-button" onclick="newFilter(this, false)">New</button>
			</span>
			<%
			for (Filter f : filters) {
			%>
			<label class="checkbox-label prevent-select"> 
			<input
				type="checkbox" value="<%=f.getFilterId()%>" class="filters-checkbox" <%=f.isActive() ? "checked" : "" %> onchange="updateActiveFilters()"> 
				<span class="checkbox"></span> <%=f.getFilterName()%> <%=f.getFilterId() != 1 ? "<button class=\"icon-button\"> <img id=\"trash-icon\" onclick=\"deleteFilter(" + f.getFilterId()+ ")\" src=\"assets/trash_icon.svg\" width=\"20\" height=\"20\" class=\"icon-shown\"></button>" :"" %></label>
			<%
			}
			%>
		</div>

		<jsp:include page="WEB-INF/components/newFilter.jsp"></jsp:include>

	</div>
</body>
</html>