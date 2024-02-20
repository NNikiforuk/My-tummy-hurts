const router = require("express").Router();
const pool = require("../database/db");
const authorization = require("../middleware/authorization");

router.get("/", authorization, async (req, res) => {
	try {
		const user = await pool.query(
			"SELECT user_name FROM users WHERE user_id = $1",
			[req.user]
		);
		res.json(user.rows[0]);
	} catch (error) {
		res.json("Server error", error);
	}
});

module.exports = router;
