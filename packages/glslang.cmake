ExternalProject_Add(glslang
    GIT_REPOSITORY https://github.com/KhronosGroup/glslang.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--sparse --filter=tree:0"
    GIT_CLONE_POST_COMMAND "sparse-checkout set --no-cone /* !Test"
    GIT_REMOTE_NAME origin
    # Pinned to the revision shaderc expects (google/shaderc DEPS). Tracking
    # main here let the shader toolchain versions drift apart and broke the
    # shaderc build.
    GIT_TAG 73b25650df6dc4545966674531e6b7cc8f5d2407
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1 LOG_UPDATE 1
)

force_rebuild_git(glslang)
cleanup(glslang install)
