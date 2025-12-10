import re
import json

def extract_json_from_text(text: str):
    """
    LLM 출력에서 JSON 블록만 깔끔하게 추출하는 함수
    """

    # 코드블록 안 JSON (```json ... ```)
    codeblock_match = re.search(r"```json\s*(\{[\s\S]*?\})\s*```", text)
    if codeblock_match:
        return json.loads(codeblock_match.group(1))

    # 코드블록 없이 첫 JSON만 추출
    pure_json_match = re.search(r"(\{[\s\S]*\})", text)
    if pure_json_match:
        return json.loads(pure_json_match.group(1))

    raise ValueError("JSON 블록을 찾을 수 없음")
