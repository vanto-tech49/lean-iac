# lean-iac

## Overview

The `lean-iac` repository is designed to provide a modular and centralized Infrastructure as Code (IaC) framework. It aims to streamline the provisioning and management of infrastructure components, ensuring consistency, reusability, and automation.

## Purpose

- **Modularity**: Break down infrastructure into reusable modules for better organization and maintainability.
- **Automation**: Leverage GitHub Actions for automated deployments and CI/CD workflows.
- **Scalability**: Create a robust framework that supports rapid growth and adapts to changing requirements.

## Defining a robust base

### .gitattributes

The usage of the ```.gitattributes``` file is mainly based on the  because of Cross-Platofrm Development. Different operating systems use different line-ending conventions (LF for Linux/macOS, CRLF for Windows). Without ```.gitattributes```, inconsistent line endings can cause issues when collaborating across platforms.

If a developer on Windows commits a file with CRLF line endings, and another developer on Linux checks it out, the ```.gitattributes``` file ensures that the line endings are normalized to LF in the repository and converted back to the appropriate format on checkout.
This helps maintain consistency and avoids issues like unnecessary diffs caused by line-ending mismatches.

### .gitignore

As the filename already suggests, the ```.gitignore```file is a simple way to tell **git** to not include certain files. This helps to exluce not relevant information or files which not belong to a central source code control system. These can be build results or temporarly or OS specfic files.

In this specific **IaC using Terraform** example, we ignore the **.terraform** folder which contains the local state information as we exclusively want to store the state in a remote storage.

## Repository Structure

```plaintext
lean-iac
|__ .github
|   |__ workflows          # CI/CD workflows for Terraform commands and deployments
|   |__ actions            # Shell scripts for pre- or post-deployments
|__ src
|   |__ terraform
|   |   |__ platform
|   |   |   |__ core        # Core infrastructure definitions
|   |   |   |__ bootstrap   # Bootstrapping essential services (e.g., ArgoCD, NGINX)
|   |   |__ modules         # Terraform resourse implementations
|   |   |__ vars            # Environment-specific configurations
```



## Getting Started

1. **Clone the Repository**:

   ```bash
   git clone <repository-url>
   cd lean-iac

