from src.registry.model.model_info import MODEL_INFO
from src.registry.model.model_names import AVAILABLE_MODELS, DEFAULT_MODEL_ALIAS
from src.logging import get_logger

logger = get_logger(__name__)

class ModelService:
    def get_available_models(self):
        """
        function to return a list of available model aliases.
        """
        ordered_aliases = [DEFAULT_MODEL_ALIAS]
        ordered_aliases.extend(
            alias for alias in AVAILABLE_MODELS.keys() if alias != DEFAULT_MODEL_ALIAS
        )
        return ordered_aliases

    def get_models_info(self):
        """
        function to return detailed model metadata for frontend docs.
        """
        models_info = []
        for model_alias in self.get_available_models():
            model_info = MODEL_INFO.get(model_alias)
            if model_info is None:
                continue

            models_info.append(
                {
                    **model_info,
                    "alias": model_alias,
                    "is_default": model_alias == DEFAULT_MODEL_ALIAS,
                }
            )

        logger.debug(f"Resolved {len(models_info)} model info entries")
        return models_info
