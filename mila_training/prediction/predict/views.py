from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .ml_model import DiabetesPredictionModel
from .serializers import (
    DiabetesPredictionInputSerializer, 
    DiabetesPredictionOutputSerializer,
    ModelInfoSerializer,
    TrainingResultSerializer
)
from .tasks import retrain_diabetes_model, generate_sample_data
import logging

logger = logging.getLogger(__name__)

def predict_diabetes_view(request):
    """Web form view for diabetes prediction"""
    prediction_result = None
    error_message = None
    
    if request.method == 'POST':
        try:
            pregnancies = int(request.POST.get('pregnancies', 0))
            glucose = float(request.POST.get('glucose', 0))
            blood_pressure = float(request.POST.get('blood_pressure', 0))
            skin_thickness = float(request.POST.get('skin_thickness', 0))
            insulin = float(request.POST.get('insulin', 0))
            bmi = float(request.POST.get('bmi', 0))
            diabetes_pedigree = float(request.POST.get('diabetes_pedigree', 0))
            age = int(request.POST.get('age', 0))
            
            predictor = DiabetesPredictionModel()
            prediction_result = predictor.predict(
                pregnancies, glucose, blood_pressure, skin_thickness,
                insulin, bmi, diabetes_pedigree, age
            )
            
        except (ValueError, TypeError) as e:
            error_message = "Invalid input. Please check your values."
            logger.error(f"Input validation error: {str(e)}")
        except Exception as e:
            error_message = "Prediction failed. Please try again."
            logger.error(f"Prediction error: {str(e)}")
    
    # Get model info for display
    try:
        predictor = DiabetesPredictionModel()
        model_info = predictor.get_model_info()
    except Exception as e:
        model_info = {'model_trained': False, 'dataset_size': 0}
        logger.error(f"Error getting model info: {str(e)}")
    
    return render(request, 'predict_diabetes.html', {
        'prediction_result': prediction_result,
        'error_message': error_message,
        'model_info': model_info
    })

class DiabetesPredictionAPI(APIView):
    """
    API endpoint for diabetes prediction
    """
    
    @swagger_auto_schema(
        operation_description="Predict diabetes based on patient data",
        request_body=DiabetesPredictionInputSerializer,
        responses={
            200: DiabetesPredictionOutputSerializer,
            400: "Invalid input data",
            500: "Prediction failed"
        },
        tags=['Diabetes Prediction']
    )
    def post(self, request):
        serializer = DiabetesPredictionInputSerializer(data=request.data)
        
        if serializer.is_valid():
            try:
                data = serializer.validated_data
                predictor = DiabetesPredictionModel()
                
                result = predictor.predict(
                    pregnancies=data['pregnancies'],
                    glucose=data['glucose'],
                    blood_pressure=data['blood_pressure'],
                    skin_thickness=data['skin_thickness'],
                    insulin=data['insulin'],
                    bmi=data['bmi'],
                    diabetes_pedigree=data['diabetes_pedigree'],
                    age=data['age']
                )
                
                return Response(result, status=status.HTTP_200_OK)
                
            except Exception as e:
                logger.error(f"API prediction error: {str(e)}")
                return Response(
                    {'error': 'Prediction failed. Please try again.'},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ModelInfoAPI(APIView):
    """
    API endpoint to get model information
    """
    
    @swagger_auto_schema(
        operation_description="Get information about the current diabetes prediction model",
        responses={
            200: ModelInfoSerializer,
            500: "Failed to get model info"
        },
        tags=['Model Management']
    )
    def get(self, request):
        try:
            predictor = DiabetesPredictionModel()
            model_info = predictor.get_model_info()
            return Response(model_info, status=status.HTTP_200_OK)
        except Exception as e:
            logger.error(f"Error getting model info: {str(e)}")
            return Response(
                {'error': 'Failed to get model information'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class TrainModelAPI(APIView):
    """
    API endpoint to manually trigger model training
    """
    
    @swagger_auto_schema(
        operation_description="Manually trigger model training with current dataset",
        responses={
            200: TrainingResultSerializer,
            500: "Training failed"
        },
        tags=['Model Management']
    )
    def post(self, request):
        try:
            predictor = DiabetesPredictionModel()
            result = predictor.train_model()
            
            response_data = {
                'success': True,
                'message': 'Model trained successfully',
                'accuracy': result['accuracy'],
                'training_size': result['training_size'],
                'timestamp': result['timestamp']
            }
            
            return Response(response_data, status=status.HTTP_200_OK)
            
        except Exception as e:
            logger.error(f"Manual training error: {str(e)}")
            return Response(
                {
                    'success': False,
                    'message': f'Training failed: {str(e)}',
                    'accuracy': None,
                    'training_size': None,
                    'timestamp': None
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class GenerateDataAPI(APIView):
    """
    API endpoint to generate sample data
    """
    
    @swagger_auto_schema(
        operation_description="Generate new synthetic data for model training",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'num_records': openapi.Schema(
                    type=openapi.TYPE_INTEGER,
                    description='Number of records to generate',
                    default=50
                )
            }
        ),
        responses={
            200: "Data generated successfully",
            500: "Data generation failed"
        },
        tags=['Data Management']
    )
    def post(self, request):
        try:
            num_records = request.data.get('num_records', 50)
            
            # Trigger async task
            task = generate_sample_data.delay()
            
            return Response({
                'success': True,
                'message': f'Data generation task initiated',
                'task_id': task.id
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            logger.error(f"Data generation error: {str(e)}")
            return Response(
                {'success': False, 'message': f'Data generation failed: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class TriggerRetrainingAPI(APIView):
    """
    API endpoint to manually trigger model retraining
    """
    
    @swagger_auto_schema(
        operation_description="Manually trigger model retraining (generates new data and retrains)",
        responses={
            200: "Retraining task initiated",
            500: "Failed to initiate retraining"
        },
        tags=['Model Management']
    )
    def post(self, request):
        try:
            # Trigger async retraining task
            task = retrain_diabetes_model.delay()
            
            return Response({
                'success': True,
                'message': 'Model retraining task initiated',
                'task_id': task.id
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            logger.error(f"Retraining trigger error: {str(e)}")
            return Response(
                {'success': False, 'message': f'Failed to initiate retraining: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
