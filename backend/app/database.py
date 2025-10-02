
from sqlmodel import SQLModel, create_engine, Session
from .models import Store, Ingredient, Recipe, Pairing
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "..", "aisle_chef.db")
DB_URL = f"sqlite:///{os.path.abspath(DB_PATH)}"
engine = create_engine(DB_URL, echo=False)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

def populate_data():
    with Session(engine) as session:
        # Store & aisle layout
        aisles = [
            {"code": "A1", "name": "Fresh Produce", "index": 0},
            {"code": "A2", "name": "Dairy & Eggs", "index": 1},
            {"code": "B1", "name": "Meats & Seafood", "index": 2},
            {"code": "C1", "name": "Pantry & Canned Goods", "index": 3},
            {"code": "C2", "name": "Pasta & Grains", "index": 4},
            {"code": "C3", "name": "Baking & Spices", "index": 5},
            {"code": "D1", "name": "Frozen Foods", "index": 6},
            {"code": "E1", "name": "Beverages", "index": 7},
            {"code": "E2", "name": "Wine & Beer", "index": 8},
            {"code": "F1", "name": "Breads & Bakery", "index": 9},
            {"code": "G1", "name": "International Foods", "index": 10},
            {"code": "H1", "name": "Condiments & Sauces", "index": 11},
        ]
        store = Store(name="Walmart Supercenter", layout_version="v1", aisles=aisles)
        session.add(store)

        # Ingredients catalog (subset adequate for recipes)
        def I(name, price, unit, code, area, subs=None):
            return Ingredient(
                name=name, price=price, unit=unit,
                location={"code": code, "area": area},
                substitutes=subs or []
            )

        ingredients = [
            I("Spaghetti", 1.49, "lb", "C2", "Middle"),
            I("Eggs", 2.99, "dozen", "A2", "Rear"),
            I("Parmesan Cheese", 4.50, "cup", "A2", "Cheese Case"),
            I("Pancetta", 5.99, "lb", "B1", "Deli"),
            I("Black Pepper", 1.29, "jar", "C3", "Spices"),
            I("Salt", 0.99, "jar", "C3", "Spices"),
            I("Garlic", 0.50, "bulb", "A1", "Front"),
            I("Chicken Breast", 6.99, "lb", "B1", "Refrigerated"),
            I("Tortillas", 2.50, "pack", "G1", "Mexican"),
            I("Onion", 0.80, "ea", "A1", "Front"),
            I("Tomato", 0.70, "ea", "A1", "Front"),
            I("Cilantro", 0.90, "bunch", "A1", "Front"),
            I("Lime", 0.40, "ea", "A1", "Front"),
            I("Chili Powder", 1.20, "jar", "C3", "Spices"),
            I("Cumin", 1.10, "jar", "C3", "Spices"),
            I("Kidney Beans", 1.00, "can", "C1", "Canned"),
            I("Black Beans", 1.00, "can", "C1", "Canned"),
            I("Crushed Tomatoes", 1.50, "can", "C1", "Canned"),
            I("Vegetable Broth", 1.20, "carton", "C1", "Soups"),
            I("Sweet Potato", 1.00, "ea", "A1", "Rear"),
            I("Salmon Fillet", 9.99, "lb", "B1", "Seafood"),
            I("Asparagus", 2.99, "bunch", "A1", "Rear"),
            I("Olive Oil", 5.50, "bottle", "H1", "Oils"),
            I("Burger Buns", 2.20, "pack", "F1", "Bakery"),
            I("Ground Beef", 5.49, "lb", "B1", "Refrigerated"),
            I("Cheddar Cheese", 3.50, "block", "A2", "Cheese Case"),
            I("Lettuce", 1.30, "head", "A1", "Front"),
            I("Pickles", 2.40, "jar", "H1", "Pickled"),
            I("Ketchup", 1.80, "bottle", "H1", "Sauces"),
            I("Mustard", 1.20, "bottle", "H1", "Sauces"),
            I("Paprika", 1.00, "jar", "C3", "Spices"),
            I("Chili Flakes", 1.00, "jar", "C3", "Spices"),
            I("Brown Sugar", 1.30, "bag", "C3", "Baking"),
            I("Soy Sauce", 2.10, "bottle", "G1", "Asian"),
        ]
        session.add_all(ingredients)

        # Recipes
        def R(title, tags, image, steps, ings):
            return Recipe(title=title, tags=tags, image=image, steps=steps, ingredients=ings)

        recipes = [
            R(
                "Spaghetti Carbonara",
                ["italian", "classics", "pasta"],
                "assets/images/spagetti.jpg",
                [
                    "Bring a large pot of salted water to a boil. Cook spaghetti until al dente.",
                    "In a bowl, whisk eggs and grated Parmesan.",
                    "Cook pancetta until crisp; reserve fat.",
                    "Toss pasta with pancetta, remove from heat, and quickly stir in egg-cheese mixture to create a creamy sauce.",
                    "Season with black pepper and adjust salt to taste."
                ],
                [
                    {"name": "Spaghetti", "quantity": 500, "unit": "g"},
                    {"name": "Eggs", "quantity": 3, "unit": "pcs"},
                    {"name": "Parmesan Cheese", "quantity": 1, "unit": "cup"},
                    {"name": "Pancetta", "quantity": 150, "unit": "g"},
                    {"name": "Black Pepper", "quantity": 1, "unit": "tsp"},
                    {"name": "Salt", "quantity": 0.5, "unit": "tsp"}
                ]
            ),
            R(
                "Chicken Tacos",
                ["mexican", "quick"],
                "assets/images/chicken_tacos.jpg",
                [
                    "Season chicken with chili powder, cumin, salt.",
                    "Sauté chicken until cooked; slice.",
                    "Warm tortillas.",
                    "Assemble with onion, tomato, cilantro, and a squeeze of lime."
                ],
                [
                    {"name": "Chicken Breast", "quantity": 400, "unit": "g"},
                    {"name": "Tortillas", "quantity": 8, "unit": "pcs"},
                    {"name": "Onion", "quantity": 1, "unit": "ea"},
                    {"name": "Tomato", "quantity": 2, "unit": "ea"},
                    {"name": "Cilantro", "quantity": 1, "unit": "bunch"},
                    {"name": "Lime", "quantity": 2, "unit": "ea"},
                    {"name": "Chili Powder", "quantity": 1, "unit": "tsp"},
                    {"name": "Cumin", "quantity": 1, "unit": "tsp"},
                    {"name": "Salt", "quantity": 0.5, "unit": "tsp"}
                ]
            ),
            R(
                "Vegan Chili",
                ["vegan", "stew"],
                "assets/images/vega_chili.jpg",
                [
                    "Sauté onion and garlic in olive oil until translucent.",
                    "Add spices, beans, crushed tomatoes, broth, and diced sweet potato.",
                    "Simmer 25–30 minutes until tender; adjust seasoning."
                ],
                [
                    {"name": "Onion", "quantity": 1, "unit": "ea"},
                    {"name": "Garlic", "quantity": 2, "unit": "cloves"},
                    {"name": "Olive Oil", "quantity": 2, "unit": "tbsp"},
                    {"name": "Chili Powder", "quantity": 2, "unit": "tsp"},
                    {"name": "Cumin", "quantity": 1, "unit": "tsp"},
                    {"name": "Kidney Beans", "quantity": 2, "unit": "cans"},
                    {"name": "Black Beans", "quantity": 1, "unit": "can"},
                    {"name": "Crushed Tomatoes", "quantity": 1, "unit": "can"},
                    {"name": "Vegetable Broth", "quantity": 2, "unit": "cups"},
                    {"name": "Sweet Potato", "quantity": 1, "unit": "ea"},
                    {"name": "Salt", "quantity": 0.5, "unit": "tsp"}
                ]
            ),
            R(
                "Salmon with Asparagus",
                ["seafood", "healthy"],
                "assets/images/salmon_with_asparagus.jpg",
                [
                    "Preheat oven to 400°F / 205°C.",
                    "Toss asparagus with olive oil and salt; arrange on sheet pan.",
                    "Add salmon fillets, season with salt, pepper, paprika; roast 12–15 minutes."
                ],
                [
                    {"name": "Salmon Fillet", "quantity": 2, "unit": "pieces"},
                    {"name": "Asparagus", "quantity": 1, "unit": "bunch"},
                    {"name": "Olive Oil", "quantity": 1, "unit": "tbsp"},
                    {"name": "Salt", "quantity": 0.5, "unit": "tsp"},
                    {"name": "Paprika", "quantity": 0.5, "unit": "tsp"}
                ]
            ),
            R(
                "Classic Burger",
                ["classics", "grill"],
                "assets/images/classic_burger.png",
                [
                    "Form ground beef into patties; season with salt and pepper.",
                    "Grill or pan-sear until desired doneness.",
                    "Toast burger buns; assemble with cheese, lettuce, pickles, ketchup, mustard."
                ],
                [
                    {"name": "Ground Beef", "quantity": 500, "unit": "g"},
                    {"name": "Burger Buns", "quantity": 4, "unit": "pcs"},
                    {"name": "Cheddar Cheese", "quantity": 4, "unit": "slices"},
                    {"name": "Lettuce", "quantity": 4, "unit": "leaves"},
                    {"name": "Pickles", "quantity": 8, "unit": "slices"},
                    {"name": "Ketchup", "quantity": 2, "unit": "tbsp"},
                    {"name": "Mustard", "quantity": 1, "unit": "tbsp"},
                    {"name": "Black Pepper", "quantity": 0.5, "unit": "tsp"},
                    {"name": "Salt", "quantity": 0.5, "unit": "tsp"}
                ]
            ),
        ]
        session.add_all(recipes)

        # Pairings
        pairings = [
            Pairing(recipe_id=1, type="wine", title="Chianti DOCG", aisle_code="E2", rationale="Cuts through the richness of Carbonara."),
            Pairing(recipe_id=2, type="beer", title="Craft Lager", aisle_code="E2", rationale="Crisp finish complements spices."),
            Pairing(recipe_id=3, type="side", title="Cornbread Mix", aisle_code="C3", rationale="Adds sweetness and texture."),
            Pairing(recipe_id=4, type="side", title="Brown Rice", aisle_code="C2", rationale="Hearty, nutritious base."),
            Pairing(recipe_id=5, type="beverage", title="Cola 6-pack", aisle_code="E1", rationale="Classic burger-night pairing."),
        ]
        session.add_all(pairings)
        session.commit()

if __name__ == "__main__":
    create_db_and_tables()
    populate_data()
    print(f"Database created at: {DB_PATH}")
