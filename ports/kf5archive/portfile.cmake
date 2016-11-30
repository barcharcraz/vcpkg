# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/karchive-5.28.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/KDE/karchive/archive/v5.28.0.tar.gz"
    FILENAME "karchive-5.28.0.tar.gz"
    SHA512 9d8d51262a469e994022592421f6d58b7f0d2216b56c6ceee18009d1683a674d6e912a55d9e36873926ad3771af6b1d672c2fb3f3d977f5252b8028a9b1925de
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_CMAKEPACKAGEDIR=share
        -DKDE_INSTALL_LIBEXECDIR=tools
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/tools)
file(COPY ${CURRENT_PACKAGES_DIR}/debug/share/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
vcpkg_fix_packages()
# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/KF5Archive)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/KF5Archive/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/KF5Archive/copyright)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/KF5Archive)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/KF5Archive/COPYING ${CURRENT_PACKAGES_DIR}/share/KF5Archive/copyright-gpl)
