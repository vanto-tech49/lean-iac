#!/bin/bash

# Load parameters "--xyz abc" as named variables, see https://brianchildress.co/named-parameters-in-bash/
while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
    fi
    shift
done

# Ensure provided parameters
if [[ -z "${location}" ]]; then
    echo "Parameter missing: --location"
    exit 1
elif [[ -z "${rgName}" ]]; then
    echo "Parameter missing: --rgName"
    exit 2
elif [[ -z "${saName}" ]]; then
    echo "Parameter missing: --saName"
    exit 3
fi

echo -e "Initialize-StateStore:"
echo -e "- location\t\t=\t$location"
echo -e "- rgName\t\t=\t$rgName"
echo -e "- saName\t\t=\t$saName"
echo -e ""

echo -e "Create/access resource group '$rgName'..."
az group create --location $location --name $rgName --output none

echo -e "Ensure registered provider 'Microsoft.Storage'..."
az provider register --namespace 'Microsoft.Storage' --wait

echo -e "Create/access storage account '$saName'..."
saId=$(az storage account create --name $saName --resource-group $rgName --location $location --sku Standard_RAGRS --kind StorageV2 --default-action Deny --public-network-access Enabled --allow-shared-key-access false --min-tls-version TLS1_2 --query id --output tsv 2>/dev/null)
echo -e "- Resolved full Storage Account Id: $saId"
