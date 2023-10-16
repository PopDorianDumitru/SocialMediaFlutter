const mongoose = require("mongoose");

const PostSchema = new mongoose.Schema({
  title: String,
  text: String,
  allowComments: Boolean,
  comments: Array,
  reaction: Map,
});

const Post = mongoose.model("Post", PostSchema);

module.exports = Post;
