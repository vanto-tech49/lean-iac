# lean-iac

``lean-iac`` is a practical, minimalistic Infrastructure as Code (IaC) framework designed to reduce operational overhead and enable DRY, scalable Terraform deployments across multiple cloud environments.

This approach leverages native Terraform, modular structure, and GitHub Actions to orchestrate infrastructure changes across environments like ``tst``, ``int``, and ``prd``—**without using workspaces, duplicated folders, or third-party wrappers like Terragrunt**.

## Why ``lean-iac``?

### The problem with common multi-environment strategies

#### 1. Terraform Workspaces

Workspaces isolate state, but **not code**. All environments share the same Terraform configuration and module versions, making isolated testing or phased rollouts risky. You must use complex conditionals to differentiate environments, which clutters the code and introduces tight coupling.

#### 2. Separate Folders per Environment

This offers separation of logic and state, but at the cost of **massive duplication**. You copy-paste .tf files across environments, increasing maintenance burden and the risk of drift.

##### 3. Third-party Wrappers (e.g., Terragrunt)

While powerful, wrappers add another layer of complexity. They require version management, increase the learning curve, and may pose **licensing or compliance concerns** in corporate environments.

## How ```lean-iac``` solves this

- **Same ``.tf`` files for all environments**
- **No workspaces, no folder duplication**
- **No third-party dependencies**
- **Environment-specific variables loaded via YAML**
- **Dynamic backend configuration generated per run**
- **Fully GitHub-native using ``workflow_call`` + ``workflow_dispatch``**

All logic is environment-aware but cleanly separated through input parameters, not conditional spaghetti. Each environment triggers the same Terraform module with different input and isolated state.

> [!NOTE]
> While all environments share the same Terraform code, deployments are fully isolated by environment. To fully decouple logic evolution (e.g. test new resources only in ``tst``), module version pinning or staged rollout patterns can be added.

## Usage

### Prerequisites

Before running the workflow, ensure the following **GitHub environment secrets are configured**:

```bash
ARM_TENANT_ID                   # Azure AD tenant ID
ARM_SUBSCRIPTION_ID             # Azure subscription ID
ARM_CLIENT_ID                   # Azure service principal client ID
ARM_CLIENT_CERTIFICATE_PASSWORD # Optional password for the PFX, can be left empty
ARM_CLIENT_PFX_BASE64           # Base64-encoded .pfx certificate used for SPN authentication
```

> [!NOTE]
> Setting ``ARM_SUBSCRIPTION_ID`` here avoids the need to hardcode the subscription ID in the Terraform provider blocks.

### Convert PFX to base64

If you have a ``.pfx`` certificate file and want to store it as a GitHub secret, convert it to base64 using:

```bash
base64 -i certificate.pfx | tr -d '\n' > cert.pfx.b64
```

Then copy the content of ``cert.pfx.b64`` and add it as a secret (``ARM_CLIENT_PFX_BASE64``) in your GitHub environment settings.

This setup assumes your Terraform modules live under ``src/terraform`` and are driven by a calling workflow.

### Trigger workflow

```bash
# .github/workflows/provision-infra.yml
name: provision-infra
on:
  workflow_dispatch:
    inputs:
      command:
        description: Terraform command
        type: choice
        options:
          - plan
          - plan+apply
          - destroy

jobs:
  tst-core:
    uses: ./.github/workflows/_iac.yml
    with:
      command: ${{ inputs.command }}
      environment: tst-gwc
      working-directory: ./src/terraform/platform/core
    secrets: inherit
```

### Core logic

```bash
# .github/workflows/_iac.yml
- name: Load environment-specific variables
  uses: ./.github/actions/load-variables
  with:
    path: ${{ github.workspace }}/src/terraform/vars/vars-${{ inputs.environment }}.yml

- name: Terraform init
  run: |
    # Generate backend config dynamically
   printf "environment          = \"${{ env.arm_environment }}\"\n" >> $FILENAME
   printf "subscription_id      = \"${{ env.TF_VAR_subscription_id }}\"\n" >> $FILENAME
   printf "resource_group_name  = \"${{ env.TF_VAR_backend_resource_group_name }}\"\n" >> $FILENAME
   printf "storage_account_name = \"${{ env.TF_VAR_backend_storage_account_name }}\"\n" >> $FILENAME
   printf "container_name       = \"${{ env.TF_VAR_backend_storage_container_name }}\"\n" >> $FILENAME
   printf "key                  = \"${{ env.TF_VAR_backend_key }}\"\n" >> $FILENAME
   
   terraform init -backend-config=backend.tfvars

- name: Terraform plan/apply/destroy
  run: terraform ${{ inputs.command }} [...]
```

See full examples in ``.github/workflows/``.

### Folder structure

```bash
src/terraform
├── platform
│   └── core
│       ├── main.tf
│       └── variables.tf
├── vars
│   ├── vars-defaults.yml
│   └── vars-tst-gwc.yml
```

## Key Benefits

- Works in **any CI/CD** but is optimized for GitHub Actions
- Eliminates workspaces and their limitations
- Keeps infrastructure modular, composable, and testable
- Reduces risk of misconfiguration and simplifies rollout pipelines