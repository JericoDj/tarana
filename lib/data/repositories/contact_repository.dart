import '../datasources/remote/firestore_source.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final FirestoreSource _firestoreSource;

  ContactRepository(this._firestoreSource);

  String _contactsPath(String uid) => 'users/$uid/contacts';

  Stream<List<ContactModel>> watchContacts(String uid) {
    return _firestoreSource.firestore
        .collection(_contactsPath(uid))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ContactModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<ContactModel> addContact(String uid, ContactModel contact) async {
    final docRef = await _firestoreSource.addDocument(
      _contactsPath(uid),
      contact.toFirestore(),
    );
    return ContactModel(
      id: docRef.id,
      name: contact.name,
      phone: contact.phone,
      type: contact.type,
      relationship: contact.relationship,
      createdAt: contact.createdAt,
    );
  }

  Future<void> updateContact(String uid, ContactModel contact) async {
    await _firestoreSource.updateDocument(
      _contactsPath(uid),
      contact.id,
      contact.toFirestore(),
    );
  }

  Future<void> deleteContact(String uid, String contactId) async {
    await _firestoreSource.deleteDocument(_contactsPath(uid), contactId);
  }
}
