import cv2
import numpy as np
import pandas as pd
import mediapipe as mp
import joblib

model_path = "model.pkl"
image_path = "sample.jpg"
face_labels = ["정과", "기과", "신과", "혈과"]
sex = 0  # 0 = 남자, 1 = 여자

# 1. Capture image from webcam
cap = cv2.VideoCapture(0)
ret, frame = cap.read()
cap.release()

if not ret:
    raise Exception("Webcam capture failed")
cv2.imwrite(image_path, frame)

# 2. Load image and detect face
mp_face = mp.solutions.face_detection
detector = mp_face.FaceDetection(model_selection=1, min_detection_confidence=0.5)

rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
results = detector.process(rgb_frame)

if not results.detections:
    raise Exception("No face detected")

# 3. Get bounding box of first detected face
box = results.detections[0].location_data.relative_bounding_box
h, w, _ = frame.shape
x, y = int(box.xmin * w), int(box.ymin * h)
width, height = int(box.width * w), int(box.height * h)

# 4. Feature engineering
ratio_hw = height / width
d = np.sqrt((width / 2) ** 2 + (height / 2) ** 2)
r = height / 2
ratio_dr = d / r

face_rect = width * height
face_trep = ((width + width * 0.3) * height) / 2
face_circle = np.pi * (height / 2) ** 2
face_ellipse = np.pi * (width / 2) * (height / 2)
face_origin = face_ellipse  # used for normalization

ratio_or = face_rect / face_origin
ratio_ot = face_trep / face_origin
ratio_oc = face_circle / face_origin
ratio_oe = face_ellipse / face_origin

# 5. Build model input
df = pd.DataFrame([{
    "ratio_hw": ratio_hw,
    "ratio_dr": ratio_dr,
    "ratio_or": ratio_or,
    "ratio_ot": ratio_ot,
    "ratio_oc": ratio_oc,
    "ratio_oe": ratio_oe,
    "sex": sex
}])

# 6. Load model and predict
model = joblib.load(model_path)
probs = model.predict_proba(df)[0]

results_df = pd.DataFrame({
    "label": face_labels,
    "probability": probs
}).sort_values("probability", ascending=False)

print(results_df)
results_df.to_csv("face_result.csv", index=False)