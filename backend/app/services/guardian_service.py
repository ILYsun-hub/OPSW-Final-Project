from google.cloud import firestore
from datetime import datetime, timezone
import os

db = firestore.Client.from_service_account_json(
    os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
)


def link_guardian(user_id: str, guardian_id: str):
    """
    사용자 ↔ 보호자 연결
    (중복 방지)
    """
    existing = (
        db.collection("user_guardians")
        .where("user_id", "==", user_id)
        .where("guardian_id", "==", guardian_id)
        .limit(1)
        .stream()
    )

    if any(existing):
        return {"status": "already_linked"}

    db.collection("user_guardians").add({
        "user_id": user_id,
        "guardian_id": guardian_id,
        "created_at": datetime.now(timezone.utc)
    })

    return {"status": "linked"}


def get_guardians_by_user(user_id: str):
    """
    사용자 기준 보호자 목록 조회
    """
    links = (
        db.collection("user_guardians")
        .where("user_id", "==", user_id)
        .stream()
    )

    guardians = []

    for link in links:
        guardian_id = link.to_dict()["guardian_id"]
        guardian_doc = db.collection("guardians").document(guardian_id).get()

        if guardian_doc.exists:
            data = guardian_doc.to_dict()
            guardians.append({
                "guardian_id": guardian_id,
                "name": data.get("name"),
                "phone": data.get("phone"),
                "fcm_token_exists": bool(data.get("fcm_token"))
            })

    return {"guardians": guardians}


def unlink_guardian(user_id: str, guardian_id: str):
    """
    보호자 연결 해제
    """
    links = (
        db.collection("user_guardians")
        .where("user_id", "==", user_id)
        .where("guardian_id", "==", guardian_id)
        .stream()
    )

    deleted = False
    for link in links:
        link.reference.delete()
        deleted = True

    if not deleted:
        return {"status": "not_found"}

    return {"status": "unlinked"}
