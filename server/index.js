const express = require("express");
const app = express();
const port = 3000;

app.use(express.json());

app.use("/auth", require("./routes/jwtauth"));
app.use("/dashboard", require("./routes/dashboard"));

app.listen(port, () => {
	console.log(`Server running on port ${port}`);
});
