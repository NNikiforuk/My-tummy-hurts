const jwt = require("jsonwebtoken");
require("dotenv").config();

async function authorization(req, res) {
	try {
		const jwtToken = req.header("token");

		if (!jwtToken) {
			return res.json("Not authorized");
		}

		const payload = jwt.verify(jwtToken, process.env.jwtSecret);

		req.user = payload.user;
	} catch (error) {
		return res.json("Not authorized, error");
	}
}

module.exports = authorization;
