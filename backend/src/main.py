import streamlit as st
import tensorflow as tf
import numpy as np
import pandas as pd
from PIL import Image
from src.constants.model_names import  CXC104



CLASS_NAMES = ['NORMAL', 'PNEUMONIA', 'TUBERCULOSIS', 'UNKNOWN']
IMG_SIZE = (224, 224)


@st.cache_resource
def load_classification_model(model_path):
    try:
        return tf.keras.models.load_model(model_path)
    except Exception as e:
        st.error(f"Error loading model from {model_path}: {e}")
        return None

def upload_img_preprocessing(pil_image, target_size=IMG_SIZE):
    if pil_image.mode != "RGB":
        pil_image = pil_image.convert("RGB")
    
    img = pil_image.resize(target_size)
    img_array = tf.keras.preprocessing.image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    
    return img_array

def get_prediction(model, processed_image):
    preds = model.predict(processed_image)
    print("\n\n\nPRED",preds)
    # preds will be something like [[0.1, 0.7, 0.2]]
    class_idx = np.argmax(preds, axis=1)[0]
    confidence = np.max(preds)
    return class_idx, confidence, preds[0]


def render_results_column(uploaded_file, pil_image, model):
    st.header("Diagnosis Results")
    
    if uploaded_file and pil_image:
        with st.spinner("Analyzing Chest X-ray..."):
            processed_data = upload_img_preprocessing(pil_image)
            idx, conf, raw_preds = get_prediction(model, processed_data)
            
            label = CLASS_NAMES[idx]
            
            # Highlight Prediction
            if label == 'NORMAL':
                st.success(f"Primary Prediction: **{label}**")
            else:
                st.error(f"Primary Prediction: **{label} Detected**")

            st.divider()

            # Confidence Metrics for all 3 classes
            st.subheader("Confidence Breakdown grpah")
            m_col1, m_col2, m_col3 = st.columns(3)
            
            m_col1.metric(CLASS_NAMES[0], f"{raw_preds[0]:.2%}")
            m_col2.metric(CLASS_NAMES[1], f"{raw_preds[1]:.2%}")
            m_col3.metric(CLASS_NAMES[2], f"{raw_preds[2]:.2%}")

            st.divider()

            # Probability Distribution chart
            st.subheader("Probability Distribution")
            chart_data = pd.DataFrame({
                'Condition': CLASS_NAMES,
                'Confidence': [float(p) for p in raw_preds]
            })
            st.bar_chart(chart_data.set_index('Condition'))
            
    else:
        st.info("Upload a chest X-ray to start analysis.")

def render_upload_column():
    st.header("Upload Image")
    uploaded_file = st.file_uploader("Select a Chest X-ray", type=["jpg", "png", "jpeg"])
    
    print("FILE: ", uploaded_file)
    if uploaded_file:
        image = Image.open(uploaded_file)
        st.image(image, caption="Uploaded X-ray Preview", use_container_width=True)
        return uploaded_file, image
    return None, None


def main():
    st.set_page_config(layout="wide", page_title="CXC model testing UI")
    st.title("CXC Model testing UI")
    st.markdown("---")
    
    model = load_classification_model(CXC104)
    
    # Create the layout: Left (Results), Right (Upload)
    col1, col2 = st.columns([1, 1], gap="large")
    
    with col2:
        file, image_obj = render_upload_column()
        
    with col1:
        if model is not None:
            render_results_column(file, image_obj, model)
        else:
            st.warning("Model failed to load.")

if __name__ == "__main__":
    main()