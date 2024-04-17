IMAGE_NAME="winetkg_builder"

set -xe

if [ "$REBUILD_IMAGE" == "true" ] && podman image exists $IMAGE_NAME
then
	podman image rm --force $IMAGE_NAME
fi

if ! podman image exists $IMAGE_NAME
then
	podman image build -f Dockerfile -t $IMAGE_NAME
fi

if ! [ -e wine-tkg-git ]
then
	git clone https://github.com/Frogging-Family/wine-tkg-git.git
fi

(
	cd wine-tkg-git
	git fetch origin
)

if ! [ -e ntsync.h ]
then
	_commit=67ecf76b95fcaf9a70e54b0d25b485f4e135e439
	curl "https://repo.or.cz/linux/zf.git/blob_plain/$_commit:/include/uapi/linux/ntsync.h" --output "ntsync.h"
fi

podman run \
	--rm -it \
	--security-opt label=disable \
	-v ./wine-tkg-git:/workdir/wine-tkg-git \
	-w /workdir \
	--entrypoint /bin/bash \
	-v ./script:/workdir/script:ro \
	-v ./ntsync.h:/usr/include/linux/ntsync.h:ro \
	--env DEBIAN_FRONTEND=noninteractive \
	$IMAGE_NAME \
	script
