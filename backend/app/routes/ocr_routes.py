from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.ocr_service import extract_text_from_image
from app.utils.parser import parse_ocr_text

router = APIRouter(prefix="/api/ocr", tags=["OCR"])

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
