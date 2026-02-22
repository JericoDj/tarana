const admin = require("firebase-admin");
admin.initializeApp();

exports.booking = require("./src/booking");
exports.promo = require("./src/promo");
