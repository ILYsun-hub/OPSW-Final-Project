"""
elder_service.py

- 노인(피보호자) 생성 / 조회
"""

from google.cloud import firestore
from datetime import datetime, timezone
import uuid
import os

db = firestore.Client.from_service_account_json(
    os.getenv("FIREBASE_ADMIN_KEY")
)

def create_elder(user_id: str, name: str, birth: str = None, gender: str = None):
    elder_id = str(uuid.uuid4())

    doc = {
        "user_id": user_id,
        "name": name,
        "birth": birth,
        "gender": gender,
        "created_at": datetime.now(timezone.utc),
    }

    db.collection("elders").document(elder_id).set(doc)
    return elder_id


def get_elders_by_user(user_id: str):
    docs = (
        db.collection("elders")
        .where("user_id", "==", user_id)
        .stream()
    )

    result = []
    for d in docs:
        data = d.to_dict()
        data["elder_id"] = d.id
        result.append(data)

    return result

def get_or_create_elder(user_id: str, name: str):
    docs = (
        db.collection("elders")
        .where("user_id", "==", user_id)
        .where("name", "==", name)
        .stream()
    )

    for d in docs:
        return d.id  # 이미 있으면 그대로 사용

    # 없으면 자동 생성
    elder_id = str(uuid.uuid4())
    db.collection("elders").document(elder_id).set({
        "user_id": user_id,
        "name": name,
        "created_at": datetime.now(timezone.utc),
    })
    return elder_id
