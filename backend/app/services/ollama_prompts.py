# app/services/ollama_prompts.py

def build_drug_parse_prompt(ocr_text: str):
    return f"""
당신은 '노인 복약 관리 AI'입니다.

다음 OCR 텍스트에서 약 정보를 정확하게 구조화하여 JSON으로 추출하십시오.

규칙:
- 약품명 오타는 문맥 기반으로 교정
- 정/캡슐/시럽/서방정 등 제형 추출
- mg 또는 mL 단위 용량 식별 및 정규화
- 하루 복용 횟수(times_per_day), 1회량(amount_per_dose), 일수(days) 추출
- 성분명(ingredient)도 가능하면 추론
- JSON 외 다른 문장 출력 금지

OCR 원문:
\"\"\"{ocr_text}\"\"\"

출력 JSON 예시:
{{
  "drugs": [
    {{
      "drug_name": "", 
      "normalized_name": "",
      "dose": "",
      "ingredient": "",
      "amount_per_dose": "",
      "times_per_day": "",
      "days": ""
    }}
  ]
}}
"""
