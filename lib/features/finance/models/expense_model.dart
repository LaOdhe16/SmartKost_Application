import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ExpenseCategory { listrik, air, wifi, gajiStaf, perbaikan, lainnya }

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.listrik:
        return 'Listrik';
      case ExpenseCategory.air:
        return 'Air';
      case ExpenseCategory.wifi:
        return 'WiFi/Internet';
      case ExpenseCategory.gajiStaf:
        return 'Gaji Staf';
      case ExpenseCategory.perbaikan:
        return 'Perbaikan';
      case ExpenseCategory.lainnya:
        return 'Lainnya';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.listrik:
        return Icons.bolt_rounded;
      case ExpenseCategory.air:
        return Icons.water_drop_rounded;
      case ExpenseCategory.wifi:
        return Icons.wifi_rounded;
      case ExpenseCategory.gajiStaf:
        return Icons.badge_rounded;
      case ExpenseCategory.perbaikan:
        return Icons.build_rounded;
      case ExpenseCategory.lainnya:
        return Icons.more_horiz_rounded;
    }
  }

  static ExpenseCategory fromString(String value) =>
      ExpenseCategory.values.firstWhere((e) => e.name == value, orElse: () => ExpenseCategory.lainnya);
}

class ExpenseModel {
  final String id;
  final ExpenseCategory category;
  final String description;
  final int amount;
  final DateTime date;

  const ExpenseModel({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory ExpenseModel.fromMap(String id, Map<String, dynamic> map) {
    return ExpenseModel(
      id: id,
      category: ExpenseCategoryX.fromString(map['category'] ?? 'lainnya'),
      description: map['description'] ?? '',
      amount: map['amount'] ?? 0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category.name,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}