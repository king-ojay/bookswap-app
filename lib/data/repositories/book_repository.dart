import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/book_model.dart';

class BookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // CREATE: Add a new book
  Future<void> addBook(BookModel book, File? imageFile) async {
    try {
      String imageUrl = '';

      // Upload image if provided
      if (imageFile != null) {
        final ref = _storage.ref().child('books/${book.id}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final bookWithImage = book.copyWith(imageUrl: imageUrl);
      await _firestore
          .collection('books')
          .doc(book.id)
          .set(bookWithImage.toMap());
    } catch (e) {
      throw Exception('Failed to add book: $e');
    }
  }

  // READ: Get all books
  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // READ: Get books by owner
  Stream<List<BookModel>> getBooksByOwner(String ownerId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // UPDATE: Edit a book
  Future<void> updateBook(BookModel book, File? newImageFile) async {
    try {
      String imageUrl = book.imageUrl;

      // Upload new image if provided
      if (newImageFile != null) {
        final ref = _storage.ref().child('books/${book.id}.jpg');
        await ref.putFile(newImageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final updatedBook = book.copyWith(imageUrl: imageUrl);
      await _firestore
          .collection('books')
          .doc(book.id)
          .update(updatedBook.toMap());
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  // DELETE: Remove a book
  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();

      // Delete image from storage
      try {
        await _storage.ref().child('books/$bookId.jpg').delete();
      } catch (e) {
        // Image might not exist, continue
      }
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  // Update book status (for swaps)
  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    await _firestore.collection('books').doc(bookId).update({
      'status': status.name,
    });
  }
}
