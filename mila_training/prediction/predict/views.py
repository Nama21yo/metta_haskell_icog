from django.shortcuts import render
from .ml_model import HousePricePredictor

def predict_price(request):
    prediction = None
    if request.method == 'POST':
        try:
            size = float(request.POST.get('size'))
            bedrooms = int(request.POST.get('bedrooms'))
            age = float(request.POST.get('age'))
            
            predictor = HousePricePredictor()
            prediction = predictor.predict(size, bedrooms, age)
        except (ValueError, TypeError):
            prediction = "Invalid input"
    
    return render(request, 'predict.html', {'prediction': prediction})
