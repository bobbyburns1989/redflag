from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import os

from routers import search, image_search, phone_lookup

# Load environment variables
load_dotenv()

# Initialize rate limiter
# This limits requests per IP address to prevent abuse
limiter = Limiter(key_func=get_remote_address)

app = FastAPI(
    title="Pink Flag API",
    description="Backend API for Pink Flag - Women's Safety App",
    version="2.0.0",  # Bumped version for security update
    docs_url="/docs",  # Swagger UI
    redoc_url="/redoc",  # ReDoc UI
)

# Add rate limiter to app state
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Configure CORS - Locked down for production security
# Only allow requests from our own backend and iOS app (if using deep links)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://pink-flag-api.fly.dev",  # Production backend
        "capacitor://localhost",           # iOS WebView (if used)
        "ionic://localhost",               # Ionic (if used)
        "http://localhost:8000",           # Local development
        "http://127.0.0.1:8000",           # Local development alternative
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST"],  # Only allow necessary HTTP methods
    allow_headers=["Content-Type", "Authorization"],  # Only necessary headers
)

# Include routers
app.include_router(search.router, prefix="/api", tags=["search"])
app.include_router(image_search.router, prefix="/api", tags=["image-search"])
app.include_router(phone_lookup.router, prefix="/api", tags=["phone-lookup"])

@app.get("/")
async def root():
    return {
        "message": "Safety App API",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
