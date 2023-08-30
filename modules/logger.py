import logging
import colorlog
from config import config


def setup_logger(log_level: str) -> logging.Logger:
    """Return a logger instance

    log_level: ERROR > WARNING > INFO > DEBUG
    
    """

    log_levels = {
        'DEBUG': colorlog.DEBUG,
        'INFO': colorlog.INFO,
        'WARNING': colorlog.WARNING,
        'ERROR': colorlog.ERROR
    }

    # Set up color logging
    log_colors = {
        'DEBUG': 'white',
        'INFO': 'green',
        'WARNING': 'yellow',
        'ERROR': 'red',
    }

    log_format = "%(asctime)s %(log_color)s%(levelname)-8s%(reset)s \x1b[34m%(name)s\x1b[0m %(message)s"
    formatter = colorlog.ColoredFormatter(log_format, log_colors=log_colors, datefmt="%Y-%m-%d %H:%M:%S")

    # Set up the logger
    logger = colorlog.getLogger('Flatfile System')
    handler = colorlog.StreamHandler()
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(log_levels[log_level])

    return logger

logger = setup_logger(config.get("log_level"))