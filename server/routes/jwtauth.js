const express = require("express");
const router = express.Router();
const pool = require("../database/db");
const bcrypt = require("bcrypt");
const jwtGenerator = require("../utils/jwtGenerator");
const validation = require("../middleware/validation");
const authorization = require("../middleware/authorization");

//Registration
router.post("/register", validation, async (req, res) => {
	try {
		const { name, email, password } = req.body;
		const user = await pool.query("SELECT * FROM users WHERE user_email = $1", [
			email,
		]);

		if (user.rows.length > 0) {
			return res.json("An account is already linked to that e-mail");
		}

		const salt = await bcrypt.genSalt(10);
		const bcryptPassword = await bcrypt.hash(password, salt);
		const newUser = await pool.query(
			"INSERT INTO USERS(user_name, user_email, user_password) VALUES($1, $2, $3) RETURNING *",
			[name, email, bcryptPassword]
		);
		const token = jwtGenerator(newUser.rows[0].user_id);
		res.json({ name, token });
	} catch (err) {
		res.send("Server Error", error);
	}
});

//Login
router.post("/", validation, async (req, res) => {
	try {
		const { email, password } = req.body;
		const user = await pool.query("SELECT * FROM users WHERE user_email = $1", [
			email,
		]);

		if (user.rows.length === 0) {
			return res.json("Password or username is incorrect");
		}

		const passwordValid = await bcrypt.compare(
			password,
			user.rows[0].user_password
		);

		if (!passwordValid) {
			return res.status(401).json("Password or e-mail is incorrect.");
		}

		const token = jwtGenerator(user.rows[0].user_id);
		const name = user.rows[0].user_name;
		res.json({ name, token });
	} catch (err) {
		res.status(500).send("Server Error");
	}
});

router.post("/verified", authorization, (req, res) => {
	try {
		res.json(true);
	} catch (err) {
		res.status(500).send("Server Error");
	}
});

module.exports = router;
