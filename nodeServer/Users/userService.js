const { default: mongoose } = require("mongoose");
const User = require("./userModel");
const axios = require("axios");
const NodeCache = require("node-cache");
const cache = new NodeCache({ stdTTL: 15 });
require("dotenv").config();
const bcrypt = require("bcrypt");
class UserService {
  static async addFCMToken(email, newToken) {
    console.log(email, newToken);
    return await User.findOneAndUpdate(
      { email: email },
      {
        $push: { fcm_token: newToken },
      }
    ).exec();
  }
  static async getRandomUser() {
    console.log("It breaks here!");
    //const user = await User.aggregate([{ $sample: { size: 1 } }]).exec();
    //console.log(user);
    return null;
  }
  static async removeFCMToken(email, oldToken) {
    return User.findOneAndUpdate(
      { email: email },
      {
        $pull: { fcm_token: oldToken },
      }
    ).exec();
  }
  static async selectUserForRoom(givenRoom = null) {
    const user = User.aggregate([{ $sample: { size: 1 } }]);
    if (user.fcm_token == []) return false;
    sentNotification = false;
    for (token in user.fcm_tokn) {
      axios
        .post(process.env.SEND_NOTIFICATION_URL, {
          fcm_token: token,
          notificationTitle: "Check if you have been chosen!",
          notificationBody:
            "A user has been chosen to post, check if you are the one!",
          orderId: "1",
          room: givenRoom,
        })
        .then((res) => {
          if (res.status == 200) sentNotification = user.email;
        });
    }
    return sentNotification;
  }

  static async sendDummyNotification(givenRoom = null, email) {
    const users = User.where("email").ne(email);
    (await users).forEach((user) => {
      for (token in user.fcm_token) {
        axios.post(process.env.SEND_NOTIFICATION_URL, {
          fcm_token: token,
          notificationTitle: "Check if you have been chosen!",
          notificationBody:
            "A user has been chosen to post, check if you are the one!",
          orderId: "3",
          room: givenRoom,
        });
      }
    });
  }

  static async unselectUsersForRoom(givenRoom = null) {
    const users = User.where("fcm_token").ne(null);
    (await users).forEach((user) => {
      for (token in user.fcm_token) {
        axios.post(process.env.SEND_NOTIFICATION_URL, {
          fcm_token: token,
          notificationTitle: "A new user is about to be chosen!",
          notificationBody: "",
          orderId: "2",
          room: givenRoom,
        });
      }
    });
  }

  static async getAll() {
    return User.find();
  }
  static async getUser(username, password) {
    const user = await User.findOne({ username: username }).exec();
    if (user == null) {
      throw "Wrong username or password";
    }
    const correctPassword = await bcrypt.compare(password, user.passwordHash);
    if (correctPassword) {
      return user;
    }
    throw "Wrong username or password";
  }

  static async getUserPersistent(username, password) {
    const user = await User.findOne({ username: username }).exec();
    if (user == null) {
      throw "Wrong username or password";
    }
    if (password == user.passwordHash) return user;
    return "Wrong username or password";
  }

  static async emailInUse(email) {
    const user = await User.findOne({ email: email }).exec();
    if (user != null) return true;
    return false;
  }
  static async usernameInUse(username) {
    const user = await User.findOne({ username: username }).exec();
    if (user != null) return true;
    return false;
  }
  static async save(body) {
    console.log("RUNNING SAVE FUNCTION");
    console.log(body);
    if (body.password.length < 5) throw "Password too short";

    const newSalt = await bcrypt.genSalt();
    const passHash = await bcrypt.hash(body.password, newSalt);
    const newUser = new User({
      _id: new mongoose.Types.ObjectId(),
      username: body.username,
      name: body.name,
      email: body.email,
      passwordHash: passHash,
      fcm_token: [body.fcm_token],
    });
    if (newUser.username.length < 1) throw "Username too short";

    return await newUser.save();
  }
}

module.exports = UserService;
