from django.urls import path
from . import views

urlpatterns = [
    # Web interface
    path('', views.predict_diabetes_view, name='predict_diabetes'),
    
    # API endpoints
    path('api/predict/', views.DiabetesPredictionAPI.as_view(), name='api_predict'),
    path('api/model-info/', views.ModelInfoAPI.as_view(), name='api_model_info'),
    path('api/train/', views.TrainModelAPI.as_view(), name='api_train_model'),
    path('api/generate-data/', views.GenerateDataAPI.as_view(), name='api_generate_data'),
    path('api/trigger-retraining/', views.TriggerRetrainingAPI.as_view(), name='api_trigger_retraining'),
]
