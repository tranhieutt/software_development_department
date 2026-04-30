---
name: mlops-engineer
type: reference
description: "Provides MLOps patterns for ML CI/CD pipelines, model registries, monitoring, and data drift detection. Use when setting up ML infrastructure or when the user mentions MLOps, model deployment, ML pipeline, or model monitoring."
paths: ["**/*.py", "**/Dockerfile", "**/requirements*.txt", "**/mlflow*", "**/*.yaml"]
effort: 4
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
when_to_use: "When building ML pipelines, experiment tracking systems, or model registries with MLflow or Kubeflow"
---

# MLOps Engineer

## Tool selection matrix

| Need | Tool | When to use |
|---|---|---|
| Experiment tracking | MLflow | Open-source, self-hosted |
| Experiment tracking | W&B | Cloud, rich visualization |
| Pipeline orchestration | Kubeflow | Kubernetes-native |
| Pipeline orchestration | Prefect | Python-first, dynamic |
| Data version control | DVC | Git-based datasets & models |
| Feature store | Feast | Open-source, online+offline |
| Model serving | KServe | K8s serverless inference |
| Model serving | SageMaker Endpoints | AWS managed |
| Monitoring / drift | Evidently | Open-source, alerting |
| CI/CD for ML | GitHub Actions + DVC | Lightweight |

## MLflow: experiment tracking + model registry

```python
import mlflow
import mlflow.sklearn

mlflow.set_tracking_uri("http://mlflow-server:5000")
mlflow.set_experiment("model-training")

with mlflow.start_run():
    # Log params
    mlflow.log_param("n_estimators", 100)
    mlflow.log_param("max_depth", 5)

    # Train
    model = train(X_train, y_train)
    metrics = evaluate(model, X_test, y_test)

    # Log metrics
    mlflow.log_metric("accuracy", metrics["accuracy"])
    mlflow.log_metric("f1", metrics["f1"])

    # Log model + register
    mlflow.sklearn.log_model(
        model, "model",
        registered_model_name="fraud-detector",
    )

# Promote to production via API
client = mlflow.tracking.MlflowClient()
client.transition_model_version_stage(
    name="fraud-detector", version=3, stage="Production"
)
```

## GitHub Actions: ML CI/CD pipeline

```yaml
name: ML Pipeline
on:
  push:
    paths: ["data/**", "src/**", "params.yaml"]

jobs:
  train-and-validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: iterative/setup-dvc@v1

      - name: Pull data
        run: dvc pull

      - name: Run training pipeline
        run: dvc repro

      - name: Validate model metrics
        run: |
          python scripts/check_metrics.py \
            --min-accuracy 0.92 \
            --min-f1 0.88

      - name: Register model if metrics pass
        if: github.ref == 'refs/heads/main'
        run: python scripts/register_model.py
        env:
          MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_URI }}
```

## Model serving: FastAPI + model registry

```python
from fastapi import FastAPI
import mlflow.pyfunc
import os

app = FastAPI()
MODEL_NAME = os.environ["MODEL_NAME"]
MODEL_STAGE = os.environ.get("MODEL_STAGE", "Production")

# Load once on startup (cold start cost paid once)
model = mlflow.pyfunc.load_model(f"models:/{MODEL_NAME}/{MODEL_STAGE}")

@app.post("/predict")
async def predict(features: dict):
    import pandas as pd
    df = pd.DataFrame([features])
    predictions = model.predict(df)
    return {"predictions": predictions.tolist()}

@app.get("/health")
async def health():
    return {"status": "healthy", "model": MODEL_NAME, "stage": MODEL_STAGE}
```

## Data drift monitoring (Evidently)

```python
from evidently.report import Report
from evidently.metric_preset import DataDriftPreset
import pandas as pd

def check_drift(reference_data: pd.DataFrame, production_data: pd.DataFrame) -> dict:
    report = Report(metrics=[DataDriftPreset()])
    report.run(reference_data=reference_data, current_data=production_data)
    result = report.as_dict()

    drift_detected = result["metrics"][0]["result"]["dataset_drift"]
    drifted_features = [
        f for f, v in result["metrics"][0]["result"]["drift_by_columns"].items()
        if v["drift_detected"]
    ]
    return {"drift_detected": drift_detected, "drifted_features": drifted_features}

# Trigger retraining if drift detected
if check_drift(ref, prod)["drift_detected"]:
    trigger_retraining_pipeline()
```

## Critical rules (non-obvious)

- **Separate training and serving environments** — training deps (torch, cuda) bloat serving images by 10x; use multi-stage Dockerfiles or separate images
- **Pin all dependencies** — ML stack changes break reproducibility; pin Python + all packages, freeze with `pip freeze` not just `requirements.txt`
- **Log everything before filtering** — never decide what metrics to log during training; log all, filter in dashboards
- **Separate model config from code** — `params.yaml` (DVC) or `config.yaml` for hyperparameters; never hardcode in training scripts
- **Shadow mode before cutover** — run new model version in parallel (shadow traffic), compare outputs before switching production

## DVC pipeline (dvc.yaml)

```yaml
stages:
  preprocess:
    cmd: python src/preprocess.py
    deps: [src/preprocess.py, data/raw/]
    outs: [data/processed/]
    params: [params.yaml:preprocess]

  train:
    cmd: python src/train.py
    deps: [src/train.py, data/processed/]
    outs: [models/model.pkl]
    params: [params.yaml:train]
    metrics: [metrics/train.json]

  evaluate:
    cmd: python src/evaluate.py
    deps: [src/evaluate.py, models/model.pkl, data/processed/]
    metrics: [metrics/eval.json]
```
