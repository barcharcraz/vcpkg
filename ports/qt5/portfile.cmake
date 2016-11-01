# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet. Portfile not modified for static and blocked on harfbuzz.")
endif()
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/qtbase-opensource-src-5.7.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.qt.io/official_releases/qt/5.7/5.7.0/single/qt-everywhere-opensource-src-5.7.0.7z"
    FILENAME "qt-5.7.0.7z"
    SHA512 96f0b6bd221be0ed819bc9b52eefcee1774945e25b89169fa927148c1c4a2d85faf63b1d09ef5067573bda9bbf1270fce5f181d086bfe585ddbad4cd77f7f418
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_find_acquire_program(JOM)
vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PERL ${PERL} DIRECTORY)
set(ENV{LIB} "$ENV{LIB};${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib")
set(ENV{PATH} "$ENV{PATH};${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/bin;${PERL}")
set(ENV{INCLUDE} "$ENV{INCLUDE};${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include")

file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES 
    ${CMAKE_CURRENT_LIST_DIR}/000_patch_libpng.patch
    ${CMAKE_CURRENT_LIST_DIR}/000_patch_libjpeg.patch
)

message(STATUS "Configure ${TARGET_TRIPLET}")

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
    -force-debug-info
    -opengl desktop
    -no-angle
    -debug-and-release
    -skip webengine
    -prefix ${CURRENT_PACKAGES_DIR}
    ZLIB_LIBS="zlib.lib"
    LOGNAME configure
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

message(STATUS "building ${TARGET_TRIPLET}")
vcpkg_execute_required_process(COMMAND ${JOM}
    LOGNAME build
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
message(STATUS "installing ${TARGET_TRIPLET}")
vcpkg_execute_required_process(COMMAND ${JOM} install
    LOGNAME install
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

file(GLOB DEBUG_DLLS
    "${CURRENT_PACKAGES_DIR}/bin/*d.dll"
    "${CURRENT_PACKAGES_DIR}/bin/*d.pdb")
file(GLOB DEBUG_LIBS
    "${CURRENT_PACKAGES_DIR}/lib/*d.lib"
    "${CURRENT_PACKAGES_DIR}/lib/*d.prl"
    "${CURRENT_PACKAGES_DIR}/lib/*d.pdb")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
foreach(file ${DEBUG_DLLS})
    get_filename_component(file_n ${file} NAME)
    file(RENAME ${file} "${CURRENT_PACKAGES_DIR}/debug/bin/${file_n}")
endforeach()
foreach(file ${DEBUG_LIBS})
    get_filename_component(file_n ${file} NAME)
    file(RENAME ${file} "${CURRENT_PACKAGES_DIR}/debug/lib/${file_n}")
endforeach()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share")
file(RENAME "${CURRENT_PACKAGES_DIR}/mkspecs" "${CURRENT_PACKAGES_DIR}/share/mkspecs")
file(RENAME "${CURRENT_PACKAGES_DIR}/doc" "${CURRENT_PACKAGES_DIR}/share/doc")
#file(RENAME "${CURRENT_PACKAGES_DIR}/plugins" "${CURRENT_PACKAGES_DIR}/share/plugins")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/plugins")
file(GLOB_RECURSE DEBUG_PLUGINS
    "${CURRENT_PACKAGES_DIR}/plugins/*d.dll"
    "${CURRENT_PACKAGES_DIR}/plugins/*d.pdb")
foreach(file ${DEBUG_PLUGINS})
    get_filename_component(file_n ${file} NAME)
    file(RELATIVE_PATH file_rel "${CURRENT_PACKAGES_DIR}/plugins" ${file})
    get_filename_component(rel_dir ${file_rel} DIRECTORY)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/plugins/${rel_dir}")
    file(RENAME ${file} "${CURRENT_PACKAGES_DIR}/debug/plugins/${rel_dir}/${file_n}")
endforeach()

file(GLOB TOOLS
    "${CURRENT_PACKAGES_DIR}/bin/*.exe"
    "${CURRENT_PACKAGES_DIR}/bin/*.pl")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
foreach(file ${TOOLS})
    get_filename_component(file_n ${file} NAME)
    file(RENAME "${file}" "${CURRENT_PACKAGES_DIR}/tools/${file_n}")
endforeach()
file(GLOB TOOLS_PDB
    "${CURRENT_PACKAGES_DIR}/bin/*.pdb")
file(REMOVE ${TOOLS_PDB})
vcpkg_execute_required_process(COMMAND ${PYTHON3} ${CMAKE_CURRENT_LIST_DIR}/fix-cmake.py
    WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR})
#deal with cmake files
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/ DESTINATION ${CURRENT_PACKAGES_DIR}/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(GLOB QT_LICENSE
    "${SOURCE_PATH}/LICENSE*"
    "${SOURCE_PATH}/LGPL_EXCEPTION.txt")
foreach(file ${QT_LICENSE})
    file(READ ${file} txt)
    get_filename_component(file_n ${file} NAME)
    file(APPEND ${CURRENT_PACKAGES_DIR}/share/qt5-base/copyright
     "${file_n}\n\n${txt}")
     file(COPY ${file} DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt5-base/${file_n})
endforeach()

#file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt5-base)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/qt5-base/LICENSE ${CURRENT_PACKAGES_DIR}/share/qt5-base/copyright)
