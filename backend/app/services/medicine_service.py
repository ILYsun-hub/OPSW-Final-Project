from app.core.firebase import get_db

db = get_db()

def get_medicine_detail(item_seq: str):
    doc = db.collection("medicines").document(item_seq).get()
    if not doc.exists:
        return None
    return doc.to_dict()


def find_medicine_by_name(normalized_name: str):
    docs = (
        db.collection("medicines")
        .where("itemName", "==", normalized_name)
        .limit(1)
        .stream()
    )

    for doc in docs:
        data = doc.to_dict()
        data["itemSeq"] = doc.id
        return data

    return None


def enrich_medications(medications: list):
    enriched = []

    for drug in medications:
        name = drug.get("normalized_name")
        medicine_detail = None

        if name:
            medicine_detail = find_medicine_by_name(name)

        enriched.append({
            "recognized_name": name,
            "ai_extracted": drug,
            "medicine_detail": medicine_detail
        })

    return enriched
