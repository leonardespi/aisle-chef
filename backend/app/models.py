
from typing import Optional, List, Dict, Any
from sqlmodel import SQLModel, Field, Column, JSON

class Store(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    layout_version: str
    # aisles: list of dicts: [{"code":"A1","name":"Fresh Produce","index":0}, ...]
    aisles: List[Dict[str, Any]] = Field(default_factory=list, sa_column=Column(JSON))

class Ingredient(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True, unique=True)
    price: float
    unit: str
    # location: {"code":"A1","area":"Front Left"}
    location: Dict[str, Any] = Field(default_factory=dict, sa_column=Column(JSON))
    substitutes: List[str] = Field(default_factory=list, sa_column=Column(JSON))

class Recipe(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    tags: List[str] = Field(default_factory=list, sa_column=Column(JSON))
    image: str
    steps: List[str] = Field(default_factory=list, sa_column=Column(JSON))
    # ingredients: [{"name":"Spaghetti","quantity":500,"unit":"g"}]
    ingredients: List[Dict[str, Any]] = Field(default_factory=list, sa_column=Column(JSON))

class Pairing(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    recipe_id: int = Field(index=True)
    type: str  # e.g., wine, beer, side
    title: str
    aisle_code: str
    rationale: str
