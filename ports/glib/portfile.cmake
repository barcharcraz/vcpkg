include(vcpkg_common_functions)

# Glib uses winapi functions not available in WindowsStore
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are currently not supported.")
endif()

# Glib relies on DllMain on Windows
if (NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)
endif()

include(vcpkg_common_functions)
if(CMAKE_HOST_WIN32)
 vcpkg_acquire_msys(MSYS_ROOT PACKAGES "mingw-w64-i686-pkg-config")
 set(ENV{PKG_CONFIG} "${MSYS_ROOT}/mingw32/bin/pkg-config.exe")
endif()

set(GLIB_VERSION 2.60.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/gnome/sources/glib/2.60/glib-${GLIB_VERSION}.tar.xz"
    FILENAME "glib-${GLIB_VERSION}.tar.xz"
    SHA512 38479c8e48fda5adaa5f7ac8e1f09c184be48adf38ab614eb69f8e11301a1b0235767abf556e09fd4d5df345822db5b3dc85d1c53d05fdba1c1b40f75b61777b)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GLIB_VERSION}
)

# file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
# file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH})
# file(REMOVE_RECURSE ${SOURCE_PATH}/glib/pcre)
# file(WRITE ${SOURCE_PATH}/glib/pcre/Makefile.in)
# file(REMOVE ${SOURCE_PATH}/glib/win_iconv.c)
if(VCPKG_BUILD_TYPE STREQUAL "release")
 set(ENV{PKG_CONFIG_LIBDIR} "${CURRENT_PACKAGES_DIR}/lib")
endif()
if(VCPKG_BUILD_TYPE STREQUAL "debug")
 set(ENV{PKG_CONFIG_LIBDIR} "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()
vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
)
# vcpkg_configure_cmake(
#     SOURCE_PATH ${SOURCE_PATH}
#     PREFER_NINJA
#     OPTIONS
#         -DGLIB_VERSION=${GLIB_VERSION}
#     OPTIONS_DEBUG
#         -DGLIB_SKIP_HEADERS=ON
#         -DGLIB_SKIP_TOOLS=ON
# )

# vcpkg_install_cmake()
# vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-glib TARGET_PATH share/unofficial-glib)

# vcpkg_copy_pdbs()
# vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/glib)

# file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/glib)
# file(RENAME ${CURRENT_PACKAGES_DIR}/share/glib/COPYING ${CURRENT_PACKAGES_DIR}/share/glib/copyright)

