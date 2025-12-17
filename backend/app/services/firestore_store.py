from google.cloud import firestore
from datetime import datetime, timedelta, timezone
import os
import uuid
import re

db = firestore.Client.from_service_account_json(
    os.getenv("FIREBASE_ADMIN_KEY")
)

# ---------------------------
# 공통 유틸: 숫자 추출
# ---------------------------
def extract_int(value, default=1):
    """
    문자열에서 숫자만 추출하여 int로 반환
    예: '21일' -> 21, '하루 3회' -> 3
    """
    if isinstance(value, int):
        return value

    if not isinstance(value, str):
        return default

    nums = re.findall(r"\d+", value)
    return int(nums[0]) if nums else default


# ---------------------------
# 1. OCR 원본 저장
# ---------------------------
def save_scan(user_id: str, elder_id: str, raw_text: str, ai_parsed: dict):
    ref = db.collection("prescription_scans").document()
    ref.set({
        "user_id": user_id,
        "elder_id": elder_id,
        "raw_ocr_text": raw_text,
        "parsed": True,
        "created_at": datetime.now(timezone.utc),
    })
    return ref.id


# ---------------------------
# 2. 약 리스트 저장 (ID만 생성)
# ---------------------------
def save_medicines(user_id: str, scan_id: str, medications: list):
    return [str(uuid.uuid4()) for _ in medications]


# ---------------------------
# 3. 처방전 저장
# ---------------------------
def save_prescription(user_id: str, elder_id: str, scan_id: str, medicines: list):
    prescription_id = str(uuid.uuid4())

    db.collection("prescriptions").document(prescription_id).set({
        "user_id": user_id,
        "elder_id": elder_id,
        "scan_id": scan_id,
        "medicine_ids": medicines,
        "created_at": datetime.now(timezone.utc),
    })

    return prescription_id


# ---------------------------
# 4. 복용 스케줄 저장
# ---------------------------
def save_schedules(user_id: str, elder_id: str, medicine_ids: list, medications: list):
    schedule_ids = []

    for idx, med in enumerate(medications):
        med_id = medicine_ids[idx]

        times_per_day = extract_int(med.get("times_per_day", 1))
        days = extract_int(med.get("days", 1))

        if times_per_day == 1:
            times = ["09:00"]
        elif times_per_day == 2:
            times = ["09:00", "18:00"]
        elif times_per_day == 3:
            times = ["09:00", "13:00", "18:00"]
        else:
            times = ["09:00"]

        start_date = datetime.now(timezone.utc)
        end_date = start_date + timedelta(days=days)
        schedule_id = str(uuid.uuid4())

        drug_name = med.get("drug_name")
        dose = med.get("dose")

        db.collection("schedules").document(schedule_id).set({
            "user_id": user_id,
            "elder_id": elder_id,
            "medicine_id": med_id,
            "drug_name": drug_name,
            "dose": dose,
            "times_per_day": times_per_day,
            "days": days,
            "times": times,
            "start_date": start_date,
            "end_date": end_date,
            "created_at": datetime.now(timezone.utc),
        })

        create_intake_logs_for_schedule(
            user_id=user_id,
            elder_id=elder_id,
            schedule_id=schedule_id,
            medicine_id=med_id,
            medicine_name=drug_name,
            dose=dose,
            start_date=start_date,
            days=days,
            times=times,
        )

        schedule_ids.append(schedule_id)

    return schedule_ids


# ---------------------------
# 5. intake_logs 생성 
# ---------------------------
def create_intake_logs_for_schedule(
    user_id: str,
    elder_id: str,
    schedule_id: str,
    medicine_id: str,
    medicine_name: str,
    dose: str,
    start_date,
    days: int,
    times: list,
):
    slot_map = {
        "09:00": "morning",
        "13:00": "noon",
        "18:00": "evening",
    }

    for day_offset in range(days):
        target_date = (start_date + timedelta(days=day_offset)).strftime("%Y-%m-%d")

        for time in times:
            db.collection("intake_logs").add({
                "user_id": user_id,
                "elder_id": elder_id,
                "schedule_id": schedule_id,

                "medicine_id": medicine_id,      # 내부용
                "medicine_name": medicine_name,  # 사람용
                "dose": dose,

                # 시간 정보
                "target_date": target_date,
                "planned_time": time,
                "slot": slot_map.get(time, "morning"),

                # 상태
                "status": "pending",              # pending | taken | skipped
                "taken_time": None,
                "skipped_reason": None,

                "created_at": datetime.now(timezone.utc),
            })


# ---------------------------
# 6. 복약 완료 처리
# ---------------------------
def mark_intake_taken(log_id: str):
    db.collection("intake_logs").document(log_id).update({
        "status": "taken",
        "taken_time": datetime.now(timezone.utc),
        "skipped_reason": None,
    })
