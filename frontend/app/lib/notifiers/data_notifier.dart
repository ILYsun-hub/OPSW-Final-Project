import 'package:flutter/material.dart';
import '../models/senior.dart';
import '../models/intake_status.dart';
import '../services/api_service.dart';
import 'auth_notifier.dart';

/// 홈 화면의 데이터를 관리하는 ChangeNotifier
class DataNotifier extends ChangeNotifier {
  final ApiService _apiService;
  final AuthNotifier _authNotifier;

  DataNotifier(this._apiService, this._authNotifier) {
    // AuthNotifier의 로그인/로그아웃 상태가 변경될 때마다 데이터 다시 불러오기
    _authNotifier.addListener(_onAuthStateChanged);
    // 초기 인증 상태 확인
    _onAuthStateChanged();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Senior> _seniors = [];
  List<Senior> get seniors => _seniors;

  Map<String, Map<String, IntakeStatus>> _intakeStatus = {};
  Map<String, Map<String, IntakeStatus>> get intakeStatus => _intakeStatus;
  
  // 인증 상태 변경 리스너
  void _onAuthStateChanged() {
    if (_authNotifier.isLoggedIn) {
      fetchData();
    } else {
      // 로그아웃 시 데이터 초기화
      _seniors = [];
      _intakeStatus = {};
      notifyListeners();
    }
  }

  /// 서버로부터 모든 데이터를 가져옴
  Future<void> fetchData() async {
    if (_authNotifier.token == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ApiService를 통해 시니어 목록 가져오기
      _seniors = await _apiService.getSeniors(_authNotifier.token!);
      
      // TODO: 실제로는 복약 현황도 API로 가져와야 함. 지금은 더미 데이터 사용.
      final statusData = {
        's1': {'morning': IntakeStatus.none, 'lunch': IntakeStatus.none, 'dinner': IntakeStatus.none},
        's2': {'morning': IntakeStatus.taken, 'lunch': IntakeStatus.none, 'dinner': IntakeStatus.none},
      };
      _intakeStatus = statusData;

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 복약 상태 업데이트
  Future<void> updateIntakeStatus(String seniorId, Map<String, IntakeStatus> newStatus) async {
    if (_authNotifier.token == null) return;

    // 낙관적 업데이트: UI를 먼저 변경
    _intakeStatus[seniorId] = newStatus;
    notifyListeners();
    
    try {
       // TODO: 실제 API에서는 newStatus의 각 항목에 대해 updateIntakeStatus를 호출해야 할 수 있음.
      await _apiService.updateIntakeStatus(
        token: _authNotifier.token!,
        seniorId: seniorId,
        time: 'morning', // 예시
        status: newStatus['morning'].toString().split('.').last,
      );
    } catch (e) {
      // 실패 시 데이터 원상 복구 (fetchData를 다시 호출하여 서버 데이터와 동기화)
      fetchData();
    }
  }

  // 이 Notifier가 dispose될 때 리스너도 제거
  @override
  void dispose() {
    _authNotifier.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
