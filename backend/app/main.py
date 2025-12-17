from fastapi import FastAPI
from dotenv import load_dotenv

load_dotenv()

from app.routes.ocr_routes import router as ocr_router

app = FastAPI(
    title="OPSW Backend",
    description="OCR → AI → Firestore Pipeline",
    version="1.0.0"
)

# OCR + AI + Save 라우터 포함
app.include_router(ocr_router)


@app.get("/")
def root():
    return {"msg": "Backend is running"}
