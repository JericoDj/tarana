import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/contact_model.dart';
import '../../data/repositories/contact_repository.dart';

class ContactProvider extends ChangeNotifier {
  final ContactRepository _repository;

  ContactProvider(this._repository);

  List<ContactModel> _contacts = [];
  List<ContactModel> get contacts => _contacts;

  List<ContactModel> get emergencyContacts =>
      _contacts.where((c) => c.isEmergency).toList();

  List<ContactModel> get savedPassengers =>
      _contacts.where((c) => c.isPassenger).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription<List<ContactModel>>? _subscription;

  void watchContacts(String uid) {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription = _repository
        .watchContacts(uid)
        .listen(
          (contactsList) {
            _contacts = contactsList;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = 'Failed to load contacts: $e';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> addContact(String uid, ContactModel contact) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.addContact(uid, contact);
    } catch (e) {
      _error = 'Failed to add contact: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateContact(String uid, ContactModel contact) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateContact(uid, contact);
    } catch (e) {
      _error = 'Failed to update contact: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteContact(String uid, String contactId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteContact(uid, contactId);
    } catch (e) {
      _error = 'Failed to delete contact: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
