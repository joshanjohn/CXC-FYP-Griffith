from sklearn.metrics import confusion_matrix, classification_report
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

def generate_confusion(dataset, model, title: str, subtitle: str = ""):
    y_pred = []
    y_true = []

    # Collect predictions and true labels
    for images, labels in dataset:
        preds = model.predict(images, verbose=0)
        y_pred.extend(np.argmax(preds, axis=1))
        y_true.extend(np.argmax(labels, axis=1))

    # Confusion matrix
    cm = confusion_matrix(y_true, y_pred)

    # Get class names safely
    class_names = dataset.class_names if hasattr(dataset, "class_names") else [str(i) for i in range(cm.shape[0])]

    # Plot heatmap
    plt.figure(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Reds',
                xticklabels=class_names, yticklabels=class_names)
    plt.xlabel('Predicted')
    plt.ylabel('Actual')
    plt.title( f"{title}\n{subtitle}",)
    plt.show()

    # Classification report
    print(classification_report(y_true, y_pred, target_names=class_names))