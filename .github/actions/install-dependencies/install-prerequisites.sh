#!/bin/bash
# Load parameters "--xyz abc" as named variables, see https://brianchildress.co/named-parameters-in-bash/
while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        
        # skip optional ones, as notation "--param1 value1 --param2 value2" requires any string as value in order not to loose the next param, therefore "===none===" is treated as empty string
        if [[ $2 != "===none===" ]]; then
            declare $param="$2"
        fi
    fi
    shift
done

scriptRoot=$(dirname "$0")

# Handle optional parameters, which are required internally due to some dependant scripts
if [[ -z "${azure_cli}" ]]; then
    # see actions.yml, also "none" supported
    azure_cli=none
fi

# Show parameters
echo -e "- azure_cli\t=\t$azure_cli"

# Installation
if [[ $azure_cli != "none" ]]; then
    echo "Install Azure CLI (latest)..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash

    echo "Azure CLI..."
    az --version
fi
