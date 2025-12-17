from fastapi import APIRouter, HTTPException
from app.services.medicine_service import get_medicine_detail

router = APIRouter(prefix="/api/medicines", tags=["Medicines"])

@router.get("/{item_seq}")
def get_medicine(item_seq: str):
    medicine = get_medicine_detail(item_seq)

    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")

    return medicine
