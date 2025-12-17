from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.ocr_service import extract_text_from_image
from app.utils.parser import parse_ocr_text
# from app.services.drug_enrichment import enrich_ocr_drugs

from app.services.ollama_service import analyze_ocr_text_with_llm

# 🔥 zFirestore 저장 로직 추가
from app.services.firestore_store import (
    save_scan,
    save_medicines,
    save_prescription,
    save_schedules
)

router = APIRouter(prefix="/api/ocr", tags=["OCR"])


# -------------------------
# 1) OCR 업로드
# -------------------------
@router.post("/upload")
async def upload_image(file: UploadFile = File(...)):
    try:
        file_bytes = await file.read()

        raw_text = extract_text_from_image(file_bytes)

        parsed = parse_ocr_text(raw_text)

        return {
            "success": True,
            "data": {
                "raw_text": raw_text,
                "parsed": parsed
            }
        }

    except Exception as e:
        print("OCR ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))


'''
# ----------------------------------------------------
# 2) FULL OCR + 약 API 검색 
# ----------------------------------------------------
@router.post("/upload/full")
async def upload_image_with_drug_info(file: UploadFile = File(...)):
    try:
        file_bytes = await file.read()

        # OCR
        raw_text = extract_text_from_image(file_bytes)

        # 파싱 (약명, 용량, 횟수 등)
        parsed = parse_ocr_text(raw_text)

        # 약 검색 + 효능/주의/부작용 포함한 enrichment
        drug_details = enrich_ocr_drugs(parsed["drugs"])

        return {
            "success": True,
            "raw_text": raw_text,
            "parsed": parsed,
            "drug_details": drug_details
        }

    except Exception as e:
        print("OCR+Drug ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))
'''


# ----------------------------------------------------
# 3)  OCR + Ollama AI 분석
# ----------------------------------------------------
@router.post("/upload/ai")
async def upload_image_with_ai(file: UploadFile = File(...)):
    try:
        file_bytes = await file.read()

        # 1) OCR
        raw_text = extract_text_from_image(file_bytes)

        # 2) Ollama 분석 (약명 정규화 + 용량 추출 + JSON)
        ai_parsed = analyze_ocr_text_with_llm(raw_text)

        return {
            "success": True,
            "raw_text": raw_text,
            "ai_parsed": ai_parsed
        }

    except Exception as e:
        print("OCR+AI ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))



# ----------------------------------------------------
# 4) OCR + AI 분석 + Firestore 저장 (Full pipeline)
# ----------------------------------------------------
@router.post("/upload/ai/save")
async def upload_image_ai_and_save(file: UploadFile = File(...)):
    try:
        user_id = "test_user_001"

        file_bytes = await file.read()

        # 1) OCR
        raw_text = extract_text_from_image(file_bytes)

        # 2) AI 분석
        ai_parsed = analyze_ocr_text_with_llm(raw_text)

        medications = ai_parsed.get("drugs", [])

        # 3) Firestore 저장
        scan_id = save_scan(user_id, raw_text, ai_parsed)
        medicine_ids = save_medicines(user_id, scan_id, medications)
        prescription_id = save_prescription(user_id, scan_id, medicine_ids)
        schedule_ids = save_schedules(user_id, medicine_ids, medications)

        return {
            "success": True,
            "message": "OCR + AI 분석 + 저장 완료",
            "scan_id": scan_id,
            "prescription_id": prescription_id,
            "medicine_ids": medicine_ids,
            "schedule_ids": schedule_ids,
            "raw_text": raw_text,
            "ai_parsed": ai_parsed
        }

    except Exception as e:
        print("FULL PIPELINE ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))
