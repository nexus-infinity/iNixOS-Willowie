
###############################################################################
# Copilot Assistant Service (Geometric Alignment)
###############################################################################

# Make sure this import is present in your imports list!
# If you have an existing 'imports = [ ... ];' block, add the line below inside it.
imports = [
  ../modules/services/copilot-assistant.nix
# ... other imports ...
];

services.copilot-assistant = {
  enable = true;
  backend = "python";
  backendScript = "/etc/copilot-assistant/copilot-assistant-python.py";
  port = 8765;
};

###############################################################################
# Copilot Assistant Service (Geometric Alignment)
###############################################################################

# Add this to your imports array (edit the existing one, or add if not present):
imports = [
  ../modules/services/copilot-assistant.nix
  # ...other imports...
];

# Then add or update this configuration block:
services.copilot-assistant = {
  enable = true;
  backend = "python";
  backendScript = "/etc/copilot-assistant/copilot-assistant-python.py";
  port = 8765;
};
