from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Inventory Service")

products = {
    101: {"name": "Keyboard", "price": 150, "stock": 10},
    102: {"name": "Mouse", "price": 80, "stock": 20},
    103: {"name": "Monitor", "price": 900, "stock": 5}
}


class PurchaseRequest(BaseModel):
    product_id: int
    quantity: int


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/products")
def get_products():
    return products


@app.get("/products/{product_id}")
def get_product(product_id: int):
    if product_id not in products:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    return products[product_id]


@app.post("/reserve")
def reserve_product(request: PurchaseRequest):
    if request.quantity <= 0:
        raise HTTPException(
            status_code=400,
            detail="Quantity must be positive"
        )

    product = products.get(request.product_id)

    if product is None:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    if product["stock"] < request.quantity:
        raise HTTPException(
            status_code=409,
            detail="Not enough stock"
        )

    product["stock"] -= request.quantity

    return {
        "product_id": request.product_id,
        "quantity": request.quantity,
        "unit_price": product["price"],
        "remaining_stock": product["stock"]
    }

