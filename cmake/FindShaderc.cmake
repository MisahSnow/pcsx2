# - Try to find SHADERC
# Once done this will define
#  SHADERC_FOUND - System has SHADERC
#  SHADERC_INCLUDE_DIRS - The SHADERC include directories
#  SHADERC_LIBRARIES - The libraries needed to use SHADERC

find_package(unofficial-shaderc CONFIG QUIET)
if(TARGET unofficial::shaderc::shaderc)
    set(SHADERC_FOUND TRUE)
    set(SHADERC_LIBRARIES unofficial::shaderc::shaderc)
    get_target_property(_SHADERC_INCLUDES unofficial::shaderc::shaderc INTERFACE_INCLUDE_DIRECTORIES)
    set(SHADERC_INCLUDE_DIR ${_SHADERC_INCLUDES})
    if(NOT TARGET Shaderc::shaderc_shared)
        add_library(Shaderc::shaderc_shared INTERFACE IMPORTED)
        set_target_properties(Shaderc::shaderc_shared PROPERTIES
            INTERFACE_LINK_LIBRARIES unofficial::shaderc::shaderc
            INTERFACE_INCLUDE_DIRECTORIES "${_SHADERC_INCLUDES}"
        )
    endif()
endif()

if(SHADERC_FOUND)
    mark_as_advanced(SHADERC_INCLUDE_DIR SHADERC_LIBRARY)
    return()
endif()

find_path(
    SHADERC_INCLUDE_DIR shaderc/shaderc.h
    ${SHADERC_PATH_INCLUDES}
)

find_library(
    SHADERC_LIBRARY
    NAMES shaderc_shared.1 shaderc_shared
    PATHS ${ADDITIONAL_LIBRARY_PATHS} ${SHADERC_PATH_LIB}
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Shaderc DEFAULT_MSG
                                  SHADERC_LIBRARY SHADERC_INCLUDE_DIR)

if(SHADERC_FOUND)
    add_library(Shaderc::shaderc_shared UNKNOWN IMPORTED)
    set_target_properties(Shaderc::shaderc_shared PROPERTIES
        IMPORTED_LOCATION ${SHADERC_LIBRARY}
        INTERFACE_INCLUDE_DIRECTORIES ${SHADERC_INCLUDE_DIR}
        INTERFACE_COMPILE_DEFINITIONS "SHADERC_SHAREDLIB"
    )
endif()

mark_as_advanced(SHADERC_INCLUDE_DIR SHADERC_LIBRARY)
