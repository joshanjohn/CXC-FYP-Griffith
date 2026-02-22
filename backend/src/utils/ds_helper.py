import os
import tensorflow as tf
import numpy as np
import polars as pl
import matplotlib.pyplot as plt
from pathlib import Path
from tabulate import tabulate

def get_dataset_distribution(dir_paths: list[str]):
    class_names = sorted([
        f.name for f in Path(dir_paths[0]).iterdir() 
        if f.is_dir()
    ])

    result = {}

    for dir_path in dir_paths:
        ds_path = Path(dir_path)
        ds_type = ds_path.name
        result[ds_type] = {}

        for class_name in class_names:
            class_path = ds_path / class_name
            if class_path.exists():
                result[ds_type][class_name] = count_images_in_folder(str(class_path))
            else:
                result[ds_type][class_name] = 0

    # Dynamic Table Formatting
    # Create headers: ["Dataset", "Class A", "Class B", ..., "Total"]
    headers = ["Dataset"] + [name.capitalize() for name in class_names] + ["Total"]
    rows = []

    for split, classes in result.items():
        # Create row: [Split Name, Count1, Count2, ..., Sum]
        row_counts = [classes[name] for name in class_names]
        total = sum(row_counts)
        
        rows.append([split.capitalize()] + row_counts + [total])

    print(tabulate(rows, headers=headers, tablefmt="fancy_grid"))

    return result



def count_images_in_folder(path_str: str) -> int:
    with os.scandir(path_str) as entries:
        return sum(1 for entry in entries if entry.is_file())



if __name__ == "__main__": 
    get_dataset_distribution(
        [
           "/Users/joshan/Documents/final-year-project/dataset/data02/train",
            "/Users/joshan/Documents/final-year-project/dataset/data02/test",
            "/Users/joshan/Documents/final-year-project/dataset/data02/val"
        ]
    )


    