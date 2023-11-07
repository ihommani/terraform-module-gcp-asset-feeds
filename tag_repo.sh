#!/bin/bash

INITIAL_VERSION=1.0.0
version=""
increment_type=""

function usage() {
    echo "Usage: $0 [-v X.Y.Z] [-i <MAJOR|MINOR|PATCH>] [-h]"
    exit 0
}

function apply_tags() {
    major="$1"
    minor="$2"
    patch="$3"

    t1="v${major}.${minor}.${patch}"
    echo "- tagging ${t1}"
    git tag ${t1}
    t2="v${major}.${minor}"
    echo "- tagging ${t2}"
    git tag -f ${t2}
    t3="v${major}"
    echo "- tagging ${t3}"
    git tag -f ${t3}

    echo "Do you want to push (with tags) ? (y/n)"
    read ans
    if [ "${ans^^}" == "Y" ]; then
        echo "Pushing (with tags)"
        git push --tags
    else
        echo "Not pushing."
        echo "You can manually push using : git push --tags"
    fi
}

function tag_version() {
    version="$1"
    major=$(echo ${version} | cut -d"." -f1)
    minor=$(echo ${version} | cut -d"." -f2)
    patch=$(echo ${version} | cut -d"." -f3)

    apply_tags "${major}" "${minor}" "${patch}"
}

function tag_increment() {
    increment_type="$1"
    echo "Incrementing tag ${increment_type}"
    last_version=$(git tag -l --sort=-version:refname v*.*.* | head -n1 | sed 's/^v//')
    echo "Last found version : ${last_version}"

    major=$(echo ${last_version} | cut -d"." -f1)
    minor=$(echo ${last_version} | cut -d"." -f2)
    patch=$(echo ${last_version} | cut -d"." -f3)

    if [ "${increment_type}" == "MAJOR" ]; then
        major=$((major + 1))
        minor=0
        patch=0
    elif [ "${increment_type}" == "MINOR" ]; then
        minor=$((minor + 1))
        patch=0
    else
        patch=$((patch + 1))
    fi

    echo "Incremented version : ${major}.${minor}.${patch}"
    apply_tags "${major}" "${minor}" "${patch}"
}

while getopts "hv:i:" o; do
    case "${o}" in
    h)
        usage
        ;;
    v)
        version=${OPTARG}
        ;;
    i)
        increment_type=${OPTARG^^}
        ;;
    *)
        echo "Unsupported parameter"
        usage
        exit 1
        ;;
    esac
done

if [ -z "${version}${increment_type}" ]; then
    echo "Missing parameter !" 2>&1
    echo "version or increment_type must be set" 2>&1
    usage
    exit 1
elif [ "${version}" != "" -a "${increment_type}" != "" ]; then
    echo "version and increment_type cannot be used at the same time" 2>&1
    usage
    exit 1
elif [ "${version}" != "" ]; then
    if [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Using version = ${version}"
        tag_version ${version}
    else
        echo "Version '${version}' is incorrect" 2>&1
        usage
        exit 1
    fi
elif [ "${increment_type}" != "" ]; then
    if [[ "${increment_type}" =~ ^(MAJOR|MINOR|PATCH)$ ]]; then
        echo "Using increment_type = ${increment_type}"
        tag_increment ${increment_type}
    else
        echo "Increment type '${increment_type}' is incorrect" 2>&1
        usage
        exit 1
    fi
fi
