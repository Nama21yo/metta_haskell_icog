from rest_framework import serializers

class DiabetesPredictionInputSerializer(serializers.Serializer):
    pregnancies = serializers.IntegerField(
        min_value=0, 
        max_value=20,
        help_text="Number of pregnancies"
    )
    glucose = serializers.FloatField(
        min_value=0, 
        max_value=300,
        help_text="Plasma glucose concentration (mg/dL)"
    )
    blood_pressure = serializers.FloatField(
        min_value=0, 
        max_value=200,
        help_text="Diastolic blood pressure (mm Hg)"
    )
    skin_thickness = serializers.FloatField(
        min_value=0, 
        max_value=100,
        help_text="Triceps skin fold thickness (mm)"
    )
    insulin = serializers.FloatField(
        min_value=0, 
        max_value=900,
        help_text="2-Hour serum insulin (mu U/ml)"
    )
    bmi = serializers.FloatField(
        min_value=10, 
        max_value=70,
        help_text="Body mass index (weight in kg/(height in m)^2)"
    )
    diabetes_pedigree = serializers.FloatField(
        min_value=0, 
        max_value=3,
        help_text="Diabetes pedigree function"
    )
    age = serializers.IntegerField(
        min_value=18, 
        max_value=120,
        help_text="Age in years"
    )

class DiabetesPredictionOutputSerializer(serializers.Serializer):
    prediction = serializers.IntegerField(help_text="Prediction result (0: No diabetes, 1: Diabetes)")
    probability_no_diabetes = serializers.FloatField(help_text="Probability of not having diabetes")
    probability_diabetes = serializers.FloatField(help_text="Probability of having diabetes")
    risk_level = serializers.CharField(help_text="Risk level (Low, Medium, High)")

class ModelInfoSerializer(serializers.Serializer):
    model_trained = serializers.BooleanField(help_text="Whether the model is trained")
    dataset_size = serializers.IntegerField(help_text="Current dataset size")
    last_modified = serializers.CharField(help_text="Last model modification time")

class TrainingResultSerializer(serializers.Serializer):
    success = serializers.BooleanField(help_text="Whether training was successful")
    message = serializers.CharField(help_text="Training result message")
    accuracy = serializers.FloatField(help_text="Model accuracy")
    training_size = serializers.IntegerField(help_text="Training dataset size")
    timestamp = serializers.CharField(help_text="Training timestamp")
