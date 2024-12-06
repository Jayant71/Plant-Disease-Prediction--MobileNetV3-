# Plant Disease Prediction Using MobileNetV3

This repository contains a plant disease prediction system built using the MobileNetV3 architecture. The project includes the training model, a sample Android application for prediction, and supporting materials.

## Features

- **MobileNetV3 Implementation**: A lightweight, efficient neural network for plant disease detection.
- **Sample App**: An Android app (`sample_app.apk`) that allows users to upload plant images and get predictions.
- **Trained Models**: Pretrained models for inference.
- **Notebook**: `plant_mobilenet.ipynb` for training and testing.
- **Dataset**: Plant village dataset [text](https://data.mendeley.com/datasets/tywbtsjrjv/1)

## Directory Structure

- `Models/`: Contains pretrained models.
- `Plant Disease Prediction Sample App/`: Android project files.
- `images/`: Sample App Screenshots.
- `plant_mobilenet.ipynb`: Training and testing notebook.
- `sample_app.apk`: Sample Android app for disease prediction.

## Getting Started

### Prerequisites

- Python 3.x
- TensorFlow/Keras
- Android Studio/ VsCode

### Training

Run the notebook `plant_mobilenet.ipynb` to train the MobileNetV3 model on your dataset.

### App Usage

1. Install `sample_app.apk` on your Android device.
2. Open the app and upload an image of a plant leaf.
3. View the predicted disease and confidence score.

## Contributing

Feel free to open issues or submit pull requests for improvements.

## License

This project is licensed under [MIT License](LICENSE).

---
