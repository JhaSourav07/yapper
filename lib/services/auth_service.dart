import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:yapper/services/firestore_service.dart';

import '../models/user_model.dart';



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Getters
  User? get currentUser => _auth.currentUser;
  String? get userId => currentUser?.uid;

  // Stream for auth state (used in Riverpod providers)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in user and updates their online status in Firestore
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Update presence in Firestore
        await _firestoreService.updateUserOnlineStatus(user.uid, true);
        
        // Fetch and return your custom User Model
        return await _firestoreService.getUser(user.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // It's better to catch specific Firebase errors
      throw Exception(e.message ?? "An unknown authentication error occurred.");
    } catch (e) {
      throw Exception("Failed to sign in: $e");
    }
  }

  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Update presence in Firestore
        await user.updateDisplayName(displayName);
        final userModel = UserModel(
          id: user.uid,
          name: displayName,
          email: email,
          displayName: displayName,
          photoUrl: '',
          isOnline: true,
          lastSeen: DateTime.now(),
          createdAt: DateTime.now(),
        );
        
        // Fetch and return your custom User Model
        await _firestoreService.createUser(userModel);
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // It's better to catch specific Firebase errors
      throw Exception(e.message ?? "An unknown authentication error occurred.");
    } catch (e) {
      throw Exception("Failed to Register: $e");
    }

    
  

    }
    Future<void> sendPasswordResetEmail({required String email}) async {
      try {
        await _auth.sendPasswordResetEmail(email: email);
      } on FirebaseAuthException catch (e) {
        throw Exception(e.message ?? "An unknown error occurred.");
      } catch (e) {
        throw Exception("Failed to send password reset email: $e");
      }
    }

    Future<void> signOut() async {
      try {
        // Update presence in Firestore
        if (currentUser != null) {
          await _firestoreService.updateUserOnlineStatus(currentUser!.uid, false);
        }
        await _auth.signOut();
      } catch (e) {
        throw Exception("Failed to sign out: $e");
      }
    }

    Future<void> deleteAccount() async {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          // Delete user data from Firestore
          await _firestoreService.deleteUser(user.uid);
          // Delete user from Firebase Auth
          await user.delete();
        }
      } catch (e) {
        throw Exception("Failed to delete account: $e");
      }
    }
}
