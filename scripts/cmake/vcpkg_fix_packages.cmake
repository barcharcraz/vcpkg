function(vcpkg_fix_packages)
    file(GLOB_RECURSE _debug_confs
        *debug.cmake)
    foreach(_file in ${_debug_confs})
        file(READ ${_file} _content)
        string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" _content "${_content}")
        file(WRITE ${_file} "${_content}")
    endforeach()
endfunction()