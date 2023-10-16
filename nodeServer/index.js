require("dotenv").config();
const express = require("express");
const database = require("./db.js");
const bodyParser = require("body-parser");
const cron = require("node-cron");
const app = express();
const axios = require("axios");
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
const PORT = process.env.PORT || 3000;
console.log(PORT);
const userController = require("./Users/userController.js");
const pushNotificationController = require("./PushNotifications/PushNotificationController.js");

app.use("/users", userController);
app.use("/pushNotification", pushNotificationController);

app.listen(PORT, () => {
  console.log(`Server is running on PORT : ${PORT}`);
  cron.schedule("*/200 * * * * *", async () => {
    console.log("Entered here");
    const r = await axios.post(`${process.env.BASE_USER_URL}/setUser`, {});
    const t = await axios.post(`${process.env.BASE_USER_URL}/unselectUser`, {});
    console.log("Now here");
  });
});
