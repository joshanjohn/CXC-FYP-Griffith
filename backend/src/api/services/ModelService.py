from src.registry.model.model_info import MODEL_INFO
from src.registry.model.model_names import AVAILABLE_MODELS, DEFAULT_MODEL_ALIAS
from src.logging import get_logger

logger = get_logger(__name__)


class ModelService:
    def get_available_models(self) -> list[str]:
        """
        Return available model aliases with the default model first.
        """
        # Start list with default model alias
        ordered_aliases = [DEFAULT_MODEL_ALIAS]

        # Add remaining model aliases
        ordered_aliases.extend(
            alias for alias in AVAILABLE_MODELS.keys()
            if alias != DEFAULT_MODEL_ALIAS
        )

        return ordered_aliases

    def get_models_info(self) -> list:
        """
        Return model metadata for frontend display and documentation.
        """

        # Store model information records
        models_info = []

        # Process models in display order
        for model_alias in self.get_available_models():

            # Retrieve metadata for the current model
            model_info = MODEL_INFO.get(model_alias)

            if model_info is None:
                continue

            # Add model details with alias and default flag
            models_info.append(
                {
                    **model_info,
                    "alias": model_alias,
                    "is_default": model_alias == DEFAULT_MODEL_ALIAS,
                }
            )

        # Log number of models returned
        logger.debug(f"Resolved {len(models_info)} model info entries")

        return models_info