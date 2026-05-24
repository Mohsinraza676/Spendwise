import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/transaction_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference transactionCollection =
      FirebaseFirestore.instance.collection('transactions');

  // Add transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      print("Attempting to add transaction for user: $uid");
      await transactionCollection.add(transaction.toFirestore());
      print("Transaction added successfully");
    } catch (e) {
      print("Error adding transaction: $e");
      rethrow;
    }
  }

  // Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    return await transactionCollection
        .doc(transaction.id)
        .update(transaction.toFirestore());
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    return await transactionCollection.doc(id).delete();
  }

  // Get transactions stream
  // Simplified query to avoid requiring a composite index immediately
  Stream<List<TransactionModel>> get transactions {
    print("Listening to transactions for user: $uid");
    return transactionCollection
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      print("Received ${snapshot.docs.length} transactions from Firestore");
      List<TransactionModel> txs = snapshot.docs.map((doc) {
        try {
          return TransactionModel.fromFirestore(doc);
        } catch (e) {
          print("Error parsing transaction doc ${doc.id}: $e");
          return null;
        }
      }).whereType<TransactionModel>().toList();
      
      // Sort in memory to avoid needing a Firestore composite index
      txs.sort((a, b) => b.date.compareTo(a.date));
      return txs;
    }).handleError((error) {
      print("Stream Error: $error");
    });
  }

  // Get user details
  Stream<DocumentSnapshot> get userData {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }
}
