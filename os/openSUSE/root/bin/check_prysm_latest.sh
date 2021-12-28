#!/bin/bash
unset -v latest
for file in "/opt/beacon-chain/bin/dist"/*; do
  [[ $file -nt $latest ]] && latest=$file
done

version=$(echo ${latest} | grep -Po '(?<=chain-)[^-]+')
echo "Used version: $version"

git_latest=$(curl -f -s https://prysmaticlabs.com/releases/latest)
echo "Latest version: $git_latest"

if [ $version != $git_latest ]; then
    echo "Update required..."
    echo "Update required: $git_latest" |/usr/bin/mailx -s 'An update is available for Prysm! (StekerNode)' info@angelhost.eu
else
    echo "Nothing to do"
fi
