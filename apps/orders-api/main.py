from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import httpx
import os
import uuid

app = FastAPI(title="Orders API")

INVENTORY_URL = os.getenv(
    "INVENTORY_URL",
    "http://localhost:8001"
)

orders = {}


class OrderRequest(BaseModel):
    product_id: int
    quantity: int = Field(gt=0)


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/orders")
def get_orders():
    return list(orders.values())


@app.post("/orders", status_code=201)
async def create_order(request: OrderRequest):
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.post(
                f"{INVENTORY_URL}/reserve",
                json=request.model_dump()
            )
    except httpx.RequestError:
        raise HTTPException(
            status_code=503,
            detail="Inventory service unavailable"
        )

    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail=response.json().get("detail", "Inventory error")
        )

    inventory = response.json()

    order_id = str(uuid.uuid4())

    order = {
        "order_id": order_id,
        "product_id": request.product_id,
        "quantity": request.quantity,
        "total_price": inventory["unit_price"] * request.quantity,
        "status": "confirmed"
    }

    orders[order_id] = order

    return order

