# Below is an example of a Makefile setup for a project that uses Docker and Go.

DOCKER_REPO := "my-org/my-repo"

-include artifacts/make/go/Makefile
-include artifacts/make/docker/Makefile

artifacts/make/%/Makefile:
	curl -sf https://jmalloc.github.io/makefiles | bash /dev/stdin $*
