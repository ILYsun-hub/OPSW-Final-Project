from fastapi import APIRouter, Body, Query
from app.services.guardian_service import (
    link_guardian,
    get_guardians_by_user,
    unlink_guardian
)

router = APIRouter(
    prefix="/api/guardians",
    tags=["Guardians"]
)


@router.post("/link")
def link_guardian_api(
    user_id: str = Body(...),
    guardian_id: str = Body(...)
):
    """
    보호자 연결
    """
    return link_guardian(user_id, guardian_id)


@router.get("")
def get_guardians_api(
    user_id: str = Query(...)
):
    """
    사용자 기준 보호자 목록 조회
    """
    return get_guardians_by_user(user_id)


@router.delete("/link")
def unlink_guardian_api(
    user_id: str = Body(...),
    guardian_id: str = Body(...)
):
    """
    보호자 연결 해제
    """
    return unlink_guardian(user_id, guardian_id)
