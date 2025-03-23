import json
from mangum import Mangum
from app.main import app

# Mangum adapter for AWS Lambda
handler = Mangum(app)