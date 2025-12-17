from datetime import datetime, timezone
from google.cloud import firestore
import os

from app.services.fcm_service import send_guardian_notification


# --------------------------------
# Firestore Client (지연 생성)
# --------------------------------
def get_db():
    key_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    if not key_path:
        raise RuntimeError("GOOGLE_APPLICATION_CREDENTIALS 환경변수가 설정되지 않았습니다.")
    return firestore.Client.from_service_account_json(key_path)


# --------------------------------
# '09:00' → 오늘 날짜 datetime
# --------------------------------
def _time_to_today_datetime(time_str: str):
    hour, minute = map(int, time_str.split(":"))
    now = datetime.now(timezone.utc)
    return now.replace(hour=hour, minute=minute, second=0, microsecond=0)


# --------------------------------
# 복약 기록 여부 확인
# --------------------------------
def has_intake(schedule_id: str, target_time: datetime):
    db = get_db()
    logs = (
        db.collection("intake_logs")
        .where("schedule_id", "==", schedule_id)
        .where("intake_time", ">=", target_time)
        .where("intake_time", "<", target_time.replace(minute=59))
        .limit(1)
        .stream()
    )
    return any(True for _ in logs)


# --------------------------------
# 알림 발송 여부 확인 (중복 방지)
# --------------------------------
def has_alert(schedule_id: str, target_time: datetime):
    db = get_db()
    alerts = (
        db.collection("alert_history")
        .where("schedule_id", "==", schedule_id)
        .where("alert_time", "==", target_time)
        .limit(1)
        .stream()
    )
    return any(True for _ in alerts)


# --------------------------------
# 🔥 복약 누락 감지 + 보호자 알림
# --------------------------------
def process_missed_doses():
    db = get_db()
    now = datetime.now(timezone.utc)

    schedules = db.collection("schedules").stream()

    for schedule in schedules:
        data = schedule.to_dict()
        schedule_id = schedule.id

        # 복용 기간 벗어나면 패스
        if not (data["start_date"] <= now <= data["end_date"]):
            continue

        for time_str in data.get("times", []):
            scheduled_dt = _time_to_today_datetime(time_str)

            # 아직 시간 안 지남
            if scheduled_dt > now:
                continue

            # 이미 복용함
            if has_intake(schedule_id, scheduled_dt):
                continue

            # 이미 알림 보냄
            if has_alert(schedule_id, scheduled_dt):
                continue

            user_id = data["user_id"]

            # 보호자 조회
            links = (
                db.collection("user_guardians")
                .where("user_id", "==", user_id)
                .stream()
            )

            for link in links:
                guardian_id = link.to_dict().get("guardian_id")
                if not guardian_id:
                    continue

                guardian = db.collection("guardians").document(guardian_id).get()
                if not guardian.exists:
                    continue

                token = guardian.to_dict().get("fcm_token")
                if not token:
                    continue

                # 알림 전송
                send_guardian_notification(
                    token=token,
                    title="복약 알림",
                    body=f"{data.get('drug_name', '약')} 복용 시간이 지났습니다."
                )

            # 알림 기록 저장 (중복 방지)
            db.collection("alert_history").add({
                "schedule_id": schedule_id,
                "alert_time": scheduled_dt,
                "created_at": now
            })
