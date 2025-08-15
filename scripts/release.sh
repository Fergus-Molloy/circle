#!/usr/bin/env bash


echo "Cleaning build directories"
rm -rf _build/prod

VERSION="$(cat mix.exs | grep 'version:' | sed 's/.*"\(.*\)".*/\1/')"
echo "Building release for version $VERSION"

MIX_ENV=prod mix build_release

if [ ! -f "circle-$VERSION.tar.xz" ]; then
	echo "Creating archive..."
	tar cf - -C _build/prod/rel/ circle | pv -s $(du -sb _build/prod/rel | awk '{print $1}') | xz > "circle-$VERSION.tar.xz"
else 
	echo "Archive for version $VERSION already exists"
fi
