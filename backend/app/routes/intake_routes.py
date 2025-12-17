"""
intake_routes.py

프론트(체크리스트/주간뷰/월간캘린더)에서 바로 쓰도록
"user_id + elder_id + date(YYYY-MM-DD)" 기준으로 날짜 기반 데이터를 반환한다.

Endpoints
- GET  /api/intake/today?user_id=U&elder_id=E
- GET  /api/intake/week/schedule?user_id=U&elder_id=E
- GET  /api/intake/calendar/month?user_id=U&elder_id=E&year=2025&month=12
- GET  /api/intake/summary?user_id=U&elder_id=E&range=day|week|month
- POST /api/intake/{log_id}/take
- POST /api/intake/{log_id}/skip?reason=...
"""

from fastapi import APIRouter, HTTPException
from datetime import datetime, timedelta, timezone, date
from google.cloud import firestore
import os

router = APIRouter(prefix="/api/intake", tags=["Intake"])

FIREBASE_ADMIN_KEY = os.getenv("FIREBASE_ADMIN_KEY")
if not FIREBASE_ADMIN_KEY:
    raise RuntimeError("FIREBASE_ADMIN_KEY env var is missing. Set it to your service account json path.")

db = firestore.Client.from_service_account_json(FIREBASE_ADMIN_KEY)

SLOTS = ("morning", "noon", "evening")


# -----------------------------
# helpers
# -----------------------------
def _iso(d: date) -> str:
    return d.isoformat()

def _coerce_status(raw) -> str:
    """
    과거 호환:
    - status가 False/True로 저장돼 있으면 pending/taken으로 해석
    - 문자열이면 그대로 사용
    """
    if isinstance(raw, bool):
        return "taken" if raw else "pending"
    if raw in ("pending", "taken", "skipped"):
        return raw
    # 예상 밖 값이면 pending 처리
    return "pending"

def _map_log(doc) -> dict:
    data = doc.to_dict()
    return {
        "log_id": doc.id,
        "medicine_id": data.get("medicine_id"),
        "schedule_id": data.get("schedule_id"),
        "planned_time": data.get("planned_time"),
        "slot": data.get("slot"),
        "status": _coerce_status(data.get("status")),
        "taken_time": data.get("taken_time"),
        "skipped_reason": data.get("skipped_reason"),
    }

def _query_logs_by_date_range(user_id: str, elder_id: str, start_date: str, end_date: str):
    """
    target_date가 YYYY-MM-DD 문자열이면 문자열 range 비교가 날짜 range랑 동일하게 동작함.
    """
    return (
        db.collection("intake_logs")
        .where("user_id", "==", user_id)
        .where("elder_id", "==", elder_id)
        .where("target_date", ">=", start_date)
        .where("target_date", "<=", end_date)
        .stream()
    )


# --------------------------------------------------
# ① 오늘 복약 (체크리스트/카드용)
# --------------------------------------------------
@router.get("/today")
def today_intake(user_id: str, elder_id: str):
    today_str = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    docs = _query_logs_by_date_range(user_id, elder_id, today_str, today_str)

    result = {"date": today_str, "morning": [], "noon": [], "evening": []}
    for doc in docs:
        item = _map_log(doc)
        slot = item.get("slot")
        if slot in result:
            result[slot].append(item)

    # 시간순 정렬(같은 slot 안에서)
    for s in SLOTS:
        result[s].sort(key=lambda x: (x.get("planned_time") or ""))
    return result


# --------------------------------------------------
# ③ 월간 캘린더 (달력 grid 전용)
# --------------------------------------------------
@router.get("/calendar/month")
def month_calendar(user_id: str, elder_id: str, year: int, month: int):
    # month 범위 체크
    if month < 1 or month > 12:
        raise HTTPException(status_code=400, detail="month must be 1~12")

    start = date(year, month, 1)
    # 다음달 1일 구하기
    if month == 12:
        next_month = date(year + 1, 1, 1)
    else:
        next_month = date(year, month + 1, 1)
    end = next_month - timedelta(days=1)

    start_str = _iso(start)
    end_str = _iso(end)

    # calendar 그리드용: 월의 모든 날짜 키를 미리 깔아둠
    calendar = {}
    cur = start
    while cur <= end:
        calendar[_iso(cur)] = {"morning": [], "noon": [], "evening": []}
        cur += timedelta(days=1)

    docs = _query_logs_by_date_range(user_id, elder_id, start_str, end_str)
    for doc in docs:
        item = _map_log(doc)
        d = doc.to_dict().get("target_date")
        slot = item.get("slot")
        if d in calendar and slot in calendar[d]:
            calendar[d][slot].append(item)

    # 정렬
    for d in calendar:
        for s in SLOTS:
            calendar[d][s].sort(key=lambda x: (x.get("planned_time") or ""))

    return {"year": year, "month": month, "calendar": calendar}


# --------------------------------------------------
# ② 이번 주 스케줄 (주간 뷰 / 카드 리스트)
# --------------------------------------------------
@router.get("/week/schedule")
def week_schedule(user_id: str, elder_id: str):
    today = datetime.now(timezone.utc).date()
    end = today + timedelta(days=6)

    start_str = _iso(today)
    end_str = _iso(end)

    schedule = {}
    # 주간도 날짜 키 미리 생성(프론트 안정)
    cur = today
    while cur <= end:
        schedule[_iso(cur)] = {"morning": [], "noon": [], "evening": []}
        cur += timedelta(days=1)

    docs = _query_logs_by_date_range(user_id, elder_id, start_str, end_str)
    for doc in docs:
        item = _map_log(doc)
        d = doc.to_dict().get("target_date")
        slot = item.get("slot")
        if d in schedule and slot in schedule[d]:
            schedule[d][slot].append(item)

    for d in schedule:
        for s in SLOTS:
            schedule[d][s].sort(key=lambda x: (x.get("planned_time") or ""))

    return {
        "range": "week",
        "start_date": start_str,
        "end_date": end_str,
        "schedule": schedule,
    }


# --------------------------------------------------
# ④ 요약 통계 (day / week / month)
# --------------------------------------------------
@router.get("/summary")
def intake_summary(user_id: str, elder_id: str, range: str):
    today = datetime.now(timezone.utc).date()

    if range == "day":
        start = today
    elif range == "week":
        start = today - timedelta(days=6)
    elif range == "month":
        start = today - timedelta(days=29)
    else:
        raise HTTPException(status_code=400, detail="range must be one of: day, week, month")

    start_str = _iso(start)
    end_str = _iso(today)

    docs = _query_logs_by_date_range(user_id, elder_id, start_str, end_str)

    total = 0
    taken = 0

    for doc in docs:
        data = doc.to_dict()
        total += 1
        status = _coerce_status(data.get("status"))
        if status == "taken":
            taken += 1

    return {
        "range": range,
        "start_date": start_str,
        "end_date": end_str,
        "total": total,
        "taken": taken,
        "missed": total - taken,  # taken이 아니면 전부 미복용(스킵 포함)
        "rate": round((taken / total) * 100, 1) if total else 0,
    }


# --------------------------------------------------
# ⑤ 복약 액션: 먹었어요
# --------------------------------------------------
@router.post("/{log_id}/take")
def mark_taken(log_id: str):
    ref = db.collection("intake_logs").document(log_id)
    snap = ref.get()
    if not snap.exists:
        raise HTTPException(status_code=404, detail="log not found")

    ref.update({
        "status": "taken",
        "taken_time": datetime.now(timezone.utc),
        "skipped_reason": None,
    })
    return {"success": True, "status": "taken"}


# --------------------------------------------------
# ⑥ 복약 액션: 스킵했어요
# --------------------------------------------------
@router.post("/{log_id}/skip")
def mark_skipped(log_id: str, reason: str = "컨디션 불량"):
    ref = db.collection("intake_logs").document(log_id)
    snap = ref.get()
    if not snap.exists:
        raise HTTPException(status_code=404, detail="log not found")

    ref.update({
        "status": "skipped",
        "taken_time": None,
        "skipped_reason": reason,
    })
    return {"success": True, "status": "skipped", "skipped_reason": reason}
