Repository instructions for AI Assistants (nexus-infinity/iNixOS-Willowie)

This configuration supports multiple AI assistants for development coherence:
- **GitHub Copilot**: Primary code completion and chat assistant
- **Google Gemini**: Alternative AI assistant for code review and suggestions
- **Local LLM Agents**: Self-hosted models (e.g., Ollama, LLaMA) for privacy-focused development

You are a repository-scoped AI assistant for nexus-infinity/iNixOS-Willowie.
Follow these immutable rules:

Core constraints (do not change or bypass)
- Use Nix/NixOS flakes and native Nix builds only. Do NOT propose Docker images, Dockerfiles, or container registries.
- Do NOT create, modify, or recommend using any external cloud provider resources (AWS, GCP, Azure) unless explicitly authorized in a PR by the repo owner.
- Do NOT suggest or add new paid subscriptions or external services.
- Always prefer local testing workflows (nix build, nix develop, nixos-rebuild, systemd) and emulation only if explicitly requested.
- For local LLM integration, prefer Nix-packaged solutions (e.g., ollama from nixpkgs) over manual installations.

Repository workflow
- All code changes must be proposed via branches and pull requests. Use branch names prefixed with "copilot/" for Copilot-generated changes (e.g. copilot/add-nix-derivation).
- Provide a single-file patch or minimal changeset per PR, with a clear description and testing steps.
- When proposing system changes (NixOS modules, services), add a short local test plan showing how to reproduce the build and test locally with nix build and systemd unit checks.

Copilot-assistant service specifics
- This repository contains a NixOS module: modules/services/copilot-assistant-flake.nix.
- When proposing changes to copilot-assistant, ensure:
  - The module remains optional (services.copilot-assistant.enable must default to false).
  - Any added scripts are stored under modules/services or etc/ in the flake and referenced via the flake.
  - No networked cloud onboarding or automatic account authorization should be added.

Approval and observers
- Changes that alter service enablement, authentication, or secrets require a PR approved by at least:
  - Field observer (position 3)
  - Architect (position 6)
  - Weaver (position 9)
- After merge, testing must be witnessed by the external observer (position 11 — repository owner / you) before any production enablement or cross-account changes.

Testing & commands (for humans)
- Build the flake outputs:
  nix build --no-link .#nixosConfigurations.BearsiMac.config.system.build.toplevel
- Rebuild and switch NixOS (only run on the machine you control):
  sudo nixos-rebuild switch --flake .#BearsiMac
- Check whether the copilot-assistant module is visible:
  nixos-option services.copilot-assistant.enable
- Check the local systemd service status:
  systemctl status copilot-assistant.service

If you are Copilot Chat: always ask the user before changing authentication, credentials, or any file under ~/.aws, ~/.config, or system secrets. When in doubt, propose a PR and do not commit or push changes without review.

Local LLM Agent Integration
- For local LLM coherence building, the system supports:
  - Ollama: `nix-shell -p ollama` or add to system packages
  - LLaMA models: Via ollama or direct nixpkgs integration
  - Open-source alternatives to cloud AI services
- When implementing local LLM features:
  - Create service modules in `modules/services/` following existing patterns
  - Use systemd for service management
  - Store model configurations in the flake, not user home directories
  - Prefer CPU inference for compatibility; GPU acceleration is optional
- Branch naming for AI-assisted changes:
  - `copilot/*`: GitHub Copilot generated changes
  - `gemini/*`: Google Gemini assisted changes  
  - `local-llm/*`: Local LLM agent generated changes
