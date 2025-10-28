from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
async def health():
    return {"status": "Ok"}

@app.get("/")
async def root():
    return {"message": "HEllo from User Application"}

@app.get("/users/{user_id}/")
async def get_user_deliveries():
    return {
            "deliveries": [{"id": 1, "date": "2025-05-11"}, {"id": 2, "date": "2025-06-22"}]
        }

