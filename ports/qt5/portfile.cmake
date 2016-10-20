# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/qt-everywhere-opensource-src-5.7.0)
set(JOM_PATH ${CURRENT_BUILDTREES_DIR}/src)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.qt.io/official_releases/qt/5.7/5.7.0/single/qt-everywhere-opensource-src-5.7.0.tar.gz"
    FILENAME "qt-5.7.0.tar.gz"
    SHA512 bde74a474da192785ff8db5565db03685411b577bf29e999f72b92e4f6d406a6dfd266b612c9fe56a996f717ab32811e9396ada3c0d5ce5bc2c3d137b6533174
)
vcpkg_download_distfile(JOM_ARCHIVE
    URLS "http://download.qt.io/official_releases/jom/jom_1_1_1.zip"
    FILENAME "jom-1.1.0.zip"
    SHA512 23a26dc7e29979bec5dcd3bfcabf76397b93ace64f5d46f2254d6420158bac5eff1c1a8454e3427e7a2fe2c233c5f2cffc87b376772399e12e40b51be2c065f4
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_extract_source_archive(${JOM_ARCHIVE})
set(ENV{LIB} "$ENV{LIB};${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib")
set(ENV{INCLUDE} "$ENV{INCLUDE};${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include")
vcpkg_execute_required_process(COMMAND ${SOURCE_PATH}/configure.bat 
    -opensource 
    -confirm-license 
    -nomake tests 
    -system-zlib 
    -system-libjpeg 
    -system-libpng 
    -system-freetype 
    -system-pcre 
    -system-harfbuzz 
    -system-sqlite
    -prefix ${CURRENT_PACKAGES_DIR}
    ZLIB_LIB="-lzlib"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)


# Handle copyright
#file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt5)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/qt5/LICENSE ${CURRENT_PACKAGES_DIR}/share/qt5/copyright)
