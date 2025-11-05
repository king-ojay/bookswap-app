import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_model.dart';
import '../models/book_model.dart';

class SwapRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a swap offer
  Future<void> createSwap(SwapModel swap) async {
    try {
      // Create swap document
      await _firestore.collection('swaps').doc(swap.id).set(swap.toMap());

      // Update book status to pending
      await _firestore.collection('books').doc(swap.bookId).update({
        'status': BookStatus.pending.name,
      });
    } catch (e) {
      throw Exception('Failed to create swap: $e');
    }
  }

  // Get swaps sent by user
  Stream<List<SwapModel>> getSwapsSent(String userId) {
    return _firestore
        .collection('swaps')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SwapModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Get swaps received by user
  Stream<List<SwapModel>> getSwapsReceived(String userId) {
    return _firestore
        .collection('swaps')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SwapModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Update swap status
  Future<void> updateSwapStatus(
    String swapId,
    String bookId,
    SwapStatus status,
  ) async {
    try {
      // Update swap status
      await _firestore.collection('swaps').doc(swapId).update({
        'status': status.name,
      });

      // Update book status
      BookStatus bookStatus;
      if (status == SwapStatus.accepted) {
        bookStatus = BookStatus.swapped;
      } else if (status == SwapStatus.rejected) {
        bookStatus = BookStatus.available;
      } else {
        bookStatus = BookStatus.pending;
      }

      await _firestore.collection('books').doc(bookId).update({
        'status': bookStatus.name,
      });
    } catch (e) {
      throw Exception('Failed to update swap: $e');
    }
  }

  // Delete swap (cancel offer)
  Future<void> deleteSwap(String swapId, String bookId) async {
    try {
      await _firestore.collection('swaps').doc(swapId).delete();

      // Set book back to available
      await _firestore.collection('books').doc(bookId).update({
        'status': BookStatus.available.name,
      });
    } catch (e) {
      throw Exception('Failed to delete swap: $e');
    }
  }
}
