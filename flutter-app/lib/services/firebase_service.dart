import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Centralized Firebase service for the Cannasol Executive Dashboard
class FirebaseService {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // Getters for Firebase instances
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseDatabase get database => _database;
  
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();
  
  // Factory constructor
  factory FirebaseService() => _instance;
  
  // Private constructor
  FirebaseService._internal();
  
  // Analytics Collection Reference
  CollectionReference get analyticsCollection => 
      _firestore.collection('analytics');
  
  // Email Collection Reference
  CollectionReference get emailCollection => 
      _firestore.collection('emails');
  
  // Blog Collection Reference
  CollectionReference get blogCollection => 
      _firestore.collection('blog');
  
  // SEO Collection Reference
  CollectionReference get seoCollection => 
      _firestore.collection('seo');
  
  // Settings Collection Reference
  CollectionReference get settingsCollection => 
      _firestore.collection('settings');
  
  // User Collection Reference
  CollectionReference get userCollection => 
      _firestore.collection('users');
      
  // Realtime Database References
  DatabaseReference get chatReference => 
      _database.ref('chat');
  
  DatabaseReference get notificationsReference => 
      _database.ref('notifications');
  
  // Call a Cloud Function
  Future<HttpsCallableResult<dynamic>> callFunction(
    String functionName, 
    Map<String, dynamic> parameters
  ) async {
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable(functionName);
    return await callable.call(parameters);
  }
  Future<DocumentSnapshot> getDocument(
    CollectionReference collection, 
    String documentId
  ) async {
    return await collection.doc(documentId).get();
  }
  
  // Add a document
  Future<DocumentReference> addDocument(
    CollectionReference collection, 
    Map<String, dynamic> data
  ) async {
    return await collection.add(data);
  }
  
  // Update a document
  Future<void> updateDocument(
    CollectionReference collection, 
    String documentId, 
    Map<String, dynamic> data
  ) async {
    await collection.doc(documentId).update(data);
  }
  
  // Delete a document
  Future<void> deleteDocument(
    CollectionReference collection, 
    String documentId
  ) async {
    await collection.doc(documentId).delete();
  }
  
  // Get collection
  Stream<QuerySnapshot> getCollectionStream(CollectionReference collection) {
    return collection.snapshots();
  }
  
  // Listen to Realtime Database Path
  Stream<DatabaseEvent> listenToRealtimeDatabase(DatabaseReference reference) {
    return reference.onValue;
  }
} 