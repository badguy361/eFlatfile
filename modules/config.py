import os.path as path
from ruamel.yaml import YAML


yaml = YAML()

class Config:
    """The class for managing the configuration of a Discord bot."""

    def __init__(self):
        """Initialize the Config instance."""
        self.file_path = path.abspath(__file__)
        self.project_folder = path.dirname(path.dirname(self.file_path))
        self.config_path = path.join(self.project_folder, "config.yml")
        self.config = self._read_config_data()

    def get(self, node):
        """
        Get the value of a configuration node.

        Args:
            node (str): The node in the configuration to retrieve (can be nested using dots).

        Returns:
            Any: The value of the specified configuration node.
        """
        return self._get_config_traverse_dict(self.config, node.split('.'))

    def set(self, node, value):
        """
        Set the value of a configuration node in the YAML file.

        Args:
            node (str): The node to be modified (can be nested using dots).
            value (Any): The new value to be set for the node.

        Returns:
            None
        """
        self._set_config_traverse_dict(self.config, node.split('.'), value)
        self._save_to_config_file()

    def reload_config(self):
        """
        Reload the configuration data from the YAML file.

        Returns:
            None
        """
        self.config = self._read_config_data()

    def _save_to_config_file(self):
        """
        Save the configuration data to the YAML file.

        Returns:
            None
        """
        with open(self.config_path, 'w', encoding="utf-8") as file:
            yaml.dump(self.config, file)

    def _read_config_data(self):
        """
        Read the configuration data from the YAML file.

        Returns:
            dict: The configuration data as a dictionary, or an empty dictionary if an error occurred during reading.
        """
        return self._read_yaml_file(self.config_path)

    def _read_yaml_file(self, file_path):
        """
        Read the content of a YAML file.

        Args:
            file_path (str): The path of the YAML file to read.

        Returns:
            dict: The content of the YAML file as a dictionary, or an empty dictionary if an error occurred during reading.
        """
        with open(file_path, 'r', encoding='utf-8') as file:
            try:
                yaml_content = yaml.load(file)
                return yaml_content
            except Exception as e:
                print("Error reading the YAML file:", e)
                return {}

    def _set_config_traverse_dict(self, config, node, value):
        """
        Traverse the nested dictionary and set the value for the given node.

        Args:
            config (dict): The nested dictionary to traverse.
            node (list): The list of keys to traverse through the nested dictionary.
            value (Any): The new value to be set for the node.

        Returns:
            None
        """
        if len(node) == 1:
            config[node[0]] = value
            return

        current_key = node[0]
        if current_key not in config:
            config[current_key] = {}

        self._set_config_traverse_dict(config[current_key], node[1:], value)

    def _get_config_traverse_dict(self, config, node):
        """
        Traverse the nested dictionary and retrieve the value for the given node.

        Args:
            config (dict): The nested dictionary to traverse.
            node (list): The list of keys to traverse through the nested dictionary.

        Returns:
            Any: The value of the specified node in the nested dictionary.
        """
        if len(node) == 1:
            return config[node[0]]

        current_key = node[0]
        return self._get_config_traverse_dict(config[current_key], node[1:])
    
config = Config()