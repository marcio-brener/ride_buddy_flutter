import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ride_buddy_flutter/models/template.dart';

class TemplateService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _rawTemplatesRef() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('templates');
  }

  CollectionReference<Template> _templatesRef() {
    return _rawTemplatesRef().withConverter<Template>(
      toFirestore: (t, _) => t.toMap(),
      fromFirestore: (snapshot, _) =>
          Template.fromMap(snapshot.data()!, snapshot.id),
    );
  }

  Future<List<Template>> getTemplates(FormType formType) async {
    if (_auth.currentUser == null) return [];

    final snapshot = await _templatesRef()
        .where('formType', isEqualTo: formType.name)
        .get();

    final templates = snapshot.docs.map((d) => d.data()).toList();

    templates.sort((a, b) {
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      if (b.usageCount != a.usageCount) {
        return b.usageCount.compareTo(a.usageCount);
      }
      final aTime = a.lastUsedAt ?? DateTime(0);
      final bTime = b.lastUsedAt ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    return templates;
  }

  Future<String> saveTemplate(Template t) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final withUser = t.copyWith(userId: user.uid);
    final ref = await _templatesRef().add(withUser);
    return ref.id;
  }

  Future<void> deleteTemplate(String id) {
    return _rawTemplatesRef().doc(id).delete();
  }

  Future<void> setDefault(FormType formType, String? newDefaultId) async {
    if (_auth.currentUser == null) return;

    final batch = _firestore.batch();
    final ref = _rawTemplatesRef();

    final prevDefaults = await ref
        .where('formType', isEqualTo: formType.name)
        .where('isDefault', isEqualTo: true)
        .get();

    for (final doc in prevDefaults.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }

    if (newDefaultId != null) {
      batch.update(ref.doc(newDefaultId), {'isDefault': true});
    }

    await batch.commit();
  }

  Future<void> incrementUsage(String id) async {
    if (_auth.currentUser == null) return;
    await _rawTemplatesRef().doc(id).update({
      'usageCount': FieldValue.increment(1),
      'lastUsedAt': FieldValue.serverTimestamp(),
    });
  }
}
