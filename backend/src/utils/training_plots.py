import matplotlib.pyplot as plt


def plot_train_accuracy(history) -> None:
    if not history: 
        raise TypeError("Training history not passed")
    # Plot accuracy
    plt.figure(figsize=(8, 5))

    plt.plot(history.history['accuracy'], label='Training Accuracy')
    plt.plot(history.history['val_accuracy'], label='Validation Accuracy')

    plt.xlabel('Epoch')
    plt.ylabel('Accuracy')
    plt.title('Training vs Validation Accuracy')
    plt.legend()

    plt.show()


def plot_train_loss(history) -> None: 
    if not history: 
        raise TypeError("Training history not passed")
    
    # Plot loss
    plt.figure(figsize=(8, 5))

    plt.plot(history.history['loss'], label='Training Loss')
    plt.plot(history.history['val_loss'], label='Validation Loss')

    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.title('Training vs Validation Loss')
    plt.legend()

    plt.show()