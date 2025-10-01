
from typing import List, Dict

def optimize_route(aisle_codes: List[str], store_aisles: List[Dict]) -> List[Dict]:
    """
    Simple optimizer: sort requested aisles by their index in store_aisles.
    Returns a list of {code, name, index}
    """
    index_map = {a.get("code"): a.get("index", i) for i, a in enumerate(store_aisles)}
    name_map = {a.get("code"): a.get("name") for a in store_aisles}
    unique_codes = []
    seen = set()
    for c in aisle_codes:
        if c not in seen:
            unique_codes.append(c)
            seen.add(c)
    sorted_codes = sorted(unique_codes, key=lambda c: index_map.get(c, 1_000_000))
    return [{"code": c, "name": name_map.get(c, c), "index": index_map.get(c, -1)} for c in sorted_codes]
