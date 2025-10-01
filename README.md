
# Aisle Chef MVP

A self-contained MVP of **Aisle Chef**, a meal & shopping planning assistant. Pick a recipe from a visual catalog, view steps and ingredients (with prices and in-store locations for a fictional **Walmart Supercenter**), and get a suggested pairing. Generate an optimized store route to shop efficiently.

---

## Prerequisites
- **Python 3.11+**
- **pip** (Python package manager)
- **Flutter SDK 3.24+** (Dart 3.5+)
- Chrome browser for Flutter Web

> Tested with: FastAPI 0.115, SQLModel 0.0.21, Flutter Web target.

---

## Backend Setup

```bash
cd backend
python -m venv .venv
# Activate:
#   Windows: .venv\Scripts\activate
#   macOS/Linux:
source .venv/bin/activate

pip install -r requirements.txt
```

Initialize the SQLite database:

```bash
cd app
python database.py
# Creates backend/aisle_chef.db and seeds data
cd ..
```

Run the API server:

```bash
uvicorn app.main:app --reload
# Server runs at http://127.0.0.1:8000
```

API endpoints:
- `GET /recipes`
- `GET /recipes/{recipe_id}`
- `GET /recipes/{recipe_id}/route`

---

## Frontend Setup (Flutter Web)

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

The app will open in Chrome. Ensure the backend is running at `http://127.0.0.1:8000` (the default in the client).

---

## Project Structure

```
aisle_chef_mvp/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── models.py
│   │   ├── database.py
│   │   └── services.py
│   ├── requirements.txt
│   └── aisle_chef.db
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   │   └── recipe.dart
│   │   ├── providers/
│   │   │   └── api_provider.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── recipe_detail_screen.dart
│   │   │   └── shopping_route_screen.dart
│   │   └── services/
│   │       └── api_service.dart
│   ├── pubspec.yaml
│   └── web/
│       └── index.html
└── README.md
```

---

## Notes

- CORS is enabled for local development.
- Images are loaded from `picsum.photos` seeds to avoid API keys.
- Route optimization uses aisle order for simplicity (MVP). Extendable to graph-based shortest-path later.
- Basic error handling returns `404` for missing recipes and passes through message to the UI.
