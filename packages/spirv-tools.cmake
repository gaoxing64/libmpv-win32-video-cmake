ExternalProject_Add(spirv-tools
    GIT_REPOSITORY https://github.com/KhronosGroup/SPIRV-Tools.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--filter=tree:0"
    GIT_REMOTE_NAME origin
    # Pinned to the revision shaderc expects (google/shaderc DEPS). Tracking
    # main here made the two drift apart and broke shaderc's build with
    # "no member named 'StorageClassToString' in namespace 'spvtools'".
    GIT_TAG 71f287f18ed78d496e724fbfb1c3feae3a2af75a
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1 LOG_UPDATE 1
)

force_rebuild_git(spirv-tools)
cleanup(spirv-tools install)
