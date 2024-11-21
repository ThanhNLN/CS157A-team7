function primaryButtonClick(buttonId) {
	buttonId.style.border = '1px solid #EAAC9D';
	buttonId.style.background = 'white';
	buttonId.style.color = "#EAAC9D"

	setTimeout(() => {
		buttonId.style.border = '';
		buttonId.style.background = '#EAAC9D';
		buttonId.style.color = "black";
	}, 200);
}

function secondaryButtonClick(buttonId) {
	buttonId.style.background = '#EAAC9D';
	buttonId.style.color = "black"

	setTimeout(() => {
		buttonId.style.background = 'white';
		buttonId.style.color = "#EAAC9D";
	}, 200);
}

function createSaveCancelButtons(container, primaryButtonText, secondaryButtonText, saveCallback, cancelCallback) {
	const saveButton = document.createElement("button");
	saveButton.setAttribute("id", "primaryButton");
	const cancelButton = document.createElement("button");

	saveButton.setAttribute("class", "primary-button");
	cancelButton.setAttribute("class", "secondary-button");

	saveButton.textContent = primaryButtonText;
	cancelButton.textContent = secondaryButtonText;

	const buttonGroup = document.createElement("span");
	buttonGroup.setAttribute("id", "buttonGroup");

	buttonGroup.appendChild(saveButton);
	buttonGroup.appendChild(cancelButton);

	cancelButton.addEventListener("click", function() {
		cancelCallback(cancelButton, buttonGroup);
	});
	console.log(saveCallback);
	saveButton.addEventListener("click", function() {
		saveCallback(saveButton, buttonGroup);
	});
	container.appendChild(buttonGroup);
}

function createButtonGroup(container, primaryButtonText, secondaryButtonText, cancelCallback) {
	const saveButton = document.createElement("button");
	const cancelButton = document.createElement("button");

	saveButton.setAttribute("class", "primary-button");
	cancelButton.setAttribute("class", "secondary-button");

	saveButton.textContent = primaryButtonText;
	cancelButton.textContent = secondaryButtonText;

	const buttonGroup = document.createElement("span");
	buttonGroup.setAttribute("id", "buttonGroup");

	buttonGroup.appendChild(saveButton);
	buttonGroup.appendChild(cancelButton);

	cancelButton.addEventListener("click", function() {
		cancelCallback(cancelButton, buttonGroup);
	});
	saveButton.type = "submit";
	container.appendChild(buttonGroup);
}