//Validation for login an registration
function validateAuthData(req, res) {
	const { email, name, password } = req.body;

	function isEmailValid(userEmail) {
		return /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(userEmail);
	}

	if (req.path === "/register") {
		if (!email || !name || !password) {
			return res.json("One or more fields are missing");
		} else if (!isEmailValid(email)) {
			return res.json("Invalid e-mail");
		}
	} else if (req.path === "/") {
		if (!email || !password) {
			return res.json("Missing info");
		} else if (!isEmailValid(email)) {
			return res.json("Invalid e-mail");
		}
	}
}

module.exports = validateAuthData;
