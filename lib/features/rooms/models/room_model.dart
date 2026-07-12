import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';

enum RoomStatus { kosong, terisi, booking, perbaikan }

extension RoomStatusX on RoomStatus {
  String get label {
    switch (this) {
      case RoomStatus.kosong:
        return 'Kosong';
      case RoomStatus.terisi:
        return 'Terisi';
      case RoomStatus.booking:
        return 'Booking';
      case RoomStatus.perbaikan:
        return 'Perbaikan';
    }
  }

  Color get color {
    switch (this) {
      case RoomStatus.kosong:
        return AppColors.roomEmpty;
      case RoomStatus.terisi:
        return AppColors.roomFilled;
      case RoomStatus.booking:
        return AppColors.roomBooked;
      case RoomStatus.perbaikan:
        return AppColors.roomRepair;
    }
  }

  static RoomStatus fromString(String value) {
    return RoomStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RoomStatus.kosong,
    );
  }
}

class RoomModel {
  final String id;
  final String number;
  final RoomStatus status;
  final int price;
  final String? tenantName;
  final String? tenantUid;
  final DateTime? contractStart;
  final DateTime? contractEnd;

  const RoomModel({
    required this.id,
    required this.number,
    required this.status,
    required this.price,
    this.tenantName,
    this.tenantUid,
    this.contractStart,
    this.contractEnd,
  });

  int? get daysUntilContractEnd {
    if (contractEnd == null) return null;
    return contractEnd!.difference(DateTime.now()).inDays;
  }

  factory RoomModel.fromMap(String id, Map<String, dynamic> map) {
    return RoomModel(
      id: id,
      number: map['number'] ?? '-',
      status: RoomStatusX.fromString(map['status'] ?? 'kosong'),
      price: map['price'] ?? 0,
      tenantName: map['tenantName'],
      tenantUid: map['tenantUid'],
      contractStart: (map['contractStart'] as Timestamp?)?.toDate(),
      contractEnd: (map['contractEnd'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'status': status.name,
      'price': price,
      'tenantName': tenantName,
      'tenantUid': tenantUid,
      'contractStart': contractStart != null ? Timestamp.fromDate(contractStart!) : null,
      'contractEnd': contractEnd != null ? Timestamp.fromDate(contractEnd!) : null,
    };
  }
}