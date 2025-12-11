# Pink Flag - Backend API

FastAPI backend service for the Pink Flag mobile app. Provides secure API proxy and credit management for sex offender registry searches.

## Overview

This backend serves as an intermediary between the Flutter mobile app and external APIs. It:

- **Credit Management**: Server-side credit validation, deduction, and refunds (single source of truth for ALL search types)
- **API Security**: Secures API keys (not exposed to mobile clients)
- **Data Normalization**: Normalizes data from multiple registry APIs
- **Automatic Refunds**: Refunds credits on API failures (503, 500, timeouts)
- **JWT Authentication**: Validates Supabase user sessions on all requests
- **FBI Integration**: Parallel FBI Most Wanted checks (free API)
- **Error Handling**: Graceful error handling with automatic retries

**Credit System (v1.1.11+)**:
- ✅ Name Search: Backend-only credit deduction (v1.1.10)
- ✅ Image Search: Backend-only credit deduction (v1.1.11)
- ✅ Phone Search: Backend-only credit deduction with Twilio Lookup API v2 (v1.1.13)

## Tech Stack

- **FastAPI**: Modern, fast web framework
- **Uvicorn**: ASGI server
- **httpx**: Async HTTP client
- **python-dotenv**: Environment variable management
- **Pydantic**: Data validation

## API Endpoints

### Health Check

```bash
GET /health
```

Returns server health status.

**Response:**
```json
{
  "status": "healthy"
}
```

### Root

```bash
GET /
```

Returns API information.

**Response:**
```json
{
  "message": "Safety App API",
  "version": "1.0.0",
  "status": "running"
}
```

### Search Test

```bash
GET /api/search/test
```

Tests search API connectivity.

**Response:**
```json
{
  "message": "Search API is working",
  "endpoints": {
    "POST /api/search/name": "Search by name with optional filters"
  }
}
```

### Search by Name

```bash
POST /api/search/name
Content-Type: application/json
Authorization: Bearer <supabase-jwt-token>
```

Searches offender registries by name with optional filters.

**IMPORTANT**: This endpoint handles credit deduction automatically. Do NOT deduct credits on client-side.
**Credit deduction flow fixed in v1.1.10 - client-side deduction removed.**

**Credit Flow:**
1. Validates JWT token → extracts user_id
2. Calls `deduct_credit_for_search` RPC (atomic transaction)
3. Performs external API search
4. On success: Updates search history with results
5. On failure: Calls `refund_credit_for_failed_search` RPC

**Request Body:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "555-1234",
  "zipCode": "94102",
  "age": "35",
  "state": "CA"
}
```

**Headers:**
```
Authorization: Bearer <supabase-access-token>
Content-Type: application/json
```

**Response:**
```json
[
  {
    "id": "123456",
    "fullName": "John Doe",
    "age": 45,
    "city": "San Francisco",
    "state": "CA",
    "offenseDescription": "Offense details",
    "registrationDate": "2020-01-15",
    "distance": 2.5,
    "address": "San Francisco, CA"
  }
]
```

**Error Response:**
```json
{
  "detail": "Error searching offender database: <error message>"
}
```

## Data Sources

### Primary: Offenders.io

- 900k+ offender records
- Updated daily
- Supports name/DOB/ZIP search
- Sign up: https://offenders.io

### Fallback: CrimeoMeter

- Name + ZIP code search
- Detailed fields including charges
- Sign up: https://crimeometer.com

### Development Mode

If no API keys are configured, the service returns mock data for testing:

```json
[
  {
    "id": "mock-1",
    "fullName": "John Doe",
    "age": 45,
    "city": "San Francisco",
    "state": "CA",
    "offenseDescription": "Mock offense - API key not configured",
    "registrationDate": "2020-01-15",
    "distance": null,
    "address": "San Francisco, CA"
  }
]
```

## Setup

### 1. Environment Variables

Create a `.env` file:

```bash
cp .env.example .env
```

Add your API keys:

```env
# Name Search API
OFFENDERS_IO_API_KEY=your_offenders_io_key
CRIMEOMETER_API_KEY=your_crimeometer_key  # Optional fallback

# Phone Lookup API (Twilio Lookup v2)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Image Search API
TINEYE_API_KEY=your_tineye_api_key_here

# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_JWT_SECRET=your_jwt_secret
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Server Config
PORT=8000
HOST=0.0.0.0
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Run Server

```bash
# Development
python main.py

# Production with Uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## Docker Deployment

### Build Image

```bash
docker build -t safety-app-backend .
```

### Run Container

```bash
docker run -d \
  --name safety-backend \
  -p 8000:8000 \
  --env-file .env \
  safety-app-backend
```

### Docker Compose

```bash
# From project root
docker-compose up -d
```

## Development

### Project Structure

```
backend/
├── main.py                 # FastAPI app & config
├── routers/
│   ├── __init__.py
│   └── search.py          # Search endpoints
├── services/
│   ├── __init__.py
│   └── offender_api.py    # External API integration
├── requirements.txt        # Python dependencies
├── Dockerfile             # Container definition
└── .env.example           # Environment template
```

### Adding New API Sources

1. Add API credentials to `.env.example`
2. Implement search method in `services/offender_api.py`
3. Add transformation logic for response format
4. Update fallback logic in `search_by_name()`

### Error Handling

The service implements multiple fallback layers:

1. Try Offenders.io API
2. On failure, try CrimeoMeter API
3. On all failures, return empty list
4. If no keys configured, return mock data

## CORS Configuration

Currently configured for development:

```python
allow_origins=["*"]  # Allow all origins
```

**For production**, update to specific origins:

```python
allow_origins=[
    "https://your-app-domain.com",
    "capacitor://localhost",  # For Capacitor apps
]
```

## Security

### API Key Storage

- Never commit `.env` files
- Use environment variables in production
- Rotate keys regularly
- Monitor API usage

### Rate Limiting

Not currently implemented. For production, consider:

- Redis-based rate limiting
- Per-IP request limits
- API key quotas

### HTTPS

- Use HTTPS in production
- Configure SSL certificates
- Use reverse proxy (nginx, Traefik)

## Testing

```bash
# Install dev dependencies
pip install pytest pytest-asyncio httpx

# Run tests (when implemented)
pytest

# Test with curl
curl -X POST http://localhost:8000/api/search/name \
  -H "Content-Type: application/json" \
  -d '{"firstName": "John", "lastName": "Doe"}'
```

## Monitoring

### Health Checks

The `/health` endpoint can be used for:

- Docker healthchecks
- Kubernetes liveness probes
- Uptime monitoring services

### Logging

Logs are written to stdout and include:

- API call attempts
- Error messages
- Search parameters (sanitized)

## Performance

### Optimization Tips

1. **Caching**: Implement Redis caching for frequent searches
2. **Connection Pooling**: Use persistent HTTP connections
3. **Async Operations**: Already using async/await
4. **Database**: Consider caching results in PostgreSQL

### Current Limitations

- No rate limiting
- No result caching
- Synchronous external API calls in sequence
- No load balancing

## Troubleshooting

### Port Already in Use

```bash
lsof -i :8000
kill -9 <PID>
```

### Module Not Found

```bash
pip install -r requirements.txt
```

### API Connection Timeout

Increase timeout in `offender_api.py`:

```python
response = await client.get(..., timeout=30.0)  # Increase from 10.0
```

### CORS Issues

Update `main.py` CORS middleware to include your frontend URL.

## License

MIT License - See LICENSE file for details

## Support

For issues and questions:
- GitHub Issues: https://github.com/bobbyburns1989/redflag/issues
- FastAPI Docs: https://fastapi.tiangolo.com
