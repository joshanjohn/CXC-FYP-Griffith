from sklearn.preprocessing import label_binarize
from sklearn.metrics import roc_curve, auc
import numpy as np
import matplotlib.pyplot as plt

def generate_roc_curve(dataset, model, title: str):
    class_names = dataset.class_names
    y_pred_prob = []
    y_true = []

    for images, labels in dataset:
        preds = model.predict(images, verbose=0)

        y_pred_prob.extend(preds)  # keep full probability vector
        y_true.extend(np.argmax(labels, axis=1))  # keep true class indices

    y_pred_prob = np.array(y_pred_prob)
    y_true = np.array(y_true)

    n_classes = y_pred_prob.shape[1]

    # Convert labels to one-hot format
    y_true_bin = label_binarize(y_true, classes=range(n_classes))

    plt.figure(figsize=(8, 6))

    for i in range(n_classes):
        fpr, tpr, _ = roc_curve(y_true_bin[:, i], y_pred_prob[:, i])
        roc_auc = auc(fpr, tpr)

        plt.plot(fpr, tpr, label=f"{class_names[i]} (accuracy = {roc_auc:.2f})")

    # Random baseline
    plt.plot([0, 1], [0, 1], linestyle='--')

    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.title(title)
    plt.legend()
    plt.show()