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
if [[ -z "${rgName}" ]]; then
    echo "Parameter missing: --rgName"
    exit 1
elif [[ -z "${saName}" ]]; then
    echo "Parameter missing: --saName"
    exit 2
elif [[ -z "${saContainerName}" ]]; then
    echo "Parameter missing: --saContainerName"
    exit 3
elif [[ -z "${spApplicationId}" ]]; then
    echo "Parameter missing: --spApplicationId"
    exit 4
fi

echo -e "Initialize-StateStore:"
echo -e "- rgName\t\t=\t$rgName"
echo -e "- saName\t\t=\t$saName"
echo -e "- saContainerName\t=\t$saContainerName"
echo -e "- spApplicationId\t=\t$spApplicationId"
echo -e ""

echo -e "Create/access storage container '$saContainerName'..."
containerCreated=$(az storage container create --account-name $saName --auth-mode login --name $saContainerName --output tsv --query created)
if [[ "$containerCreated" == "false" ]]; then
    echo -e "Storage container '$saContainerName' already exists."
else
    echo -e "Storage container '$saContainerName' created."
fi

echo -e "Ensure Storage Blob Data Contributor role on container for service principal application id '$spApplicationId'..."
saId=$(az storage account show --name $saName --resource-group $rgName --query "id" -o tsv)
echo -e "- Resolved storage account object id: $saId"
spObjectId=$(az ad sp list --filter "appId eq '$spApplicationId'" --query "[0].id" -o tsv)
echo -e "- Resolved service principal object id: $spObjectId"
az role assignment create --role "Storage Blob Data Contributor" --assignee-principal-type ServicePrincipal --assignee-object-id $spObjectId --scope $saId/blobServices/default/containers/$saContainerName >/dev/null 2>&1
echo -e "- Resolved role assignment"
