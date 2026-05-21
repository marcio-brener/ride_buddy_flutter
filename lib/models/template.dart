import 'package:cloud_firestore/cloud_firestore.dart';

enum FormType {
  receita,
  despesa,
  meta,
  jornadaFinal;

  static FormType fromString(String s) {
    return FormType.values.byName(s);
  }
}

class Template {
  final String id;
  final String userId;
  final FormType formType;
  final String name;
  final bool isDefault;
  final int usageCount;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final Map<String, dynamic> payload;

  const Template({
    required this.id,
    required this.userId,
    required this.formType,
    required this.name,
    this.isDefault = false,
    this.usageCount = 0,
    this.lastUsedAt,
    required this.createdAt,
    required this.payload,
  });

  factory Template.fromMap(Map<String, dynamic> map, String id) {
    return Template(
      id: id,
      userId: map['userId'] as String? ?? '',
      formType: FormType.fromString(map['formType'] as String),
      name: map['name'] as String,
      isDefault: map['isDefault'] as bool? ?? false,
      usageCount: map['usageCount'] as int? ?? 0,
      lastUsedAt: map['lastUsedAt'] != null
          ? (map['lastUsedAt'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      payload: Map<String, dynamic>.from(map['payload'] as Map),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'formType': formType.name,
      'name': name,
      'isDefault': isDefault,
      'usageCount': usageCount,
      'lastUsedAt':
          lastUsedAt != null ? Timestamp.fromDate(lastUsedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'payload': payload,
    };
  }

  Template copyWith({
    String? id,
    String? userId,
    FormType? formType,
    String? name,
    bool? isDefault,
    int? usageCount,
    DateTime? lastUsedAt,
    DateTime? createdAt,
    Map<String, dynamic>? payload,
  }) {
    return Template(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      formType: formType ?? this.formType,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      payload: payload ?? this.payload,
    );
  }
}
