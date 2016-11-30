# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/kdoctools-5.28.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/KDE/kdoctools/archive/v5.28.0.tar.gz"
    FILENAME "kdoctools-5.28.0.tar.gz"
    SHA512 e960cb4771a7dbbcc974726efbf9a51fa3b4f2bf24289ae327772b7f22dea721333185d198f471dea033f04224acba27e5b2d46e2d3bc142c3da5b4013324b03
)
vcpkg_download_distfile(DTD
    URLS "http://docbook.org/xml/4.5/docbook-xml-4.5.zip"
    FILENAME "docbook-xml-4.5.zip"
    SHA512 1ee282fe86c9282610ee72c0e1d1acfc03f1afb9dc67166f438f2703109046479edb6329313ecb2949db27993077e077d111501c10b8769ebb20719eb6213d27
)
vcpkg_download_distfile(XSL
    URLS "http://downloads.sourceforge.net/docbook/docbook-xsl-1.78.1.tar.bz2"
    FILENAME "docbook-xsl-1.78.1.tar.bz2"
    SHA512 0a5ca95e6e451192c4edf15d2b72c716935ce6df0c70c1974f794f0085db8f52f3e1f470435b6a77ec7c0f67e32c189a4dd334305e609031173444d5818767f3
)

vcpkg_extract_source_archive(${ARCHIVE})
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/data/xml/docbook/schema/dtd/4.5)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/share/data/xml/docbook/schema/dtd/4.5)
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} -E tar xjf ${DTD}
    WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/data/xml/docbook/schema/dtd/4.5
    LOGNAME dtd-extract
)
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} -E tar xjf ${DTD}
    WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/share/data/xml/docbook/schema/dtd/4.5
    LOGNAME dtd-extract
)
vcpkg_extract_source_archive(${XSL})
file(COPY ${CURRENT_BUILDTREES_DIR}/src/docbook-xsl-1.78.1/
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/data/xml/docbook/stylesheet/docbook-xsl)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/docbook-xsl-1.78.1/
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/share/data/xml/docbook/stylesheet/docbook-xsl)
vcpkg_find_acquire_program(MSGMERGE)
vcpkg_find_acquire_program(MSGFMT)
vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_DIR ${PERL} DIRECTORY)
set(ENV{PATH} "${PERL_DIR};$ENV{PATH}")
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_CMAKEPACKAGEDIR=share
        -DKDE_INSTALL_LIBEXECDIR=tools
        -DKDE_INSTALL_DATAROOTDIR=share/data
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DGETTEXT_MSGMERGE_EXECUTABLE=${MSGMERGE}
        -DGETTEXT_MSGFMT_EXECUTABLE=${MSGFMT}
        -DPYTHON_EXECUTABLE=${PYTHON3}
        -DPERL_EXECUTABLE=${PERL}
        -DLIBXML2_XMLLINT_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/xmllint.exe
        -DLIBXSLT_XSLTPROC_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/xsltproc.exe
    OPTIONS_RELEASE  
        -DDocBookXSL_DIR=${CURRENT_PACKAGES_DIR}/share/data/xml/docbook/stylesheet/docbook-xsl
    OPTIONS_DEBUG
        -DDocBookXSL_DIR=${CURRENT_PACKAGES_DIR}/debug/share/data/xml/docbook/stylesheet/docbook-xsl

    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

# this code is copied from vcpkg_install cmake
# we need copy it here because we need to change the path between steps
# or else the build will fail for mysterious reasons
set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/bin;$ENV{PATH}")
message(STATUS "Package ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} --build . --config Release --target install -- /m
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME package-${TARGET_TRIPLET}-rel
)
message(STATUS "Package ${TARGET_TRIPLET}-rel done")
set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/debug/bin;$ENV{PATH}")
message(STATUS "Package ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} --build . --config Debug --target install -- /m
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME package-${TARGET_TRIPLET}-dbg
)
message(STATUS "Package ${TARGET_TRIPLET}-dbg done")

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
file(WRITE ${CURRENT_PACKAGES_DIR}/share/data/xml/docbook/stylesheet/docbook-xsl/doc/empty "")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)

vcpkg_fix_packages()
# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/KF5DocTools)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/KF5DocTools/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/KF5DocTools/copyright)
#file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/KF5Archive)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/KF5Archive/COPYING ${CURRENT_PACKAGES_DIR}/share/KF5Archive/copyright-gpl)
