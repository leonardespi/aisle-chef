
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session, select, SQLModel, create_engine
from typing import List, Dict, Any
from .models import Recipe, Ingredient, Pairing, Store
import os
import json

DB_PATH = os.path.join(os.path.dirname(__file__), "..", "aisle_chef.db")
DB_URL = f"sqlite:///{os.path.abspath(DB_PATH)}"
engine = create_engine(DB_URL, echo=False)

app = FastAPI(title="Aisle Chef API", version="0.1.0")

# CORS for local Flutter web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def _get_store(session: Session) -> Store:
    store = session.exec(select(Store)).first()
    if not store:
        raise HTTPException(status_code=500, detail="Store not configured.")
    return store

@app.get("/recipes")
def list_recipes() -> List[Dict[str, Any]]:
    with Session(engine) as session:
        recipes = session.exec(select(Recipe)).all()
        return [
            {
                "id": r.id,
                "title": r.title,
                "tags": r.tags,
                "image": r.image,
            }
            for r in recipes
        ]

@app.get("/recipes/{recipe_id}")
def get_recipe(recipe_id: int) -> Dict[str, Any]:
    with Session(engine) as session:
        recipe = session.get(Recipe, recipe_id)
        if not recipe:
            raise HTTPException(status_code=404, detail="Recipe not found")
        # Resolve ingredient details
        items = []
        for item in recipe.ingredients:
            ing = session.exec(select(Ingredient).where(Ingredient.name == item["name"])).first()
            if not ing:
                # If ingredient is missing from catalog, still return the requested quantity but mark missing
                items.append({
                    "name": item["name"],
                    "quantity": item.get("quantity"),
                    "unit": item.get("unit"),
                    "price": None,
                    "location": None,
                    "substitutes": [],
                    "missing": True,
                })
            else:
                items.append({
                    "name": ing.name,
                    "quantity": item.get("quantity"),
                    "unit": item.get("unit", ing.unit),
                    "price": ing.price,
                    "location": ing.location,
                    "substitutes": ing.substitutes,
                    "missing": False,
                })
        pairing = session.exec(select(Pairing).where(Pairing.recipe_id == recipe_id)).first()
        return {
            "id": recipe.id,
            "title": recipe.title,
            "tags": recipe.tags,
            "image": recipe.image,
            "steps": recipe.steps,
            "ingredients": items,
            "pairing": pairing.dict() if pairing else None,
        }

@app.get("/recipes/{recipe_id}/route")
def get_recipe_route(recipe_id: int) -> Dict[str, Any]:
    from .services import optimize_route
    with Session(engine) as session:
        recipe = session.get(Recipe, recipe_id)
        if not recipe:
            raise HTTPException(status_code=404, detail="Recipe not found")
        store = _get_store(session)
        # Collect aisle codes needed
        aisle_codes = []
        for item in recipe.ingredients:
            ing = session.exec(select(Ingredient).where(Ingredient.name == item["name"])).first()
            if ing and ing.location and "code" in ing.location:
                aisle_codes.append(ing.location["code"])
        aisle_codes = list(dict.fromkeys(aisle_codes))  # de-dup preserving order
        if not aisle_codes:
            return {"route": [], "aisles": store.aisles}

        route = optimize_route(aisle_codes, store.aisles)
        return {"route": route, "aisles": store.aisles}
