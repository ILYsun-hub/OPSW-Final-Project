import os
import firebase_admin
from firebase_admin import credentials

def init_firebase():
    if firebase_admin._apps:
        return

    key_path = os.getenv("FIREBASE_ADMIN_KEY")
    cred = credentials.Certificate(key_path)
    firebase_admin.initialize_app(cred)
