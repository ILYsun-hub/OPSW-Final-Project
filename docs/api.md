#  Backend API Specification

본 문서는 **보호자(user) – 피보호자(elder) – 날짜(date)** 를 기준으로  
복약 관리 앱에서 사용하는 백엔드 API 명세를 정의한다.

---

##  공통 개념 (Core Scope)

모든 복약 데이터는 아래 3가지 스코프로 관리된다.

| 필드 | 설명 |
|---|---|
| `user_id` | 보호자(간병인) |
| `elder_id` | 피보호자(노인) |
| `date` | YYYY-MM-DD |

한 명의 보호자가 여러 명의 노인을 날짜별로 관리하는 구조

---

##  Elders API (피보호자 관리)

### 노인 생성

**POST** `/api/elders`

#### Request
```http
POST /api/elders?user_id=U&name=김영자&birth=1945-03-02&gender=F
```
#### Response
```http
{
  "elder_id": "elder_001"
}
```

### 시니어 목록 조회
**GET** `/api/elders`

#### Request
```http
GET /api/elders?user_id=U
```
#### Response
```json
{
  "elders": [
    {
      "elder_id": "elder_001",
      "name": "김영자",
      "birth": "1945-03-02",
      "gender": "F"
    }
  ]
}
```
## OCR / 처방 인식 API
### OCR 텍스트 추출
**POST** `/api/ocr/upload`

- Content-Type: multipart/form-data
- key: file

#### Response
```json
{
  "success": true,
  "data": {
    "raw_text": "...",
    "parsed": {
      "drugs": []
    }
  }
}
```
### OCR + AI 분석
**POST** `/api/ocr/upload/ai`

#### Response
```json
{
  "success": true,
  "raw_text": "...",
  "ai_parsed": {
    "drugs": [
      {
        "drug_name": "아모잘탄",
        "dose": "1정",
        "times_per_day": "하루 1회",
        "days": "30일"
      }
    ]
  }
}
```
### OCR + AI + Firestore 저장 (스케줄 자동 생성)
**POST** `/api/ocr/upload/ai/save`

#### Request
```
POST /api/ocr/upload/ai/save?elder_id=elder_001
```
#### Response
```json

{
  "success": true,
  "message": "OCR + AI + 복약 스케줄 생성 완료",
  "elder_id": "elder_001",
  "scan_id": "scan_xxx",
  "prescription_id": "pres_xxx",
  "medicine_ids": ["m1", "m2"],
  "schedule_ids": ["s1", "s2"]
}
```

## schedules

### intake_logs (날짜/시간 단위)

### 오늘 복약 (체크리스트 / 카드용)
**GET** `/api/intake/today`

#### Request
```
GET /api/intake/today?user_id=U&elder_id=E
```
#### Response
```json
{
  "date": "2025-12-18",
  "morning": [
    {
      "log_id": "log_xxx",
      "medicine_id": "m1",
      "planned_time": "09:00",
      "slot": "morning",
      "status": "pending"
    }
  ],
  "noon": [],
  "evening": []
}
```
### 이번 주 스케줄 (주간 뷰)
**GET** `/api/intake/week/schedule`

#### Response
```json
{
  "range": "week",
  "start_date": "2025-12-18",
  "end_date": "2025-12-24",
  "schedule": {
    "2025-12-18": {
      "morning": [],
      "noon": [],
      "evening": []
    }
  }
}
```
프론트에서 요일 카드 / 주간 복약률 계산 가능

### 월간 캘린더 (Calendar Grid 전용)
**GET** `/api/intake/calendar/month`

#### Request
```GET /api/intake/calendar/month?user_id=U&elder_id=E&year=2025&month=12```

#### Response
```json
{
  "year": 2025,
  "month": 12,
  "calendar": {
    "2025-12-01": {
      "morning": [],
      "noon": [],
      "evening": []
    }
  }
}
```
-> 날짜 셀 하나 = calendar[YYYY-MM-DD]

### 복약 요약 통계 (그래프용)
**GET** `/api/intake/summary`

#### Request
```
GET /api/intake/summary?user_id=U&elder_id=E&range=week
```
#### Response
```
json
{
  "range": "week",
  "start_date": "2025-12-12",
  "end_date": "2025-12-18",
  "total": 21,
  "taken": 15,
  "missed": 6,
  "rate": 71.4
}
```

## 복약 액션 API
### 먹었어요
**POST** `/api/intake/{log_id}/take`

```json
{
  "success": true,
  "status": "taken"
}
```
### 스킵했어요
**POST** `/api/intake/{log_id}/skip?reason=컨디션불량`

```json
{
  "success": true,
  "status": "skipped",
  "skipped_reason": "컨디션불량"
}
```