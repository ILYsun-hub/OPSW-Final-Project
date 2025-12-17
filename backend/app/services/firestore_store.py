from google.cloud import firestore
from datetime import datetime, timedelta, timezone
import os
import uuid

db = firestore.Client.from_service_account_json(
    os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
)

# ---------------------------
# 1. OCR 원본 저장
# ---------------------------
def save_scan(user_id: str, raw_text: str, ai_parsed: dict):
    scan_ref = db.collection("prescription_scans").document()
    scan_ref.set({
        "user_id": user_id,
        "raw_ocr_text": raw_text,
        "parsed": True,
        "created_at": datetime.now(timezone.utc),
    })
    return scan_ref.id


# ---------------------------
# 2. 약 리스트 저장 (약 ID 만 생성)
# ---------------------------
def save_medicines(user_id: str, scan_id: str, medications: list):
    medicine_ids = [str(uuid.uuid4()) for _ in medications]
    return medicine_ids


# ---------------------------
# 3. 처방전 저장
# ---------------------------
def save_prescription(user_id: str, scan_id: str, medicines: list):
    prescription_id = str(uuid.uuid4())

    doc = {
        "user_id": user_id,
        "scan_id": scan_id,
        "created_at": datetime.utcnow(),
        "medicine_ids": medicines,
    }

    db.collection("prescriptions").document(prescription_id).set(doc)
    return prescription_id


# ---------------------------
# 4. 복용 스케줄 저장
# ---------------------------
def save_schedules(user_id: str, medicine_ids: list, medications: list):
    schedule_ids = []

    for idx, med in enumerate(medications):

        med_id = medicine_ids[idx]

        # === 정규화 ===
        # times_per_day
        tpd = med.get("times_per_day", "1회")
        if isinstance(tpd, str):
            tpd = int(tpd.replace("회", ""))

        # days
        days = med.get("days", "1일")
        if isinstance(days, str):
            days = int(days.replace("일", ""))

        # 복용 시간 자동 생성
        if tpd == 1:
            times = ["09:00"]
        elif tpd == 2:
            times = ["09:00", "18:00"]
        elif tpd == 3:
            times = ["09:00", "13:00", "18:00"]
        else:
            times = ["09:00"]

        # start_date (처방일이 OCR에 있으면 사용)
        start_date = datetime.utcnow()

        schedule_id = str(uuid.uuid4())

        schedule_doc = {
            "user_id": user_id,
            "medicine_id": med_id,
            "drug_name": med.get("drug_name"),
            "dose": med.get("dose"),
            "times_per_day": tpd,
            "days": days,
            "times": times,
            "start_date": start_date,
            "end_date": start_date + timedelta(days=days),
        }

        db.collection("schedules").document(schedule_id).set(schedule_doc)
        schedule_ids.append(schedule_id)

    return schedule_ids
