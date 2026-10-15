import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole { customer, admin }

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = UserRole.customer,
    this.demoOwner = false,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;

  /// Lets a regular user try the salon-owner screens on their own bookings.
  final bool demoOwner;

  bool get isAdmin => role == UserRole.admin;
  bool get seesOwnerTools => isAdmin || demoOwner;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return AppUser(
      uid: doc.id,
      name: d['name'] as String? ?? '',
      email: d['email'] as String? ?? '',
      phone: d['phone'] as String? ?? '',
      role: d['role'] == 'admin' ? UserRole.admin : UserRole.customer,
      demoOwner: d['demoOwner'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, phone, role, demoOwner];
}

class Service extends Equatable {
  const Service({
    required this.id,
    required this.category,
    required this.nameEn,
    required this.nameTr,
    required this.durationMin,
    required this.price,
    required this.icon,
  });

  final String id;
  final String category;
  final String nameEn;
  final String nameTr;
  final int durationMin;

  /// Turkish lira.
  final int price;
  final String icon;

  String name(String lang) => lang == 'tr' ? nameTr : nameEn;

  factory Service.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Service(
      id: doc.id,
      category: d['category'] as String,
      nameEn: d['nameEn'] as String,
      nameTr: d['nameTr'] as String,
      durationMin: (d['durationMin'] as num).toInt(),
      price: (d['price'] as num).toInt(),
      icon: d['icon'] as String? ?? 'spa',
    );
  }

  @override
  List<Object?> get props => [id];
}

class Staff extends Equatable {
  const Staff({
    required this.id,
    required this.name,
    required this.roleEn,
    required this.roleTr,
    required this.rating,
    required this.colorIndex,
    required this.services,
  });

  final String id;
  final String name;
  final String roleEn;
  final String roleTr;
  final double rating;
  final int colorIndex;
  final List<String> services;

  String role(String lang) => lang == 'tr' ? roleTr : roleEn;
  bool offers(Service s) => services.contains(s.id);

  String get initials {
    final parts = name.split(' ');
    return (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
  }

  factory Staff.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Staff(
      id: doc.id,
      name: d['name'] as String,
      roleEn: d['roleEn'] as String,
      roleTr: d['roleTr'] as String,
      rating: (d['rating'] as num).toDouble(),
      colorIndex: (d['colorIndex'] as num?)?.toInt() ?? 0,
      services: (d['services'] as List).cast<String>(),
    );
  }

  @override
  List<Object?> get props => [id];
}

enum AppointmentStatus { pending, confirmed, declined, cancelled, completed }

class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.uid,
    required this.customerName,
    required this.serviceId,
    required this.serviceNameEn,
    required this.serviceNameTr,
    required this.staffId,
    required this.staffName,
    required this.start,
    required this.durationMin,
    required this.price,
    required this.status,
    this.note = '',
    this.slotIds = const [],
  });

  final String id;
  final String uid;
  final String customerName;
  final String serviceId;
  final String serviceNameEn;
  final String serviceNameTr;
  final String staffId;
  final String staffName;
  final DateTime start;
  final int durationMin;
  final int price;
  final AppointmentStatus status;
  final String note;
  final List<String> slotIds;

  DateTime get end => start.add(Duration(minutes: durationMin));
  String serviceName(String lang) => lang == 'tr' ? serviceNameTr : serviceNameEn;

  bool isUpcoming(DateTime now) =>
      end.isAfter(now) && (status == AppointmentStatus.pending || status == AppointmentStatus.confirmed);

  /// Customers may cancel until two hours before the start.
  bool canCancel(DateTime now) => isUpcoming(now) && start.difference(now) > const Duration(hours: 2);

  factory Appointment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Appointment(
      id: doc.id,
      uid: d['uid'] as String,
      customerName: d['customerName'] as String? ?? '',
      serviceId: d['serviceId'] as String,
      serviceNameEn: d['serviceNameEn'] as String? ?? '',
      serviceNameTr: d['serviceNameTr'] as String? ?? '',
      staffId: d['staffId'] as String,
      staffName: d['staffName'] as String? ?? '',
      start: (d['start'] as Timestamp).toDate(),
      durationMin: (d['durationMin'] as num).toInt(),
      price: (d['price'] as num).toInt(),
      status: AppointmentStatus.values.asNameMap()[d['status']] ?? AppointmentStatus.pending,
      note: d['note'] as String? ?? '',
      slotIds: (d['slotIds'] as List?)?.cast<String>() ?? const [],
    );
  }

  @override
  List<Object?> get props => [id, status, start, staffId];
}
