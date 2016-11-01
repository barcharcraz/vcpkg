# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/qt)
set(JOM_PATH ${CURRENT_BUILDTREES_DIR}/src)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.qt.io/official_releases/qt/5.7/5.7.0/single/qt-everywhere-opensource-src-5.7.0.tar.gz"
    FILENAME "qt-5.7.0.tar.gz"
    SHA512 bde74a474da192785ff8db5565db03685411b577bf29e999f72b92e4f6d406a6dfd266b612c9fe56a996f717ab32811e9396ada3c0d5ce5bc2c3d137b6533174
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_extract_source_archive(${JOM_ARCHIVE})
# we need to make the path shorter
if(EXISTS ${CURRENT_BUILDTREES_DIR}/src/qt-everywhere-opensource-src-5.7.0)
    file(RENAME ${CURRENT_BUILDTREES_DIR}/src/qt-everywhere-opensource-src-5.7.0 ${CURRENT_BUILDTREES_DIR}/src/qt)
endif()
vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(JOM)
#vcpkg_find_acquire_program(PYTHON3)
file(DOWNLOAD "http://www.orbitals.com/programs/py.exe" "${CURRENT_BUILDTREES_DIR}/src/python.exe"
    EXPECTED_HASH SHA512=28286bf6c510a4596c49e3100b7c45e5ccceac70404fdda436704b12874ec267617614002675f51b9f02c8b509cacee9aae60fc0c1b3e921755b0d47490a0744)
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES 
    ${CMAKE_CURRENT_LIST_DIR}/000-fix-assimp-imports.patch
    ${CMAKE_CURRENT_LIST_DIR}/000_patch_libpng.patch
    ${CMAKE_CURRENT_LIST_DIR}/000_patch_libjpeg.patch
    ${CMAKE_CURRENT_LIST_DIR}/001_fix_webengine_path.patch
)
set(ENV{LIB} "$ENV{LIB};${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib")
set(ENV{INCLUDE} "$ENV{INCLUDE};${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include")
# need our dependencies for running moc and rcc during the build process
#get_filename_component(PYTHON3 ${PYTHON3} DIRECTORY)
get_filename_component(PERL ${PERL} DIRECTORY)
message(STATUS ${PYTHON3})
message(STATUS ${PERL})
set(ENV{PATH} "$ENV{PATH};${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/bin;${PERL}")
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
message(STATUS "configuring debug")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(QT_RUNTIME_LINKAGE "-static")
else()
    set(QT_RUNTIME_LINKAGE "-shared")
endif()
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(QT_CRT_LINKAGE "-static-runtime")
endif()
vcpkg_execute_required_process(COMMAND ${SOURCE_PATH}/configure.bat 
    -opensource
    -confirm-license
    -nomake tests
    -nomake examples
    -system-zlib 
    -system-libjpeg 
    -system-libpng 
    -system-freetype 
    -system-pcre
    -system-harfbuzz 
    -system-sqlite
    -system-doubleconversion
    ${QT_RUNTIME_LINKAGE}
    ${QT_CRT_LINKAGE}
    -opengl dynamic
    -debug
    -prefix ${CURRENT_PACKAGES_DIR}
    ZLIB_LIBS="zlib.lib"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

message(STATUS "building debug")
vcpkg_execute_required_process(COMMAND ${JOM}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

# Handle copyright
#file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt5)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/qt5/LICENSE ${CURRENT_PACKAGES_DIR}/share/qt5/copyright)
