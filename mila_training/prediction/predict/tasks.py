from celery import shared_task
from .ml_model import DiabetesPredictionModel
import logging

logger = logging.getLogger(__name__)

@shared_task
def retrain_diabetes_model():
    """
    Scheduled task to retrain the diabetes prediction model
    """
    try:
        logger.info("Starting scheduled model retraining...")
        
        # Initialize the model
        model = DiabetesPredictionModel()
        
        # Generate new synthetic data
        new_records_count = model.generate_new_data(num_records=50)
        
        # Retrain the model
        training_result = model.train_model()
        
        logger.info(f"Model retraining completed successfully")
        logger.info(f"New dataset size: {training_result['training_size']}")
        logger.info(f"Model accuracy: {training_result['accuracy']:.4f}")
        
        return {
            'success': True,
            'message': 'Model retrained successfully',
            'training_result': training_result,
            'new_records_added': 50
        }
        
    except Exception as e:
        logger.error(f"Error in scheduled retraining: {str(e)}")
        return {
            'success': False,
            'message': f'Retraining failed: {str(e)}'
        }

@shared_task
def generate_sample_data():
    """
    Task to generate sample data for testing
    """
    try:
        model = DiabetesPredictionModel()
        new_size = model.generate_new_data(num_records=25)
        
        return {
            'success': True,
            'message': f'Generated sample data. New dataset size: {new_size}'
        }
    except Exception as e:
        logger.error(f"Error generating sample data: {str(e)}")
        return {
            'success': False,
            'message': f'Failed to generate data: {str(e)}'
        }
