from fastapi import APIRouter
from app.services.missed_dose_service import process_missed_doses

router = APIRouter(prefix="/api/alerts", tags=["alerts"])

@router.post("/check")
def check_missed():
    process_missed_doses()
    return {"status": "ok"}
