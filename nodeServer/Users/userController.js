const express = require("express");
const router = express.Router();
const UserService = require("./userService");
const { default: axios } = require("axios");
require("dotenv").config();
const NodeCache = require("node-cache");
const cache = new NodeCache({ stdTTL: 15 });
router.get("/", async (req, res) => {
  try {
    const users = await UserService.getAll();
    res.json(users);
  } catch (error) {
    console.error(error);
    res.status(500).send("Server error");
  }
});

router.post("/addFCMToken", async (req, res) => {
  console.log("Add fcm token!");
  result = await UserService.addFCMToken(req.body.email, req.body.fcmToken);
  if (result == null) res.status(500).send("Server error!");
  else res.status(200);
});

router.post("/unselectUser", async (req, res) => {
  if (cache.has(process.env.SELECTED_USER_ID))
    cache.del(process.env.SELECTED_USER_ID);
  console.log("Finished unselecting");
  return res.status(200);
});

router.post("/removeFCMToken", async (req, res) => {
  result = await UserService.removeFCMToken(req.body.email, req.body.fcmToken);
  if (result == null) res.status(500).send("Server error!");
  else res.status(200);
});

router.post("/getSelectedUser", async (req, res) => {
  if (cache.has(process.env.SELECTED_USER_ID)) {
    return res.json(cache.get(process.env.SELECTED_USER_ID));
  } else {
    return res.send("No selected user yet");
  }
});

router.post("/setUser", async (req, res) => {
  console.log("Got here!");
  if (cache.has(process.env.SELECTED_USER_ID))
    cache.del(process.env.SELECTED_USER_ID);
  const user = await UserService.getRandomUser();
  //console.log(user.email);
  //cache.set(process.env.SELECTED_USER_ID, {
  //email: user.email,
  //});
});

router.post("/logout", async (req, res) => {
  result = await UserService.removeFCMToken(req.body.email, req.body.fcmToken);
  res.status(200);
});

router.post("/selectUserForRoom", async (req, res) => {
  result = await UserService.selectUserForRoom(req.body.room);
  if (result) res.status(200).send(result);
  else res.status(500).send("Server error!");
});

router.post("/unselectUsersForRoom", async (req, res) => {
  result = await UserService.unselectUsersForRoom(req.body.room);
  if (result) res.status(200);
  else res.status(500).send("Server error!");
});

router.post("/dummyNotification", async (req, res) => {
  await UserService.sendDummyNotification(req.body.room, req.body.email);
});

router.post("/register", async (req, res) => {
  try {
    console.log("Post request");
    const emailInUse = await UserService.emailInUse(req.body.email);
    if (emailInUse) throw "Email already in use";
    const usernameInUse = await UserService.usernameInUse(req.body.username);
    if (usernameInUse) throw "Username already exists";

    const user = await UserService.save(req.body);

    res.json(user);
  } catch (error) {
    console.error(error);
    if (error == "Username already exists")
      res.status(409).send("Username already exists");
    else if (error == "Email already in use")
      res.status(409).send("Email already in use");
    else res.status(500).send("Server error");
  }
});

router.post("/loginPersistent", async (req, res) => {
  try {
    console.log("LOGIN REQUEST");
    const user = await UserService.getUserPersistent(
      req.body.username,
      req.body.password
    );
    console.log(user);
    res.json(user);
  } catch (error) {
    console.log(error);
    if (error == "Wrong password or username")
      res.send("Wrong password or username");
    else res.status(500).send("Server error");
  }
});

router.post("/login", async (req, res) => {
  try {
    console.log("LOGIN REQUEST");
    const user = await UserService.getUser(
      req.body.username,
      req.body.password
    );
    console.log(user.fcm_token);
    if (!user.fcm_token.includes(req.body.fcm_token))
      axios.post(`${process.env.BASE_USER_URL}/addFCMToken`, {
        fcmToken: req.body.fcm_token,
        email: user.email,
      });
    console.log(user);
    res.json(user);
  } catch (error) {
    console.log(error);
    if (error == "Wrong password or username")
      res.send("Wrong password or username");
    else res.status(500).send("Server error");
  }
});

module.exports = router;
