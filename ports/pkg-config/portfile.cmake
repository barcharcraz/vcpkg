# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jpakkane/pkg-config
    HEAD_REF master
    REF 7a13cbd2e67c047797735f0a8495d0e96ab7cf65
    SHA512 800ce1cd496b3bbf1a3a382f7baf6e7bc742d33b8763f56ec71cbb20a19e63fb3e13fbd4f0a6e4db5db697d5fc5727a40306c15708dff4c3e37669b203ebd11c
)

vcpkg_find_acquire_program(MESON)


vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_meson()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pkg-config RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME pkg-config)
