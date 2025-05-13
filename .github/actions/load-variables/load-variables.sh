#!/bin/bash

# fail on error
set -e

# Load parameters "--xyz abc" as named variables, see https://brianchildress.co/named-parameters-in-bash/
while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        
        # set optional ones to empty string, as notation "--param1 value1 --param2 value2" requires any string as value in order not to loose the next param, therefore "===none===" is treated as empty string
        if [[ $2 == "===none===" ]]; then
            declare $param=
        else
            declare $param="$2"
        fi
    fi
    shift
done

# Compatibility: use yaml as path
if [[ -z "${path}" ]]; then
    path=${yaml}
fi

# Ensure provided parameters
if [[ -z "${path}" ]]; then
    echo "Parameter missing: --path"
    exit 100
fi
if [[ ! -f "$path" ]]; then
    echo "Path '$path' does not exist."
    exit 101
fi

# Do actual stuff
echo "Loading yaml into variables: $path"

if [[ "$debug" =~ "path" ]]; then
    echo "Variables:"
fi

while IFS=$'#' read variable_name value
do
    # transform variable name
    case $variable_name_style in
        all-uppercase)
            variable_name=${variable_name^^}
            ;;
        all-lowercase)
            variable_name=${variable_name,,}
            ;;
    esac

    # check resulting variable name
    if [[ ! "$variable_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]
    then
        echo "Invalid resulting variable name, must start with alphanumeric characters and only alphanumeric characters, digits and underscores allowed: $variable_name"
        exit 102
    fi    

    # debug set env variable, as well as remembering it for subsequent github actions - if in such execution context
    if [[ "$debug" =~ "path" ]]; then
        echo "- $variable_name: $value"
    fi
    export $variable_name="$value"
    if [ ! -z "$GITHUB_ENV" ]; then
        echo "$variable_name=$value" >> "$GITHUB_ENV"
    fi
    # yq: see https://mikefarah.gitbook.io/yq/
    # - Process entries in "variables", or root entries - if "variables" doesn't exists ("variables" was used originally, therefore keep being compatible)
    # - Grep out, if fallback to ".", therefore a full line "variables#" (without value) got generated
done < <(
     yq '... comments=""' $path |   yq e '
        .variables // .| to_entries | .[] |
        [
            (.key | sub("\n","\n") | sub("\r","\r") | sub("\t","\t")),
            (.value)
        ] |
        join ("#")
    ' | grep -vx "variables#"
)