import joblib
import numpy as np
import pandas as pd
import os
from datetime import datetime
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


class DiabetesPredictionModel:
    """
    trains a LogisticRegression model,
    """

    def __init__(self):
        self.model_path = "diabetes_model.joblib"
        self.scaler_path = "diabetes_scaler.joblib"

        base_dir = os.path.dirname(os.path.abspath(__file__))
        self.data_path = os.path.join(base_dir, "data", "diabetes.csv")  # relative to script


        self.model = None
        self.scaler = None

        # Validate dataset presence immediately 
        if not os.path.exists(self.data_path):
            raise FileNotFoundError(
                f"Required dataset not found at '{self.data_path}'. "
                "Please place your diabetes CSV there and ensure columns match:\n"
                "['Pregnancies','Glucose','BloodPressure','SkinThickness',"
                "'Insulin','BMI','DiabetesPedigreeFunction','Age','Outcome']"
            )

    def generate_new_data(self, num_records=50):
        """
        Generate synthetic diabetes data and append to data/diabetes.csv.
        Intended to be invoked by an external scheduler like Celery.
        """
        if not os.path.exists(self.data_path):
            raise FileNotFoundError(f"Cannot generate new data because {self.data_path} is missing.")

        np.random.seed(int(datetime.now().timestamp()))

        new_data = []
        for _ in range(num_records):
            pregnancies = np.random.poisson(3)
            age = np.random.randint(21, 81)
            glucose = max(0, np.random.normal(120, 30))
            blood_pressure = max(0, np.random.normal(69, 19))
            skin_thickness = min(np.random.exponential(20), 99)
            insulin = min(np.random.exponential(79), 846)
            bmi = float(np.clip(np.random.normal(32, 8), 15, 67))
            diabetes_pedigree = min(np.random.exponential(0.5), 2.5)

            risk_score = (
                (glucose > 126) * 0.3
                + (bmi > 30) * 0.2
                + (age > 45) * 0.2
                + (blood_pressure > 80) * 0.1
                + (diabetes_pedigree > 0.5) * 0.2
            )

            outcome = 1 if (risk_score + np.random.random() * 0.3) > 0.5 else 0

            new_data.append([
                pregnancies, glucose, blood_pressure, skin_thickness,
                insulin, bmi, diabetes_pedigree, age, outcome
            ])

        columns = [
            "Pregnancies", "Glucose", "BloodPressure", "SkinThickness",
            "Insulin", "BMI", "DiabetesPedigreeFunction", "Age", "Outcome"
        ]
        new_df = pd.DataFrame(new_data, columns=columns)

        existing_df = pd.read_csv(self.data_path)
        combined_df = pd.concat([existing_df, new_df], ignore_index=True)
        combined_df.to_csv(self.data_path, index=False)

        logger.info(f"(Scheduler) Appended {num_records} records. New dataset size: {len(combined_df)}")
        return len(combined_df)

    def train_model(self):
        """
        Train LogisticRegression using data/diabetes.csv.
        """
        if not os.path.exists(self.data_path):
            raise FileNotFoundError(f"Dataset not found at {self.data_path} - cannot train.")

        print("Data path", self.data_path)
        df = pd.read_csv(self.data_path)

        # Basic preprocessing: replace zeros in certain columns with median (common practice)
        cols_with_zeros = ["Glucose", "BloodPressure", "SkinThickness", "Insulin", "BMI"]
        for col in cols_with_zeros:
            if col in df.columns:
                df[col] = df[col].replace(0, np.nan)
                df[col].fillna(df[col].median(), inplace=True)

        # Ensure required columns exist
        required_cols = ["Pregnancies", "Glucose", "BloodPressure", "SkinThickness",
                         "Insulin", "BMI", "DiabetesPedigreeFunction", "Age", "Outcome"]
        missing = [c for c in required_cols if c not in df.columns]
        if missing:
            raise ValueError(f"Dataset is missing required columns: {missing}")

        X = df.drop("Outcome", axis=1)
        y = df["Outcome"]

        # Guard: if target has only one class, training will fail; provide informative error
        if y.nunique() < 2:
            raise ValueError("Target 'Outcome' has fewer than 2 unique classes. Cannot train.")

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )

        self.scaler = StandardScaler()
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)

        self.model = LogisticRegression(max_iter=1000, solver="lbfgs")
        self.model.fit(X_train_scaled, y_train)

        y_pred = self.model.predict(X_test_scaled)
        accuracy = accuracy_score(y_test, y_pred)

        # persist artifacts
        joblib.dump(self.model, self.model_path)
        joblib.dump(self.scaler, self.scaler_path)

        logger.info(f"Model trained. Accuracy: {accuracy:.4f}. Training set size: {len(df)}")
        return {"accuracy": accuracy, "training_size": len(df), "timestamp": datetime.now().isoformat()}

    def predict(self, pregnancies, glucose, blood_pressure, skin_thickness, insulin, bmi, diabetes_pedigree, age):
        """
        Predict using the saved model. Will load artifacts from disk if not in memory.
        """
        if self.model is None:
            if os.path.exists(self.model_path):
                self.model = joblib.load(self.model_path)
            else:
                raise ValueError("Model not found. Please run train_model() first.")

        if self.scaler is None:
            if os.path.exists(self.scaler_path):
                self.scaler = joblib.load(self.scaler_path)
            else:
                raise ValueError("Scaler not found. Please run train_model() first.")

        input_data = np.array([[pregnancies, glucose, blood_pressure, skin_thickness,
                                insulin, bmi, diabetes_pedigree, age]])
        input_scaled = self.scaler.transform(input_data)

        pred = self.model.predict(input_scaled)[0]
        proba = self.model.predict_proba(input_scaled)[0]

        return {
            "prediction": int(pred),
            "probability_no_diabetes": float(proba[0]),
            "probability_diabetes": float(proba[1]),
            "risk_level": "High" if proba[1] > 0.7 else "Medium" if proba[1] > 0.3 else "Low",
        }

    def get_model_info(self):
        """Return metadata about model and dataset (if available)."""
        dataset_size = None
        if os.path.exists(self.data_path):
            dataset_size = len(pd.read_csv(self.data_path))

        model_exists = os.path.exists(self.model_path)
        last_modified = datetime.fromtimestamp(os.path.getmtime(self.model_path)).isoformat() if model_exists else None

        return {"model_trained": model_exists, "dataset_size": dataset_size, "last_modified": last_modified}

# python -c "
# from predict.ml_model import DiabetesPredictionModel
# model = DiabetesPredictionModel()
# result = model.train_model()
# print('Initial model trained successfully!')
# print(f'Model accuracy: {result[\"accuracy\"]:.4f}')
# "
