import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum InvoiceStatus { belumBayar, menungguVerifikasi, lunas, ditolak }

extension InvoiceStatusX on InvoiceStatus {
  String get label {
    switch (this) {
      case InvoiceStatus.belumBayar:
        return 'Belum Bayar';
      case InvoiceStatus.menungguVerifikasi:
        return 'Menunggu Verifikasi';
      case InvoiceStatus.lunas:
        return 'Lunas';
      case InvoiceStatus.ditolak:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case InvoiceStatus.belumBayar:
        return AppColors.roomFilled;
      case InvoiceStatus.menungguVerifikasi:
        return AppColors.roomRepair;
      case InvoiceStatus.lunas:
        return AppColors.roomEmpty;
      case InvoiceStatus.ditolak:
        return AppColors.roomFilled;
    }
  }

  static InvoiceStatus fromString(String value) =>
      InvoiceStatus.values.firstWhere((e) => e.name == value, orElse: () => InvoiceStatus.belumBayar);
}

class InvoiceModel {
  final String id;
  final String roomId;
  final String roomNumber;
  final String tenantUid;
  final String tenantName;
  final int amount;
  final DateTime dueDate;
  final InvoiceStatus status;
  final String? proofBase64;
  final DateTime createdAt;
  final DateTime? paidAt;

  const InvoiceModel({
    required this.id,
    required this.roomId,
    required this.roomNumber,
    required this.tenantUid,
    required this.tenantName,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.proofBase64,
    required this.createdAt,
    this.paidAt,
  });

  factory InvoiceModel.fromMap(String id, Map<String, dynamic> map) {
    return InvoiceModel(
      id: id,
      roomId: map['roomId'] ?? '',
      roomNumber: map['roomNumber'] ?? '-',
      tenantUid: map['tenantUid'] ?? '',
      tenantName: map['tenantName'] ?? '-',
      amount: map['amount'] ?? 0,
      dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: InvoiceStatusX.fromString(map['status'] ?? 'belumBayar'),
      proofBase64: map['proofBase64'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidAt: (map['paidAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'roomNumber': roomNumber,
      'tenantUid': tenantUid,
      'tenantName': tenantName,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status.name,
      'proofBase64': proofBase64,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }
}