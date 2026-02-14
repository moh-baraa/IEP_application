import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iep_app/mvc/models/user_model.dart';
import 'package:iep_app/mvc/repositories/auth_repository.dart';

class UserProvider extends ChangeNotifier {
  // === single object from the class to use ===
  static UserProvider? _instance;

  // === to rich the object from anywhere in the project ===
  static UserProvider get instance {
    if (_instance == null) {
      throw Exception("UserProvider not initialized yet!");
    }
    return _instance!;
  }

  final AuthRepository _repository = AuthRepository();

  User? _user; // firebase user
  UserModel? _currentUser; // the user model(with all the data)
  bool _isAuthLoading = true;
  int _recentTransactionsCount = 0;
  int _activeProjectsCount = 0;
  double _totalInvestedAmount = 0.0; // الاستثمار يكون double للمبالغ المالية

  UserProvider() {
    // === in intilazing, the information of this user will be avaliable in the instance ===
    _instance = this;
    _monitorAuthState();
  }

  // ================= Getters =================
  String? get currentUserId => _user?.uid;
  User? get user => _user;
  UserModel? get currentUser => _currentUser;
  bool get isAuthLoading => _isAuthLoading;
  bool get isBlocked => _currentUser?.isblocked ?? false;
  String get firstName => _currentUser?.firstName ?? '';
  String get lastName => _currentUser?.lastName ?? '';
  String get email => _currentUser?.email ?? '';
  String get phone => _currentUser?.mobile ?? '';
  String? get avatarUrl => _currentUser?.avatarUrl;
  // === help to composite the name ===
  String get fullName => "$firstName $lastName".trim();

  // === check the permissions ===
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isMunicipality => _currentUser?.role == UserRole.municipality;

  String get transactionsCount => _recentTransactionsCount.toString();
  String get activeProjectsCount => _activeProjectsCount.toString();
  // === show without floating numbers ===
  String get investmentsCount =>
      "${_totalInvestedAmount.toStringAsFixed(0)} JD";

  bool get isEmailVerified => _user?.emailVerified ?? false;

  // ================= Logic =================
  // === monitor user login ===
  void _monitorAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _user = user;

      if (user != null) {
        await _fetchUserData(user.uid);
        // === get the ststistics when user login ===
        fetchUserStatistics();
      } else {
        _clearData();
      }
      _isAuthLoading = false;
      notifyListeners();
    });
  }

  // === get the data from the server ===
  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _repository.getUserData(uid);

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        // === create object ===
        _currentUser = UserModel.fromMap(data, uid);

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // === to calc the statistics from the firestroe ===
  Future<void> fetchUserStatistics() async {
    if (_user == null) return;
    String uid = _user!.uid;

    try {
      final firestore = FirebaseFirestore.instance;

      // === number of active projects ===
      AggregateQuerySnapshot projectsSnapshot = await firestore
          .collection('projects')
          .where('owner_id', isEqualTo: uid)
          .where('isApproved', isEqualTo: true)
          .where('isFrozen', isEqualTo: false)
          .where('isSatisfiesTarget', isEqualTo: false)
          .count()
          .get();

      _activeProjectsCount = projectsSnapshot.count ?? 0;

      // === calc the investments & recent transactions ===
      QuerySnapshot transactionsSnapshot = await firestore
          .collection('transactions')
          .where('userId', isEqualTo: uid)
          .get();

      double totalAmount = 0.0;
      int recentCount = 0;

      // === recent will be until 30 days ===
      DateTime thirtyDaysAgo = DateTime.now().subtract(
        const Duration(days: 30),
      );

      for (var doc in transactionsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // === total ===
        totalAmount += (data['amount'] ?? 0).toDouble();

        // === check the date ===
        if (data['timestamp'] != null) {
          DateTime txDate;
          if (data['timestamp'] is Timestamp) {
            txDate = (data['timestamp'] as Timestamp).toDate();
          } else {
            txDate =
                DateTime.tryParse(data['timestamp'].toString()) ??
                DateTime.now();
          }

          if (txDate.isAfter(thirtyDaysAgo)) {
            recentCount++;
          }
        }
      }

      _totalInvestedAmount = totalAmount;
      _recentTransactionsCount = recentCount;

      notifyListeners(); // update the secreen
    } catch (e) {
      debugPrint("Error fetching stats: $e");
    }
  }

  // === for update the data manual ===
  Future<void> refreshStats() async {
    await fetchUserStatistics();
  }

  // === clean the data afted sign out ===
  void _clearData() {
    _currentUser = null;
    _recentTransactionsCount = 0;
    _activeProjectsCount = 0;
    _totalInvestedAmount = 0.0;
  }

  // === updating the data locally ===
  Future<void> reloadUserData() async {
    if (_user != null) {
      await _fetchUserData(_user!.uid);
      notifyListeners();
    }
  }

  // === update the user information without waiting the server ===
  void updateLocalData({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? avatarUrl,
  }) {
    if (_currentUser == null) return;

    Map<String, dynamic> userDataMap = _currentUser!.toMap();

    if (firstName != null) userDataMap['first_name'] = firstName;
    if (lastName != null) userDataMap['last_name'] = lastName;
    if (phone != null) userDataMap['mobile_num'] = phone;
    if (email != null) userDataMap['email'] = email;
    if (avatarUrl != null) userDataMap['avatar_url'] = avatarUrl;

    _currentUser = UserModel.fromMap(userDataMap, _currentUser!.id);

    notifyListeners();
  }

  void updateStats({int? transactions, int? projects, double? investments}) {
    if (transactions != null) _recentTransactionsCount = transactions;
    if (projects != null) _activeProjectsCount = projects;
    if (investments != null) _totalInvestedAmount = investments;
    notifyListeners();
  }
}
