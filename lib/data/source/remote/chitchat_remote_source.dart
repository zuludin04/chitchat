import 'dart:io';

import 'package:chitchat/data/model/chat.dart';
import 'package:chitchat/data/model/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

abstract class ChitChatRemoteSource {
  Future<User?> signInEmail(String email, String password);

  Future<User?> signInGoogle();

  Stream<QuerySnapshot<Map<String, dynamic>>> streamLiveChat(String groupId);

  Future<void> sendChatMessage(Chat chat);

  Stream<QuerySnapshot<Map<String, dynamic>>> streamGroupMessage();

  Future<void> createGroup(Group group);
}

@Singleton(as: ChitChatRemoteSource)
class ChitChatRemoteSourceImpl extends ChitChatRemoteSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth authentication;
  final GoogleSignIn googleSignIn;
  final FirebaseStorage storage;

  ChitChatRemoteSourceImpl({
    required this.firestore,
    required this.authentication,
    required this.googleSignIn,
    required this.storage,
  });

  @override
  Future<User?> signInEmail(String email, String password) async {
    try {
      final credential = await authentication.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return _createNewUser(email, password);
      } else {
        throw Exception(e.code);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<User?> signInGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final signInCredential =
          await authentication.signInWithCredential(credential);
      return signInCredential.user;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> streamLiveChat(String groupId) {
    return firestore
        .collection('chat')
        .where('groupId', isEqualTo: groupId)
        .orderBy('messageSent', descending: false)
        .snapshots();
  }

  @override
  Future<void> sendChatMessage(Chat chat) async {
    var collection = firestore.collection('chat');
    var docId = collection.doc().id;

    if (chat.mediaFile != null) {
      var url = await _saveMediaToStorage(chat);
      await collection.doc(docId).set(chat.toMap(id: docId, message: url));
    } else {
      await collection.doc(docId).set(chat.toMap(id: docId));
    }
    await _updateGroupLastMessage(chat);
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> streamGroupMessage() {
    return firestore
        .collection('group')
        .orderBy('lastSent', descending: true)
        .snapshots();
  }

  @override
  Future<void> createGroup(Group group) async {
    var collection = firestore.collection('group');
    var docId = collection.doc().id;
    await collection.doc(docId).set(group.toMap(groupId: docId));
  }

  Future<String> _saveMediaToStorage(Chat chat) async {
    try {
      var imageRef = storage.ref().child(chat.mediaFile!.name);
      await imageRef.putFile(File(chat.mediaFile!.path));
      var downloadUrl = await imageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _updateGroupLastMessage(Chat chat) async {
    var ref = firestore.collection('group').doc(chat.groupId);
    ref.update({
      'lastMessage': chat.message,
      'lastSender': chat.senderName,
      'lastSent': chat.messageSent,
    });
  }

  Future<User?> _createNewUser(String email, String password) async {
    try {
      final credential = await authentication.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      throw Exception(e);
    }
  }
}
