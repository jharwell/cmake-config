set(CLANG_FORMAT_ENABLED OFF)

# Function to register a target for clang_format
function(register_clang_format check_target target)
  if (${${root_target}_HAS_RECURSIVE_DIRS})
    file(GLOB INCLUDES ${CMAKE_SOURCE_DIR}/include/${root_target}/${target}/*.hpp
      ${CMAKE_SOURCE_DIR}/include/${root_target}/*/${target}/*.hpp)
    else()
    file(GLOB INCLUDES ${CMAKE_SOURCE_DIR}/include/${root_target}/*/*.hpp)
  endif()
  add_custom_target(
    ${check_target}
    COMMAND
    ${clang_format_EXECUTABLE}
    -style=file
    -i
    ${ARGN} ${INCLUDES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )


  set_target_properties(${check_target}
    PROPERTIES
    EXCLUDE_FROM_DEFAULT_BUILD 1
    )

  add_dependencies(${check_target} ${target})
endfunction()

# Enable or disable clang_format for auto-formatting
function(toggle_clang_format status)
    if(NOT ${status})
      set(CLANG_FORMAT_ENABLED ${status} PARENT_SCOPE)
      if (IS_ROOT_PROJECT)
        message(STATUS "  Formatter clang-format skipped: [disabled]")
        endif()
        return()
    endif()

    find_package(clang_format)

    if(NOT clang_format_FOUND)
      set(CLANG_FORMAT_ENABLED OFF PARENT_SCOPE)
      if (IS_ROOT_PROJECT)
        message(WARNING "  Formatter clang-format [clang-format not found]")
      endif()
        return()
    endif()

    set(CLANG_FORMAT_ENABLED ${status} PARENT_SCOPE)
    if (IS_ROOT_PROJECT)
      message(STATUS "  Formatter clang-format [enabled]")
    endif()
endfunction()