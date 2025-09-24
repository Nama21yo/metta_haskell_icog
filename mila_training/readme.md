
# Diabetes Prediction System

A Django-based web application for predicting diabetes risk using a machine learning model, with Celery for background tasks and automated retraining.

## Setup

1. **Install dependencies**

```bash
pip install -r requirements.txt
```

2. **Run Redis**

```bash
docker run -d -p 6379:6379 redis:alpine
```

3. **Django setup**

```bash
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic
```

4. **Train initial model (run once)**

```bash
python -c "
from predict.ml_model import DiabetesPredictionModel
model = DiabetesPredictionModel()
result = model.train_model()
print('Initial model trained successfully!')
print(f'Model accuracy: {result[\"accuracy\"]:.4f}')
"
```

5. **Run Django development server**

```bash
python manage.py runserver
```

6. **Run Celery worker**

```bash
celery -A prediction worker --loglevel=info
```

7. **Run Celery Beat scheduler**

```bash
celery -A prediction beat --loglevel=info
```

> Alternatively, run worker and beat together:

```bash
celery -A prediction worker --beat --loglevel=info
```

## Access

* Web Interface: [http://127.0.0.1:8000/predict/](http://127.0.0.1:8000/predict/)
* Swagger API Docs: [http://127.0.0.1:8000/swagger/](http://127.0.0.1:8000/swagger/)
* ReDoc API Docs: [http://127.0.0.1:8000/redoc/](http://127.0.0.1:8000/redoc/)

<img width="1920" height="1276" alt="image" src="https://github.com/user-attachments/assets/a9c2a4ad-2673-405e-a2d9-f92395ed9a7b" />

## API Testing

* **Get model info**

```bash
curl -X GET http://127.0.0.1:8000/predict/api/model-info/
```

* **Predict diabetes**

```bash
curl -X POST http://127.0.0.1:8000/predict/api/predict/ \
  -H "Content-Type: application/json" \
  -d '{
    "pregnancies": 6,
    "glucose": 148,
    "blood_pressure": 72,
    "skin_thickness": 35,
    "insulin": 0,
    "bmi": 33.6,
    "diabetes_pedigree": 0.627,
    "age": 50
  }'
```

## Notes

* Celery handles scheduled model retraining (check logs for automated retraining).
* For testing, retraining is scheduled every 1 minute.

