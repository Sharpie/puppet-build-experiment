# Puppet Runtime

The `puppet-runtime` project uses Vanagon to build Puppet Runtime inside of
a container. In order to function properly, the build requires several
environment variables to be set:

  - `VANAGON_BUILD_VERSION`: The tag of `puppet-agent` to build.
  - `VANAGON_DOCKER_IMAGE`: Docker image to use in the build.
  - `VANAGON_DOCKER_RUN_ARGS`: Arguments to pass to `docker run`. Usually file
    systems that must be mounted for SystemD to start.
  - `VANAGON_SSH_PORT`: The ssh port that Docker should use.

The build will start up a container, clone the `puppet-runtime` project,
apply patches, and then execute a Vanagon build inside the container.
