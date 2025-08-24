from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
from datetime import datetime

app = FastAPI()

# Allow CORS for local development (adjust origins as needed)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Transaction(BaseModel):
    id: str
    amount: float
    date: datetime
    category: str
    description: str

# TODO: Integrate with Plaid API to fetch real transactions
def get_transactions_from_plaid() -> List[Transaction]:
    # Replace this mock data with Plaid API integration
    return [
        Transaction(id="1", amount=20.0, date=datetime(2025, 8, 24), category="Food", description="Lunch"),
        Transaction(id="2", amount=50.0, date=datetime(2025, 8, 23), category="Transport", description="Taxi"),
        Transaction(id="3", amount=100.0, date=datetime(2025, 8, 22), category="Shopping", description="Clothes"),
    ]

@app.get("/transactions", response_model=List[Transaction])
def get_transactions():
    """
    Endpoint to retrieve a list of transactions.

    Returns:
        List[Transaction]: A list of transaction objects fetched from Plaid.
    """
    return get_transactions_from_plaid()
