# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/qtbase-opensource-src-5.7.0.7z)
vcpkg_download_distfile(ARCHIVE
    URLS "https://download.qt.io/archive/qt/5.7/5.7.0/submodules/qtbase-opensource-src-5.7.0.7z"
    FILENAME "qtbase-opensource-src-5.7.0.7z"
    SHA512 1898b0007d32b0ae6efa97178b069fe81abe93e7323788514663d1e2e9ccbeda618f4140935bdd54c7f8e1c36aa2fd5604412c469fc23dfda8c77cf09b9692ba
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Handle copyright
#file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt5-base)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/qt5-base/LICENSE ${CURRENT_PACKAGES_DIR}/share/qt5-base/copyright)
