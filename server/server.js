//@ts-check

const express = require("express");
const app = express();
const port = 8080;

app.get("/", async (req, res) => {
	res.send("Hello world!");
});

app.listen(port, () => {
	console.log(`Example app listening at http://localhost:${port}`);
});

const myPromise = new Promise((resolve, reject) => {
	setTimeout(() => {
		resolve("good");
	}, 300);
	reject("bad");
});

myPromise.then(() => {
	console.log("This will never run");
});
