import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

/// Centralized Firebase service for the Cannasol Executive Dashboard
class FirebaseService {
  // Firebase instances
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;
  late final FirebaseDatabase _database;
  late final FirebaseFunctions _functions;
  
  // Getters for Firebase instances
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseDatabase get database => _database;
  
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();
  
  // Factory constructor
  factory FirebaseService() => _instance;
  
  // Private constructor
  FirebaseService._internal() {
    try {
      // Try to get our named Firebase app
      final app = Firebase.app('cannasolDashboard');
      print('FirebaseService using named app: ${app.name}');
      
      // Initialize all services with the named app
      _firestore = FirebaseFirestore.instanceFor(app: app);
      _auth = FirebaseAuth.instanceFor(app: app);
      _database = FirebaseDatabase.instanceFor(app: app);
      _functions = FirebaseFunctions.instanceFor(app: app);
    } catch (e) {
      // Fallback to default instances if named app isn't available
      print('Named Firebase app not found, using default: $e');
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _database = FirebaseDatabase.instance;
      _functions = FirebaseFunctions.instance;
    }
  }
  
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
    final callable = _functions.httpsCallable(functionName);
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