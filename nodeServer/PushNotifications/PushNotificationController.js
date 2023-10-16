const pushNotificationService = require("./PushNotificationService.js");
const express = require("express");
const router = express.Router();

router.post("/sendNotification", pushNotificationService.sendNotification);

module.exports = router;
