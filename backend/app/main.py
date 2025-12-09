from fastapi import FastAPI, UploadFile, File
from dotenv import load_dotenv

load_dotenv()

from app.routes.ocr_routes import router as ocr_router

app = FastAPI()
app.include_router(ocr_router)

@app.get("/")
def root():
    return {"msg": "Backend is running"}

@app.post("/ocr")
async def upload_image(file: UploadFile = File(...)):
    return {"filename": file.filename}

