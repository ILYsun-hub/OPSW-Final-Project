import firebase_admin
from firebase_admin import credentials, firestore
import os

_app = None
_db = None

def get_db():
    global _app, _db

    if _db:
        return _db

    if not firebase_admin._apps:
        cred_path = os.getenv("FIREBASE_ADMIN_KEY")
        if not cred_path:
            raise RuntimeError("FIREBASE_ADMIN_KEY 환경변수가 설정되지 않았습니다.")

        cred = credentials.Certificate(cred_path)
        _app = firebase_admin.initialize_app(cred)

    _db = firestore.client()
    return _db
