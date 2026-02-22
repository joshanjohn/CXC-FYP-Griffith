import tensorflow as tf
import os

# Set log level to see initialization errors
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '0' 

print(f"TensorFlow Version: {tf.__version__}")

# Explicitly check for the 'PluggableDevice' (Metal)
devices = tf.config.list_physical_devices()
print(f"All Devices: {devices}")

gpu_devices = tf.config.list_physical_devices('GPU')
print("GPU = ",gpu_devices)


if gpu_devices:
    print("✅ SUCCESS: M3 GPU FOUND!")
    for dev in gpu_devices:
        print(f" - {dev}")
    
    # Test a small calculation on GPU
    with tf.device('/GPU:0'):
        a = tf.constant([[1.0, 2.0], [3.0, 4.0]])
        b = tf.constant([[1.0, 1.0], [0.0, 1.0]])
        c = tf.matmul(a, b)
        print("GPU Calculation Result:", c.numpy()[0][0])
else:
    print("❌ GPU NOT FOUND.")
    print("Check: Did 'uv pip list' show 'tensorflow-metal'?")