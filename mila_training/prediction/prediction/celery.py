import os
from celery import Celery
from django.conf import settings

# Set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'prediction.settings')

app = Celery('prediction')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Load task modules from all registered Django apps.
app.autodiscover_tasks()

# Celery Beat Schedule
app.conf.beat_schedule = {
    'retrain-model-every-minute': {  # For testing - change to 24 hours in production
        'task': 'predict.tasks.retrain_diabetes_model',
        'schedule': 60.0,  # Every 60 seconds for testing
        # For production, use: 'schedule': 24 * 60 * 60.0,  # 24 hours
    },
}

app.conf.timezone = 'UTC'

@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')
