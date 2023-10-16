import 'package:mongo_dart/mongo_dart.dart';
import "../utils/constants.dart";
import "../domain/person.dart";

class MongoDatabase {
  static var db;
  static var userCollection;
  MongoDatabase() {
    MongoDatabase.connect();
  }
  static connect() async {
    db = await Db.create(MONGO_CONN_URL);
    print(MONGO_CONN_URL);
    await db.open();
    print(db);
    userCollection = await db.collection(USER_COLLECTION);
  }

  void addNewUser(Person new_user) async {
    WriteResult res = await userCollection.insertOne(new_user.toMap());
    print(db.isConnected);
    print("A new user has been added!");
  }
}
