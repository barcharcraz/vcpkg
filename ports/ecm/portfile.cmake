# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/extra-cmake-modules-5.28.0)
vcpkg_download_distfile(ECM_ARCHIVE
    URLS "https://github.com/KDE/extra-cmake-modules/archive/v5.28.0.tar.gz"
    FILENAME "ecm-5.28.0.tar.gz"
    SHA512 e24956ccfed4f34ef60b4ea48f4cb979a7f24b8820c5d64fa50d16750782d3c7554ea8fcd803008d8efe5ef7b43ddc7a32fb56612ed18f6baede6c6d60cbdec8
)
vcpkg_extract_source_archive(${ECM_ARCHIVE})

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DBUILD_TESTING=OFF
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(WRITE ${CURRENT_PACKAGES_DIR}/include/empty "")
# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING-CMAKE-SCRIPTS DESTINATION ${CURRENT_PACKAGES_DIR}/share/ECM)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ECM/COPYING-CMAKE-SCRIPTS ${CURRENT_PACKAGES_DIR}/share/ECM/copyright)
