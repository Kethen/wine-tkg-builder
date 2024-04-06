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

if ! [ -e winesync.h ]
then
	_commit=e6bc51b547bbe820055e73cdbb93755b5bfa368c
	curl "https://repo.or.cz/linux/zf.git/blob_plain/$_commit:/include/uapi/linux/winesync.h" --output "winesync.h"
fi

podman run \
	--rm -it \
	--security-opt label=disable \
	-v ./wine-tkg-git:/workdir/wine-tkg-git \
	-w /workdir \
	--entrypoint /bin/bash \
	-v ./script:/workdir/script:ro \
	-v ./winesync.h:/usr/include/linux/winesync.h:ro \
	--env DEBIAN_FRONTEND=noninteractive \
	$IMAGE_NAME \
	script
