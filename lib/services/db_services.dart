import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/conversations.dart';
import '../models/message.dart';
import '../models/users.dart';

class DbServices {
  Stream<List<Users>?>? getUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('name')
        .snapshots()
        .map((event) =>
            event.docs.map((e) => Users.fromJson(e.data())).toList());
  }

  Stream<Users>? getCurrentUser() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => Users.fromJson(e.data())).toList()[0]);
  }

  Future<void> addUser(Users user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.userId).set({
      'userId': user.userId,
      'name': user.name,
      'email': user.email,
      'image': user.image,
      'status': 'Online'
    });
  }

  Stream<List<Message>?>? getMessages(String chatid) {
    if (chatid == "") {
      return null;
    }
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatid)
        .collection('messages')
        .orderBy('sendTime', descending: true)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => Message.fromFirestore(e)).toList());
  }

  Stream<List<Conversations>?>? getConversations() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('conversations')
        .orderBy('sendTime', descending: true)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => Conversations.fromJson(e.data())).toList());
  }

  Future<void> updateSeenStatus(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('conversations')
        .doc(userId)
        .update({
      'status': 'seen',
    });
  }

  Future<void> sendMessage(String chatid, Message message) async {
    Conversations senderConversation =
        Conversations.fromSenderMessage(message, chatid);
    Conversations recieverConversation =
        Conversations.fromRecieverMessage(message, chatid);
    if (message is TextMessage) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatid)
          .collection('messages')
          .add(message.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.from)
          .collection('conversations')
          .doc(message.to)
          .set(recieverConversation.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.to)
          .collection('conversations')
          .doc(message.from)
          .set(senderConversation.toMap());
    } else if (message is ImageMessage) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatid)
          .collection('messages')
          .add(message.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.from)
          .collection('conversations')
          .doc(message.to)
          .set(recieverConversation.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.to)
          .collection('conversations')
          .doc(message.from)
          .set(senderConversation.toMap());
    } else if (message is GifMessage) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatid)
          .collection('messages')
          .add(message.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.from)
          .collection('conversations')
          .doc(message.to)
          .set(recieverConversation.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.to)
          .collection('conversations')
          .doc(message.from)
          .set(senderConversation.toMap());
    } else if (message is VideoMessage) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatid)
          .collection('messages')
          .add(message.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.from)
          .collection('conversations')
          .doc(message.to)
          .set(recieverConversation.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.to)
          .collection('conversations')
          .doc(message.from)
          .set(senderConversation.toMap());
    } else if (message is DocumentMessage) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatid)
          .collection('messages')
          .add(message.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.from)
          .collection('conversations')
          .doc(message.to)
          .set(recieverConversation.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.to)
          .collection('conversations')
          .doc(message.from)
          .set(senderConversation.toMap());
    } else if (message is AudioMessage) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatid)
          .collection('messages')
          .add(message.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.from)
          .collection('conversations')
          .doc(message.to)
          .set(recieverConversation.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(message.to)
          .collection('conversations')
          .doc(message.from)
          .set(senderConversation.toMap());
    }
  }

  Future<void> updateProfile(String url) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'image': url});
  }

  Future<void> userStatusOnline() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'status': 'Online'});
  }

  Future<void> userStatusOffline() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'status': 'Offline'});
  }

  Future<void> saveTokenToDatabase(String token) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('deviceTokens')
        .doc('deviceTokens')
        .set({
      'tokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  Future<void> deleteTokenFromDatabase() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String? token = await FirebaseMessaging.instance.getToken();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('deviceTokens')
        .doc('deviceTokens')
        .set({
      'tokens': FieldValue.arrayRemove([token]),
    }, SetOptions(merge: true));
    FirebaseMessaging.instance.deleteToken();
  }
}
