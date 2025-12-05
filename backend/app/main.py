from fastapi import FastAPI, UploadFile, File

app = FastAPI()

@app.get("/")
def root():
    return {"msg": "Backend is running"}

@app.post("/ocr")
async def upload_image(file: UploadFile = File(...)):
    return {"filename": file.filename}