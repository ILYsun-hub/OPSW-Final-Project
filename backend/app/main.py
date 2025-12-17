from dotenv import load_dotenv
load_dotenv() 

from fastapi import FastAPI

from app.routes.ocr_routes import router as ocr_router
from app.routes.intake_routes import router as intake_router


app = FastAPI(
    title="OPSW Backend",
    description="OCR → AI → Firestore Pipeline",
    version="1.0.0"
)

# OCR + AI + Save
app.include_router(ocr_router)
app.include_router(intake_router)

# 복약 알림
app.include_router(alert_router)

# 보호자-사용자 연결 관리
app.include_router(guardian_router)

# app.include_router(schedule_router)

@app.get("/")
def root():
    return {"msg": "Backend is running"}
