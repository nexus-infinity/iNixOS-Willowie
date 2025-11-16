# Model Artifacts and Hugging Face Integration

## ⚠️ STUBS — REVISIT ⚠️

**IMPORTANT**: This directory contains **STUB/PLACEHOLDER** content that must be updated before production use.

The `index.json` file contains example entries with placeholder values marked with `TODO-STUB-*` prefixes. Before deploying trained models:

1. **Update `index.json`** with real model metadata
2. **Replace all `TODO-STUB-*` placeholders** with actual values
3. **Verify SHA-256 checksums** match your trained model files
4. **Update dataset and training repository URLs** to point to real locations
5. **Add actual training metrics** from your training logs

See the `STUBS_TO_REVISIT` section in `index.json` for a complete list of fields requiring updates.

---

## Overview

This directory provides declarative model artifact management and Hugging Face integration for the iNixOS-Willowie NixOS deployment. It enables:

- **Structured metadata** for trained models using JSON Schema validation
- **Version control** for model artifacts with checksums and provenance
- **NixOS integration** through the `hf-integration.nix` module
- **CI/CD workflows** for automated model updates and validation

## Files

### `schema.json`

JSON Schema (Draft 07) that defines the structure and validation rules for model artifact metadata.

**Required fields:**
- `id`: Unique model identifier (e.g., `muladhara-foundation-v1`)
- `version`: Semantic version (e.g., `1.0.0`)
- `chakra`: Associated chakra energy center (enum: muladhara, svadhisthana, etc.)
- `frequencyHz`: Resonant frequency (0-10000 Hz)
- `geometry`: Sacred geometry alignment properties (pattern, dimensions)
- `temporalScope`: Temporal applicability (ephemeral, daily, eternal, etc.)
- `semanticTags`: Array of categorization tags
- `dataset`: Training dataset metadata (id, commit, url)
- `training`: Training run information (repo, commit, command)
- `artifact`: Model file details (filename, **sha256**, sizeBytes)
- `license`: SPDX license identifier
- `provenance`: Reproducibility metadata (runId, metrics)

**Purpose**: Ensures consistency and completeness of model metadata entries. Used by CI pipelines to validate updates before merging.

### `index.json`

Model registry index containing metadata entries for all deployed models.

**Structure:**
```json
{
  "$schema": "./schema.json",
  "STUBS_TO_REVISIT": { ... },
  "models": [
    { /* model entry 1 */ },
    { /* model entry 2 */ }
  ]
}
```

**Current state**: Contains a single example entry for the `muladhara` chakra with **stub/placeholder values**.

**How to update:**
1. **Manual update**: Edit `index.json` directly, following the schema structure
2. **CI automation**: Push trained models to your CI system, which should:
   - Compute SHA-256 checksums
   - Extract training metrics from logs
   - Generate a new entry conforming to `schema.json`
   - Create a PR with the updated `index.json`
3. **Validation**: Run `ajv validate -s schema.json -d index.json` (requires `ajv-cli`)

### `hf-integration.nix`

NixOS module that exposes `services.models` configuration options for integrating model artifacts into the system deployment.

**Features:**
- Declarative model deployment configuration
- Integration with Hugging Face model repositories
- Automatic model downloading and caching via Nix
- Chakra-aligned model organization

**Usage:**
```nix
services.models = {
  enable = true;
  huggingFace = {
    enable = true;
    cacheDir = "/var/lib/models/hf-cache";
  };
  deployedModels = [
    "muladhara-foundation-v1"
  ];
};
```

See the module file for complete options and documentation.

### `README.md` (this file)

Documentation for operators, CI maintainers, and developers working with model artifacts.

---

## Naming Conventions

### Model IDs
- **Format**: `<chakra>-<purpose>-v<version>`
- **Examples**: 
  - `muladhara-foundation-v1`
  - `ajna-insight-v2`
  - `sahasrara-transcendence-v3-alpha`
- **Rules**:
  - Lowercase with hyphens
  - Must start and end with alphanumeric
  - 3-64 characters

### Artifact Filenames
- **Recommended**: `<model-id>.<format>`
- **Examples**:
  - `muladhara-foundation-v1.safetensors`
  - `ajna-insight-v2.gguf`
- **Formats**: `safetensors`, `gguf`, `pytorch`, etc.

### Semantic Tags
- Lowercase, hyphen-separated
- Descriptive and searchable
- Examples: `foundation`, `root-chakra`, `grounding`, `432hz`

---

## SHA-256 Checksums

**Critical**: Model integrity depends on correct SHA-256 checksums.

### Computing checksums

**Linux/macOS:**
```bash
sha256sum muladhara-foundation-v1.safetensors
```

**Output format:**
```
a1b2c3d4e5f6... muladhara-foundation-v1.safetensors
```

**Add to index.json:**
```json
{
  "artifact": {
    "filename": "muladhara-foundation-v1.safetensors",
    "sha256": "a1b2c3d4e5f6...",
    "sizeBytes": 1234567890
  }
}
```

### Verification

When downloading models, the NixOS integration module will verify checksums automatically. Mismatches will prevent deployment.

---

## CI Workflow Behavior

### Automated Model Updates (Future)

The CI pipeline should:

1. **Trigger**: On new model training completion or manual dispatch
2. **Compute metadata**:
   - Calculate SHA-256 checksum
   - Extract file size
   - Parse training metrics from logs
   - Generate provenance metadata
3. **Update index**:
   - Add new entry to `models` array in `index.json`
   - Validate against `schema.json`
4. **Create PR**:
   - Branch: `ci/model-update-<model-id>`
   - Title: `Add model artifact: <model-id>`
   - Description: Include training summary and metrics
5. **Validation**:
   - JSON Schema validation
   - Checksum verification
   - NixOS evaluation check
6. **Merge**: Upon approval, model becomes available for deployment

### Manual Updates

If CI automation is not yet configured:

1. Train your model
2. Upload to Hugging Face (or other host)
3. Compute SHA-256 checksum
4. Create a new entry in `index.json` following the schema
5. Replace all `TODO-STUB-*` values with real data
6. Validate with schema
7. Submit a PR with the updated `index.json`

---

## Hugging Face Integration

### Repository Structure

Models should be hosted in Hugging Face repositories with this structure:

```
my-org/muladhara-foundation-v1/
├── README.md
├── config.json
├── muladhara-foundation-v1.safetensors  # Main model file
└── metadata.json  # Optional: mirrors index.json entry
```

### Download URLs

Use the Hugging Face CDN URL format:

```
https://huggingface.co/<org>/<repo>/resolve/main/<filename>
```

**Example:**
```
https://huggingface.co/nexus-infinity/muladhara-foundation-v1/resolve/main/muladhara-foundation-v1.safetensors
```

### Authentication (Private Models)

For private model repositories:

1. Set `services.models.huggingFace.tokenFile` in your NixOS configuration
2. Store your HF token in a secure location (e.g., `/run/secrets/hf-token`)
3. The integration module will use this token for authenticated downloads

---

## Integration with NixOS Configuration

### Basic Setup

Add to your `flake.nix` or machine configuration:

```nix
{
  imports = [
    ./modules/models/hf-integration.nix
  ];

  services.models = {
    enable = true;
    huggingFace.enable = true;
    deployedModels = [
      "muladhara-foundation-v1"
    ];
  };
}
```

### Advanced Configuration

```nix
services.models = {
  enable = true;
  indexPath = ./modules/models/index.json;
  
  huggingFace = {
    enable = true;
    cacheDir = "/var/lib/models/hf-cache";
    tokenFile = "/run/secrets/hf-token";  # For private repos
  };
  
  deployedModels = [
    "muladhara-foundation-v1"
    "svadhisthana-flow-v2"
  ];
  
  # Chakra-specific deployment
  chakraModels = {
    muladhara = [ "muladhara-foundation-v1" ];
    svadhisthana = [ "svadhisthana-flow-v2" ];
  };
};
```

---

## Provenance and Reproducibility

The `provenance` section ensures reproducibility and auditability:

### Required Fields

- **runId**: Unique identifier for the training run (e.g., W&B run ID)
- **metrics**: Training/evaluation metrics (loss, accuracy, perplexity)

### Recommended Fields

- **timestamp**: ISO 8601 timestamp of model creation
- **creator**: Entity that trained the model
- **reproducibility.seed**: Random seed for reproducibility
- **reproducibility.environment**: Environment description or hash

### Example

```json
{
  "provenance": {
    "runId": "wandb-run-abc123",
    "timestamp": "2024-11-08T12:00:00Z",
    "creator": "nexus-infinity",
    "metrics": {
      "loss": 2.143,
      "accuracy": 0.867,
      "perplexity": 8.52
    },
    "reproducibility": {
      "seed": 42,
      "environment": "nixos-23.11-cuda-12.1"
    }
  }
}
```

---

## Troubleshooting

### Schema Validation Failures

**Error**: `data.artifact.sha256 should match pattern "^[a-f0-9]{64}$"`

**Solution**: Ensure SHA-256 checksum is 64 hexadecimal characters (lowercase).

### Missing Fields

**Error**: `data should have required property 'frequencyHz'`

**Solution**: Add the missing required field to your model entry.

### Checksum Mismatches

**Error**: `Model checksum verification failed`

**Solution**: 
1. Recompute the SHA-256 checksum of your model file
2. Update `index.json` with the correct checksum
3. Ensure the file hasn't been corrupted during upload/download

### Model Not Found

**Error**: `Model 'xyz' not found in index`

**Solution**: Verify the model ID exists in `index.json` under the `models` array.

---

## References

- [JSON Schema Specification](https://json-schema.org/)
- [Hugging Face Model Hub](https://huggingface.co/models)
- [NixOS Module System](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [Semantic Versioning](https://semver.org/)
- [SPDX License List](https://spdx.org/licenses/)

---

## Next Steps

1. **REVISIT the stubs**: Update `index.json` with real model metadata
2. **Train a model**: Use your training pipeline to create a chakra-aligned model
3. **Upload to Hugging Face**: Make the model available for download
4. **Update the index**: Add a proper entry with real checksums and metrics
5. **Deploy**: Enable `services.models` in your NixOS configuration
6. **Set up CI**: Automate model updates through your CI/CD pipeline

---

**Last updated**: 2024-11-08  
**Schema version**: 1.0.0  
**Maintainer**: nexus-infinity/iNixOS-Willowie
