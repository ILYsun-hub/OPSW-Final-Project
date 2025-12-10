from google.cloud import vision
import io
import os

def extract_text_from_image(file_bytes: bytes) -> str:
    print("GOOGLE_APPLICATION_CREDENTIALS =", os.getenv("GOOGLE_APPLICATION_CREDENTIALS"))

    client = vision.ImageAnnotatorClient()
    image = vision.Image(content=file_bytes)

    response = client.text_detection(image=image)

    if response.error.message:
        raise Exception(f"OCR Error: {response.error.message}")

    texts = response.text_annotations
    if not texts:
        return ""

    return texts[0].description
