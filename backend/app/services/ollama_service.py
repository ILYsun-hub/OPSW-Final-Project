# app/services/ollama_service.py

import requests
import json
import re
from app.services.ollama_prompts import build_drug_parse_prompt
from app.utils.json_extractor import extract_json_from_text   

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL_NAME = "hf.co/MLP-KTLim/llama-3-Korean-Bllossom-8B-gguf-Q4_K_M"


# ---------------------------------
# Ollama API 호출 함수
# ---------------------------------
def ask_ollama(prompt: str, model: str = MODEL_NAME):
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False
    }

    try:
        res = requests.post(OLLAMA_URL, json=payload)
        res.raise_for_status()

        data = res.json()
        return data.get("response")

    except Exception as e:
        print("Ollama Error:", e)
        raise e


# ---------------------------------
# OCR → LLM 분석 전체 프로세스
# ---------------------------------
def analyze_ocr_text_with_llm(raw_text: str):
    """
    1) OCR 텍스트를 받아서
    2) 프롬프트 생성
    3) Ollama 호출
    4) LLM JSON 결과 반환
    """

    # 1) 프롬프트 생성
    prompt = build_drug_parse_prompt(raw_text)

    # 2) Ollama 호출
    llm_raw_output = ask_ollama(prompt)

    # 코드블록 제거 + 공백 정리
    cleaned_output = (
        llm_raw_output
        .replace("```json", "")
        .replace("```", "")
        .strip()
    )

    # [추가] 가장 바깥 JSON만 추출
    match = re.search(r"\{[\s\S]*\}", cleaned_output)
    if not match:
        print("JSON Parsing 실패 → LLM 출력:")
        print(llm_raw_output)
        raise Exception("LLM 출력에서 JSON을 찾을 수 없습니다.")

    json_text = match.group()

    # 3) JSON 변환
    try:
        parsed = extract_json_from_text(json_text)
    except Exception:
        print("JSON Parsing 실패 → LLM 출력:")
        print(llm_raw_output)
        raise Exception("LLM JSON 파싱 실패. 프롬프트 또는 모델 출력 확인 필요.")

    return parsed
