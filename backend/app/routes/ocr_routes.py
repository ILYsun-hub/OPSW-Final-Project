from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.ocr_service import extract_text_from_image
from app.utils.parser import parse_ocr_text
from app.services.drug_enrichment import enrich_ocr_drugs

# ⭐ 추가된 부분
from app.services.ollama_service import analyze_ocr_text_with_llm

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
