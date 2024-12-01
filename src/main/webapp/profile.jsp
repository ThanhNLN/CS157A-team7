<%@ page
	import="java.sql.*, com.example.User, com.example.MapPreference, com.example.Filter, com.example.Plant, java.util.List, java.util.ArrayList"%>
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
	List<Plant> plantsAllergicTo = new ArrayList<>();
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

		String filtersSQL = "SELECT uf.filter_id, color, filter_name, active FROM myflorabase.user_filter uf, myflorabase.filter f WHERE uf.filter_id = f.filter_id AND user_id = '"
		+ user.getUserId() + "'";
		rs = statement.executeQuery(filtersSQL);
		while (rs.next()) {
			int filterId = rs.getInt("filter_id");
			String color = rs.getString("color");
			String filterName = rs.getString("filter_name");
			int active = rs.getInt("active");
			boolean isActive = false;
			if (active == 1) {
		isActive = true;
			}
			Filter filter = new Filter(filterId, color, filterName, isActive);
			filters.add(filter);
		}
		String allergiesSQL = "SELECT * FROM myflorabase.allergic a JOIN myflorabase.plant p ON a.user_id="
		+ user.getUserId() + " AND p.plant_id = a.plant_id";
		rs = statement.executeQuery(allergiesSQL);
		while (rs.next()) {
			int plantId = rs.getInt("plant_id");
			String name = rs.getString("name");
			String scientificName = rs.getString("scientific_name");
			String description = rs.getString("description");
			boolean poisonous = rs.getBoolean("poisonous");
			boolean invasive = rs.getBoolean("invasive");
			boolean endangered = rs.getBoolean("endangered");
			Plant plant = new Plant(plantId, name, scientificName, description, poisonous, invasive, endangered);
			plantsAllergicTo.add(plant);
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
	                    window.location.reload();
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
				textField.value = temp;
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
		
		function editZoom(button) {
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
			                    body: 'zoom=' + encodeURIComponent(newZoom)
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
			document.documentElement.scrollTop = 0;
			document.body.scrollTop = 0;
			document.body.style.overflowY = "hidden";
			const filterModal = document.getElementById('filterModal');
			const noPlantErrorMsg = document.getElementById("noPlantErrorMsg");
			noPlantErrorMsg.style.display = "none";
			const filterForm = document.getElementById('filterForm');
			const modalTitle = document.getElementById('modalTitle');			
			modalTitle.textContent = isAllergy ? "Add an Allergy" : "Add a New Filter";
			const filterModalLabel = document.getElementById('filterModalLabel');
			const filterName = document.getElementById('filterName');
			const colorSelectGroup = document.getElementById('colorSelectGroup');
			const filterColor = document.getElementById('filterColor');
			const filterModalPlantCheckboxes = document.getElementById('filterModalPlantCheckboxes');
			const searchBar = document.getElementById("searchBar");
			const tagList = document.getElementById("tagList");
			const filterCancelButton = document.getElementById("filterCancelButton");
			filterCancelButton.addEventListener('click', function() {
				tagList.innerHTML = '';
				closeNewFilterModal();
			});
			if (isAllergy) {
				filterModalPlantCheckboxes.style.display = "none";
				filterModalLabel.style.display = "none";
				filterName.removeAttribute('required');
				colorSelectGroup.style.display = "none";
				filterColor.removeAttribute('required');
				filterName.style.display = "none";
				filterForm.onsubmit = function(event) {
					  submitAllergy(event);
				};
			} else {
				colorSelectGroup.style.display = "block";
				filterName.setAttribute('required', "true");
				filterModalLabel.style.display = "block";
				filterColor.setAttribute('required', "true");
				colorSelectGroup.style.display = "block";
				filterName.style.display = "block";
				filterModalPlantCheckboxes.style.display = "block";
				filterModalLabel.textContent = "Filter Name";
				filterName.placeholder = "Give this filter a name";
				filterForm.onsubmit = function(event) {
					  submitFilter(event);
				};
			}
			const filterModalPlantLabel = document.getElementById('filterModalPlantLabel');
			filterModalPlantLabel.textContent = "Note: Only plants that have been reported will be saved";
			filterForm.addEventListener('keydown', function(event) {
				if (event.key === 'Enter') {
				   event.preventDefault(); 
				}
			});
			searchBar.addEventListener('keydown', function(event) {
				const plantName = searchBar.value;
			    if (event.key === 'Enter' && plantName != "") {
			      const tag = document.createElement("div");
			      tag.classList.add("tag");
			      const temp = document.createElement("span");
			      const tagText = document.createElement("p");
			      tagText.textContent = plantName;
			      temp.appendChild(tagText);
			      const xIcon = document.createElement("img");
			      xIcon.style.verticalAlign = "middle";
			      xIcon.src = 'assets/x_icon.svg';
			      xIcon.addEventListener('click', function() {
			    	  const tagListTemp = document.getElementById("tagList");
			    	  const curTag = this.parentElement.parentElement;
			    	  tagListTemp.removeChild(curTag);
			      });
			      temp.appendChild(xIcon);
			      tag.appendChild(temp);
			      tagList.appendChild(tag);
			      searchBar.value = "";
			    }
			  });
			const modal = document.getElementById('filterModal');
			modal.style.display = "block";
			
			const modalContent = document.getElementById('filterModalContent');
			modalContent.style.display = "block";
		}
		
		function submitAllergy(event) {
			event.preventDefault();
			const tagList = document.getElementById("tagList");
			const tagArr = Array.from(tagList.children);
			tagArr.forEach((tag) => {
				const plantName = tag.children[0].children[0].textContent.trim();
				fetch("/myFlorabase/getPlant?plantName=" + plantName, {
		  		  method: 'GET',
		  		})
		  	  .then(response => {
		  		  return response.json();
		  	  })
		  	  .then(plant => {
		  		fetch('/myFlorabase/addAllergy', { 
	                method: 'POST',
	                headers: {
	                    'Content-Type': 'application/x-www-form-urlencoded',
	                },
	                body: 'userId=' + <%=user.getUserId()%> + "&plantId=" + plant[0].plantId
	            })
		            .then(response => response.text())
					.then(data => {
						tagList.innerHTML = '';
						closeNewFilterModal();
						window.location.reload();
					})
					.catch(error => console.error('Error:', error));
		  	  })
		  	  .catch(error => { 
		  		  console.log("One of these plant(s) have not been reported");
		  		  const noPlantErrorMsg = document.getElementById("noPlantErrorMsg");
		  		noPlantErrorMsg.style.display = "block";
		  		  })
			});
		}
		
		function deleteAllergy(trashIcon) {
			const plantName = trashIcon.closest('label').textContent.trim();
			this.src = 'assets/trash_icon_hover.svg';
			console.log(plantName);
			fetch("/myFlorabase/getPlant?plantName=" + plantName, {
		  		  method: 'GET',
		  		})
		  	  .then(response => {
		  		  return response.json();
		  	  })
		  	  .then(plant => {
		  		  console.log(plant);
		  		fetch('/myFlorabase/deleteAllergy', { 
	                method: 'POST',
	                headers: {
	                    'Content-Type': 'application/x-www-form-urlencoded',
	                },
	                body: 'userId=' + <%=user.getUserId()%> + "&plantId=" + plant[0].plantId
	            })
		            .then(response => response.text())
					.then(data => {
						window.location.reload();
					})
					.catch(error => console.error('Error:', error));
		  	  })
		}
		
		// Close the new filter modal
		function closeNewFilterModal() {
			document.body.style.overflowY = "scroll";
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
					
			// loading screen
			const modalContent = document.getElementById("filterModalContent");
			modalContent.style.display = "none";
			const lottieFileAnim = document.getElementById("lottieFileAnim");
			lottieFileAnim.style.display = "flex";
			lottieFileAnim.style.position = "fixed";
			lottieFileAnim.style.top = 0;
			lottieFileAnim.style.left = 0;
			lottieFileAnim.style.justifyContent = "center";
			lottieFileAnim.style.alignItems = "center";
			lottieFileAnim.style.width = "100%";
			lottieFileAnim.style.height = "100%";
            document.getElementById("filter-loading-text").textContent = "Saving your filter...";
			 
			// Send the data to the server
			fetch('/myFlorabase/AddFilterServlet', {
				method: 'POST',
				body: formData // FormData handles setting the correct multipart/form-data header
			})
				.then(response => response.text())
				/* .then(data => console.log('Server response:', data)) */
				
				
				.then(data => {
					console.log('Successfully completed operation');
					setTimeout(function() {
						lottieFileAnim.style.display = "none";
						closeNewFilterModal();
						createFilterPopup(null, "Your new filter has been successfully created!", "Close", "", false);
					}, 2000);
				})
				
				.catch(error => console.error('Error:', error));

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
			// loading screen
			const modal = document.getElementById('filterModal');
			modal.style.display = "block";
			const modalContent = document.getElementById("filterModalContent");
			modalContent.style.display = "none";
			const lottieFileAnim = document.getElementById("lottieFileAnim");
			lottieFileAnim.style.display = "flex";
			lottieFileAnim.style.position = "fixed";
			lottieFileAnim.style.top = 0;
			lottieFileAnim.style.left = 0;
			lottieFileAnim.style.justifyContent = "center";
			lottieFileAnim.style.alignItems = "center";
			lottieFileAnim.style.width = "100%";
			lottieFileAnim.style.height = "100%";
            document.getElementById("filter-loading-text").textContent = "Deleting your filter...";
			
			fetch('/myFlorabase/DeleteFilterServlet', { 
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'filter_id=' + encodeURIComponent(filter_id)
            })
	            .then(response => response.text())
				.then(data => {
					console.log('Successfully completed operation');
					setTimeout(function() {
						lottieFileAnim.style.display = "none";
						closeNewFilterModal();
						createFilterPopup(filter_id, "Your filter has been successfully deleted!", "Close", "", false);
					}, 3000);
				})
				.catch(error => console.error('Error:', error));
		}
		
		function createFilterPopup(filter_id, message, primaryButtonText, secondaryButtonText, primaryCallback) {
			
			const popupContainer = document.getElementById("popupContainer");
			popupContainer.style.display = "flex";
			popupContainer.classList.add('popup-modal');
			
			const popup = document.createElement('div');
			popup.classList.add('popup-modal-content');
						
			const popupMessage = document.createElement('p');
			popupMessage.textContent = message;
			popupMessage.classList.add('popup-modal-message');

			popup.appendChild(popupMessage);

			if (secondaryButtonText !== "") {
				
				const primaryButton = document.createElement("button");
				primaryButton.setAttribute("id", "primaryButton");
				const secondaryButton = document.createElement("button");

				primaryButton.setAttribute("class", "primary-button");
				secondaryButton.setAttribute("class", "secondary-button");

				primaryButton.textContent = primaryButtonText;
				secondaryButton.textContent = secondaryButtonText;

				const buttonGroup = document.createElement("span");
				buttonGroup.setAttribute("id", "buttonGroup");

				buttonGroup.appendChild(primaryButton);
				buttonGroup.appendChild(secondaryButton);

				primaryButton.addEventListener("click", function() {
					window.location.reload();
				}); 
				secondaryButton.addEventListener("click", function() {
					popupContainer.style.display = "none";
					popup.style.display = "none";
					deleteFilter(filter_id);
				});
				
				popup.appendChild(buttonGroup);
				
			} else {
				
				const primaryButton = document.createElement("button");
				primaryButton.classList.add("primary-button", "popup-modal-button");
				primaryButton.textContent = primaryButtonText;
				
				primaryButton.addEventListener("click", function() {
					window.location.reload();
				});
				popup.appendChild(primaryButton);
			}
			

			popupContainer.appendChild(popup);
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
			<%
			if (plantsAllergicTo.size() < 1) {
			%>
			<p>You have not listed any allergies.</p>
			<%
			}
			for (Plant p : plantsAllergicTo) {
			%>


			<label class="checkbox-label prevent-select"> <%=p.getName()%>
				<button class="icon-button">
					<img id="trash-icon" onclick="deleteAllergy(this)"
						onmouseover="this.src='assets/trash_icon_hover.svg'"
						onmouseout="this.src='assets/trash_icon.svg'"
						src="assets/trash_icon.svg" width="15" height="15"
						class="icon-shown">
				</button>
			</label>
			<%
			}
			%>
		</div>
		<div id="zoomDiv">
			<span class="section-title-with-button">
				<h2>Default Zoom</h2>
				<button class="secondary-button" onclick="editZoom(this)">Edit</button>
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
			<label id="filter-checkbox-row" class="checkbox-label prevent-select">
				<input type="checkbox" value="<%=f.getFilterId()%>"
				class="filters-checkbox" <%=f.isActive() ? "checked" : ""%>
				onchange="updateActiveFilters()"> <span class="checkbox"></span>
				<%=f.getFilterName()%> <span class="icon-row"> <%=f.getFilterId() != 1
		? "<button id='editButton' class='icon-button'><img onmouseover='editMouseover(this)' onmouseout='editMouseout(this)' onclick='editClick("
				+ f.getFilterId() + ", \"" + f.getFilterName() + "\", \"" + f.getColor()
				+ "\")' src='assets/edit_icon.svg' width='20' height='20' class='icon-shown'> </button>	<button class='icon-button'> <img id='trash-icon' onmouseover='trashMouseover(this)' onmouseout='trashMouseout(this)' onclick='deleteFilterConfirmation("
				+ f.getFilterId() + ", \"" + f.getFilterName()
				+ "\")' src='assets/trash_icon.svg' width='20' height='20' class='icon-shown'></button>"
		: ""%>
			</span>
			</label>
			<%
			}
			%>
		</div>

		<div><jsp:include page="WEB-INF/components/newFilter.jsp"></jsp:include></div>

		<div id="popupContainer"></div>

	</div>
</body>
<script>
	

	function editMouseover(img){
		img.src='assets/edit_icon_hover.svg';
	}
	
	function editMouseout(img){
		img.src='assets/edit_icon.svg';
	}
	
	function editClick(filter_id, filter_name, filter_color){
		const filterForm = document.getElementById('filterForm');
		filterForm.setAttribute("onsubmit", "editFilter(event, "+ filter_id + ")");
		
		const modal = document.getElementById('filterModal');
		modal.style.display = "block";
		
		const modalContent = document.getElementById('filterModalContent');
		modalContent.style.display = "block";
		
		const filterName = document.getElementById('filterName');
		const filterColor =  document.getElementById('filterColor');
		//const plants = document.getElementById('');
		// TODO: load the plants that should be checked
		fetch("/myFlorabase/EditFilterServlet?filter_id=" + filter_id, {
			method: 'GET',
		})
		.then(response => {
			return response.json();
		})
		.then(info => {
			console.log(info);
			// set the checks?
			info.forEach(filterNum => {
				console.log(filterNum);
				document.getElementById('plantId'+ filterNum).checked = true;
			});
			
		})
		.catch(error => {
        		  console.error("Issue with fetching from EditFilterServlet", error);
        });
		
		if (filter_id != null){
			const modalTitle = document.getElementById('modalTitle');			
			modalTitle.textContent = "Edit Filter";
			
			filterName.value = filter_name;
			filterColor.value = filter_color;
		}
	}
	
	// Form Submission for editing filter
	function editFilter(event, filter_id) {
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
		
		formData.append('filterId', filter_id);
		
		 // Log each key-value pair in the FormData object
        for (const [key, value] of formData.entries()) {
            console.log(key, `:`, value);
        }
				
		// loading screen
		const modalContent = document.getElementById("filterModalContent");
		modalContent.style.display = "none";
		const lottieFileAnim = document.getElementById("lottieFileAnim");
		lottieFileAnim.style.display = "flex";
		lottieFileAnim.style.position = "fixed";
		lottieFileAnim.style.top = 0;
		lottieFileAnim.style.left = 0;
		lottieFileAnim.style.justifyContent = "center";
		lottieFileAnim.style.alignItems = "center";
		lottieFileAnim.style.width = "100%";
		lottieFileAnim.style.height = "100%";
        document.getElementById("filter-loading-text").textContent = "Saving your filter...";
		 
		// Send the data to the server
		fetch('/myFlorabase/EditFilterServlet', {
			method: 'POST',
			body: formData // FormData handles setting the correct multipart/form-data header
		})
			.then(response => response.text())
			
			.then(data => {
				console.log('Successfully completed operation');
				setTimeout(function() {
					lottieFileAnim.style.display = "none";
					closeNewFilterModal();
					createFilterPopup(null, "Your filter has been successfully edited!", "Close", "", false);
				}, 3000);
			})
			
			.catch(error => console.error('Error:', error));

	}
	
	
	
	function trashMouseover(img){
		img.src='assets/trash_icon_hover.svg';
	}
	
	function trashMouseout(img){
		img.src='assets/trash_icon.svg';	
	}

	// delete filter confirmation box, trash img onclick
	function deleteFilterConfirmation(filter_id, filter_name){
		createFilterPopup(filter_id, "Are you sure you want to delete '" + filter_name + "'?", "Cancel", "Delete", false);
	}


</script>
</html>