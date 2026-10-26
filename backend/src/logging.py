"""
Author : Joshan John
Student Number : 3092883
"""
    
import logging
from logging.handlers import RotatingFileHandler
from pathlib import Path
from enum import StrEnum
from src.constants.constants import APP_LOG_LEVEL, APP_LOGGER_NAME


# --- Constants ---
LOG_DIR =".logs"
LOG_FILE_NAME = "app.log"
LOG_FORMAT_DEFAULT = "[%(asctime)s] %(levelname)s - %(name)s - %(message)s"
LOG_FORMAT_DEBUG = "[%(asctime)s] %(levelname)s - %(name)s - %(pathname)s:%(funcName)s:%(lineno)d - %(message)s"

class LogLevels(StrEnum): 
    info = "INFO"
    warn = "WARN"
    error = "ERROR"
    debug = "DEBUG"


def configure_logging(log_level: str = APP_LOG_LEVEL):
    """
    Configures robust logging with both Console and Rotating File output.
    Creates a .logs directory at the project root.
    """
    # Normalize Log Level
    numeric_level = getattr(logging, str(log_level).upper(), logging.INFO)
    
    # Ensure Log Directory exists
    log_path = Path(LOG_DIR)
    log_path.mkdir(exist_ok=True)
    
    # Define Formatter
    formatter = logging.Formatter(
        LOG_FORMAT_DEBUG if log_level.upper() == "DEBUG" else LOG_FORMAT_DEFAULT
    )

    #Setup ROOT Logger
    root_logger = logging.getLogger()
    root_logger.setLevel(numeric_level)
    
    # Clear existing handlers to prevent duplicate logs 
    if root_logger.hasHandlers():
        root_logger.handlers.clear()

    # Add Console Handler 
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)

    # Add File Handler 
    file_path = log_path / LOG_FILE_NAME
    file_handler = RotatingFileHandler(
        file_path, 
        maxBytes=5 * 1024 * 1024,  # 5 MB
        backupCount=5,
        encoding="utf-8"
    )
    file_handler.setFormatter(formatter)
    root_logger.addHandler(file_handler)

    # Log initial configuration
    logging.getLogger(APP_LOGGER_NAME).info(
        "Logging initialized at level %s. Logs saved to %s",
        log_level,
        file_path,
    )
    return logging


def get_logger(name: str | None = None):
    logger_name = f"{APP_LOGGER_NAME}.{name}" if name else APP_LOGGER_NAME
    return logging.getLogger(logger_name)
