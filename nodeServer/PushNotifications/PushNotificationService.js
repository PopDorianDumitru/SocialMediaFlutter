var admin = require("firebase-admin");
var fcm = require("fcm-notification");

var serviceAccount = require("../config/push_notification_key.json");
const certPath = admin.credential.cert(serviceAccount);
var FCM = new fcm(certPath);

exports.sendNotification = async (req, res, next) => {
  try {
    let message = {
      notification: {
        title: req.body.notificationTitle,
        body: req.body.notificationBody,
      },
      data: {
        orderId: req.body.orderId,
        orderDate: new Date().toISOString(),
      },
      token: req.body.fcm_token,
      room: req.body.room,
    };
    FCM.send(message, function (err, resp) {
      if (err) {
        return res.status(500).send({
          message: err,
        });
      } else {
        return res.status(200).send({
          message: "Notification sent",
        });
      }
    });
  } catch (err) {}
};
