import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum IssueCategory { listrik, air, ac, furniture, kebersihan, lainnya }

extension IssueCategoryX on IssueCategory {
  String get label {
    switch (this) {
      case IssueCategory.listrik:
        return 'Listrik';
      case IssueCategory.air:
        return 'Air/Saluran';
      case IssueCategory.ac:
        return 'AC/Kipas';
      case IssueCategory.furniture:
        return 'Furnitur';
      case IssueCategory.kebersihan:
        return 'Kebersihan';
      case IssueCategory.lainnya:
        return 'Lainnya';
    }
  }

  IconData get icon {
    switch (this) {
      case IssueCategory.listrik:
        return Icons.bolt_rounded;
      case IssueCategory.air:
        return Icons.water_drop_rounded;
      case IssueCategory.ac:
        return Icons.ac_unit_rounded;
      case IssueCategory.furniture:
        return Icons.chair_rounded;
      case IssueCategory.kebersihan:
        return Icons.cleaning_services_rounded;
      case IssueCategory.lainnya:
        return Icons.more_horiz_rounded;
    }
  }

  static IssueCategory fromString(String value) =>
      IssueCategory.values.firstWhere((e) => e.name == value, orElse: () => IssueCategory.lainnya);
}

enum UrgencyLevel { low, medium, high }

extension UrgencyLevelX on UrgencyLevel {
  String get label {
    switch (this) {
      case UrgencyLevel.low:
        return 'Rendah';
      case UrgencyLevel.medium:
        return 'Sedang';
      case UrgencyLevel.high:
        return 'Tinggi';
    }
  }

  Color get color {
    switch (this) {
      case UrgencyLevel.low:
        return AppColors.roomEmpty;
      case UrgencyLevel.medium:
        return AppColors.roomRepair;
      case UrgencyLevel.high:
        return AppColors.roomFilled;
    }
  }

  static UrgencyLevel fromString(String value) =>
      UrgencyLevel.values.firstWhere((e) => e.name == value, orElse: () => UrgencyLevel.low);
}

enum TicketStatus { open, inProgress, resolved }

extension TicketStatusX on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Menunggu';
      case TicketStatus.inProgress:
        return 'Diproses';
      case TicketStatus.resolved:
        return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.open:
        return AppColors.roomBooked;
      case TicketStatus.inProgress:
        return AppColors.roomRepair;
      case TicketStatus.resolved:
        return AppColors.roomEmpty;
    }
  }

  static TicketStatus fromString(String value) =>
      TicketStatus.values.firstWhere((e) => e.name == value, orElse: () => TicketStatus.open);
}

class TicketModel {
  final String id;
  final String roomId;
  final String roomNumber;
  final String tenantUid;
  final String tenantName;
  final IssueCategory category;
  final UrgencyLevel urgency;
  final String description;
  final TicketStatus status;
  final int? repairCost;
  final DateTime createdAt;

  const TicketModel({
    required this.id,
    required this.roomId,
    required this.roomNumber,
    required this.tenantUid,
    required this.tenantName,
    required this.category,
    required this.urgency,
    required this.description,
    required this.status,
    this.repairCost,
    required this.createdAt,
  });

  factory TicketModel.fromMap(String id, Map<String, dynamic> map) {
    return TicketModel(
      id: id,
      roomId: map['roomId'] ?? '',
      roomNumber: map['roomNumber'] ?? '-',
      tenantUid: map['tenantUid'] ?? '',
      tenantName: map['tenantName'] ?? '-',
      category: IssueCategoryX.fromString(map['category'] ?? 'lainnya'),
      urgency: UrgencyLevelX.fromString(map['urgency'] ?? 'low'),
      description: map['description'] ?? '',
      status: TicketStatusX.fromString(map['status'] ?? 'open'),
      repairCost: map['repairCost'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'roomNumber': roomNumber,
      'tenantUid': tenantUid,
      'tenantName': tenantName,
      'category': category.name,
      'urgency': urgency.name,
      'description': description,
      'status': status.name,
      'repairCost': repairCost,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}