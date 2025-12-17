from google.cloud import firestore
from datetime import datetime, timedelta, timezone

import os
import uuid
import re

db = firestore.Client.from_service_account_json(
    os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
)

# ---------------------------
# 공통 유틸: 숫자 추출
# ---------------------------
def extract_int(value, default=1):
    """
    문자열에서 숫자만 추출하여 int로 반환
    예: '21분' -> 21, '하루 3회' -> 3
    """
    if isinstance(value, int):
        return value

    if not isinstance(value, str):
        return default

    nums = re.findall(r"\d+", value)
    if not nums:
        return default

    return int(nums[0])


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
# 2. 약 리스트 저장 (약 ID 생성)
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
        "created_at": datetime.now(timezone.utc),
        "medicine_ids": medicines,
    }

    db.collection("prescriptions").document(prescription_id).set(doc)
    return prescription_id


# ---------------------------
# 4. 복용 스케줄 저장 (🔥 오류 수정 완료)
# ---------------------------
def save_schedules(user_id: str, medicine_ids: list, medications: list):
    schedule_ids = []

    for idx, med in enumerate(medications):
        med_id = medicine_ids[idx]

        # =========================
        # 안전한 정규화
        # =========================
        times_per_day = extract_int(med.get("times_per_day", 1))
        days = extract_int(med.get("days", 1))

        # -------------------------
        # 복용 시간 자동 생성
        # -------------------------
        if times_per_day == 1:
            times = ["09:00"]
        elif times_per_day == 2:
            times = ["09:00", "18:00"]
        elif times_per_day == 3:
            times = ["09:00", "13:00", "18:00"]
        else:
            times = ["09:00"]

        # -------------------------
        # 날짜 계산
        # -------------------------
        start_date = datetime.now(timezone.utc)
        end_date = start_date + timedelta(days=days)

        schedule_id = str(uuid.uuid4())

        schedule_doc = {
            "user_id": user_id,
            "medicine_id": med_id,
            "drug_name": med.get("drug_name"),
            "dose": med.get("dose"),
            "times_per_day": times_per_day,
            "days": days,
            "times": times,
            "start_date": start_date,
            "end_date": end_date,
            "created_at": datetime.now(timezone.utc),
        }

        db.collection("schedules").document(schedule_id).set(schedule_doc)
        schedule_ids.append(schedule_id)

    return schedule_ids
