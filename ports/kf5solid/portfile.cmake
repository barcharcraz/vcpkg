# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/solid-5.28.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/KDE/solid/archive/v5.28.0.tar.gz"
    FILENAME "solid-5.28.0.tar.gz"
    SHA512 e4c6fadd8398a1c981c03fa7fdaa54a7ecdd3280254eaee3e3e2b20a05cbfb42c02444d8fc83b4e3b84729ae92ea34e121229e77aaad58b4579e0e9b77619be7
)

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_CMAKEPACKAGEDIR=share
        -DKDE_INSTALL_LIBEXECDIR=tools
        -DKDE_INSTALL_DATAROOTDIR=share/data
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_QMLDIR=share/qt5/qml
        -DFLEX_EXECUTABLE=${FLEX}
        -DBISON_EXECUTABLE=${BISON}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/tools)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(GLOB _tools ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
foreach(_file ${_tools})
    file(REMOVE ${_file})
endforeach()
file(GLOB _tools ${CURRENT_PACKAGES_DIR}/bin/*.exe)
foreach(_file ${_tools})
    get_filename_component(_file_r ${_file} NAME)
    file(RENAME ${_file} ${CURRENT_PACKAGES_DIR}/tools/${_file_r})
endforeach()
file(COPY ${CURRENT_PACKAGES_DIR}/debug/share/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
vcpkg_fix_packages()
# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/KF5Solid)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/KF5Solid/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/KF5Solid/copyright)
#file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/KF5Archive)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/KF5Archive/COPYING ${CURRENT_PACKAGES_DIR}/share/KF5Archive/copyright-gpl)
