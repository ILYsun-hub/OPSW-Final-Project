import '../models/senior.dart';
import '../models/report_data.dart';

// 백엔드 서버의 기본 URL. 필요에 따라 변경 가능.
const String _baseUrl = 'http://127.0.0.1:8000';

class ApiService {
  // --- 사용자 인증 ---

  /// 로그인 요청
  Future<String> login(String email, String password) async {
    // 백엔드의 /login 엔드포인트(가정)에 POST 요청
    // 성공 시, 인증 토큰(JWT 등)을 반환한다고 가정
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 흉내
    if (email == 'test@test.com' && password == 'password') {
      return 'fake_auth_token';
    } else {
      throw Exception('로그인 실패');
    }
  }

  /// 회원가입 요청
  Future<void> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    // 백엔드의 /signup 엔드포인트(가정)에 POST 요청
    await Future.delayed(const Duration(seconds: 1));
    print('회원가입 시도: $email, $name');
  }


  // --- 데이터 관리 ---

  /// 시니어 목록 가져오기
  Future<List<Senior>> getSeniors(String token) async {
    // 백엔드의 /seniors 엔드포인트(가정)에 GET 요청
    // 요청 헤더에 인증 토큰을 포함해야 함
    await Future.delayed(const Duration(seconds: 1));
    
    // 실제로는 http.get 결과를 디코딩하여 Senior 리스트로 변환해야 함
    // 지금은 더미 데이터를 반환
    return const [
      Senior(
        id: 's1',
        name: '김철수 (서버)',
        emoji: '🧓',
        age: 79,
        birth: '1946.02.13',
        guardianName: '김민수',
        guardianPhone: '010-1234-5678',
      ),
      Senior(
        id: 's2',
        name: '박영희 (서버)',
        emoji: '👵',
        age: 83,
        birth: '1942.06.01',
        guardianName: '이지은',
        guardianPhone: '010-2222-3333',
      ),
    ];
  }

  /// 복약 상태 업데이트
  Future<void> updateIntakeStatus({
    required String token,
    required String seniorId,
    required String time, // 'morning', 'lunch', 'dinner'
    required String status, // 'taken', 'missed'
  }) async {
    // 백엔드의 /intake_status 엔드포인트(가정)에 POST 또는 PUT 요청
    await Future.delayed(const Duration(milliseconds: 500));
    print('상태 업데이트: $seniorId, $time, $status');
  }

  /// AI 리포트 데이터 가져오기
  Future<ReportData> getReport(String token) async {
    // 백엔드의 /report 엔드포인트(가정)에 GET 요청
    await Future.delayed(const Duration(seconds: 1));

    // 더미 리포트 데이터 반환
    return ReportData(
      weeklyAdherence: 92,
      mostMissedTime: '저녁 식후',
      healthSummary: '혈압 안정적',
      advice: '저녁 약 복용 시간이 불규칙합니다. 알람을 30분 일찍 설정해보는 것을 추천합니다.',
    );
  }
}
