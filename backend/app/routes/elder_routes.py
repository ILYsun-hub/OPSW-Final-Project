"""
elder_routes.py

- 노인 생성
- 보호자 기준 노인 목록 조회
"""

from fastapi import APIRouter
from app.services.elder_service import create_elder, get_elders_by_user

router = APIRouter(prefix="/api/elders", tags=["Elders"])

@router.post("")
def create(user_id: str, name: str, birth: str = None, gender: str = None):
    elder_id = create_elder(user_id, name, birth, gender)
    return {"elder_id": elder_id}


@router.get("")
def list_elders(user_id: str):
    return {
        "elders": get_elders_by_user(user_id)
    }
