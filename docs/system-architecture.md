# OPSW 전체 시스템 아키텍처 정의

## 1. 문서 목적
본 문서는 OPSW 프로젝트의 전체 시스템 아키텍처와
주요 기능 흐름(플로우 차트)을 정의한다.

## 2. 기술 스택 개요
- Frontend: Flutter
- Backend: FastAPI
- Database: Firebase Firestore
- Authentication: Firebase Auth
- OCR: Google Vision API
- AI 분석: Ollama LLM
- Notification: Firebase Cloud Messaging

## 3. 전체 시스템 아키텍처
사용자는 Flutter 앱을 통해 서비스를 이용하며,
모든 요청은 FastAPI 백엔드를 통해 처리된다.

FastAPI는 OCR, AI 분석, 복약 스케줄 생성, 알림 로직을 담당하고,
데이터는 Firestore에 저장된다.

## 4. 데이터 구조 개요
- users
- elders
- guardians
- medicines
- prescriptions
- schedules
- intake_logs
- alert_history

각 컬렉션은 사용자–피보호자–복약 기록 관계를 기준으로 연결된다.

## 5. 주요 기능 플로우

### 5.1 OCR 기반 복약 정보 등록 플로우
1. 사용자가 약봉투 이미지를 업로드
2. Google Vision OCR을 통해 텍스트 추출
3. Ollama LLM으로 약 정보 구조화
4. Firestore에 medicines / prescriptions / schedules 저장

### 5.2 복약 스케줄 및 기록 플로우
1. Flutter 앱에서 복약 스케줄 조회
2. 복약 완료 또는 스킵 처리
3. intake_logs에 기록 저장

### 5.3 알림 및 보호자 연동 플로우
1. 복약 시간이 경과하면 알림 트리거
2. 사용자에게 FCM 알림 발송
3. 필요 시 보호자에게 알림 전파

## 6. 보안 및 권한 관리
- Firestore Rules를 통해 사용자별 데이터 접근 제한
- 보호자–피보호자 관계 기반 권한 분리

## 7. 정리
본 아키텍처는 복약 관리 자동화를 목표로 하며,
확장성과 유지보수를 고려한 구조로 설계되었다.
