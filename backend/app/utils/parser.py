import re

def parse_ocr_text(text: str):
    lines = [line.strip() for line in text.split("\n") if line.strip()]
    drugs = []

    # 약품명 패턴
    name_pattern = re.compile(
        r"[가-힣A-Za-z]+(?:정|캡슐)\s*\d{1,4}m(?:g)?"
    )
    
    # 용법 패턴
    dosage_pattern = re.compile(
        r"(?P<amount>\d+)\s*(?:정|캡슐)?\s*씩?\s*(?P<times>\d+)회\s*(?P<days>\d+)일분"
    )

    i = 0
    while i < len(lines):
        line = lines[i]

        # --- 1) 약품명 찾기 ---
        name_match = name_pattern.search(line)
        if name_match:
            name = name_match.group()

            # mg 보정 처리 (예: 300m → 300mg)
            name = re.sub(r"(\d+)m$", r"\1mg", name)

            # 용량 추출
            dose_match = re.search(r"(\d+mg)", name)
            dose = dose_match.group(1) if dose_match else None

            # --- 중복 방지 ---
            if any(d["drug_name"] == name for d in drugs):
                i += 1
                continue

            # --- 2) 용법 찾기 (10줄까지) ---
            amount = times = days = None
            for j in range(1, 11):
                if i + j < len(lines):
                    check = lines[i + j]
                    dosage_match = dosage_pattern.search(check)
                    if dosage_match:
                        amount = dosage_match.group("amount")
                        times = dosage_match.group("times")
                        days = dosage_match.group("days")
                        break

            # --- 결과 저장 ---
            drugs.append({
                "drug_name": name,
                "dose": dose,
                "amount_per_dose": amount,
                "times_per_day": times,
                "days": days
            })

        i += 1

    return {"drugs": drugs}
