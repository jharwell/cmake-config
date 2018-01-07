################################################################################
# Cmake Configuration Template
#
# Can be used for the root/top-level meta-project, or for a submodule.
#
################################################################################

# CMake version
cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

# I define the current target as the same as the directory that the
# CMakeLists.txt resides in--simpler that way.
get_filename_component(target ${CMAKE_CURRENT_LIST_DIR} NAME)

# The name of the target at the root of the project/repo gets a special name,
# because sometimes you need it in subdirs. Note that at the root
# target=root_target.
get_filename_component(root_target ${CMAKE_SOURCE_DIR} NAME)

project(${target} C CXX)

# Set a handy macro for determining if we are the root project/module in a
# cmake build/configure process.
if ("${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
  set(IS_ROOT_PROJECT TRUE)
else()
  set(IS_ROOT_PROJECT FALSE)
endif()

# Output some nice status info.
if(IS_ROOT_PROJECT)
  set(module_display "${root_target}")
else()
  set(module_display "${module_display}/${target}")
endif()
message(STATUS "Found ${module_display}")

################################################################################
# Cmake Environment                                                            #
################################################################################
include(${CMAKE_ROOT}/Modules/ExternalProject.cmake)

# Download repo with custom cmake config and register modules
if (IS_ROOT_PROJECT AND NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
  execute_process(COMMAND git submodule update --init cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(compile-options)
include(build-modes)
include(custom-cmds)
include(analysis)
include(doxygen)

# Set policies
set_policy(CMP0028 NEW) # ENABLE CMP0028: Double colon in target name means ALIAS or IMPORTED target.
set_policy(CMP0054 NEW) # ENABLE CMP0054: Only interpret if() arguments as variables or keywords when unquote2d.
set_policy(CMP0063 NEW) # ENABLE CMP0063: Honor visibility properties for all target types.

################################################################################
# Project Configuration                                                        #
################################################################################
if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "DEV")
endif()

# Handy checking tools
toggle_cppcheck(ON)
toggle_clang_tidy_check(ON)
toggle_clang_static_check(ON)
toggle_clang_format(ON)
toggle_clang_tidy_fix(ON)

option(SHARED_LIBS    "Build shared instead of static libraries."              ON)
option(WITH_CHECKS    "Build in run-time checking of code."                    OFF)
option(SELF_CONTAINED "Create a self-contained install with all dependencies." OFF)
option(BUILD_TESTS    "Build tests."                                           OFF)
option(WITH_OPENMP    "Enable OpenMP code."                                    ON)
option(WITH_MPI       "Enable MPI code."                                       OFF)
option(WITH_FPC       "FPC_RETURN or FPC_ABORT"                                FPC_ABORT)
set(FPC FPC_TYPE="${WITH_FPC}")

# Set output directories. If we are the root project, then this is
# necessary. If not, we simply re-set the same values.
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

################################################################################
# Source Definitions                                                           #
################################################################################
# Sources
set(${target}_SRC_PATH "${CMAKE_CURRENT_SOURCE_DIR}/src")
file(GLOB_RECURSE ${target}_ROOT_SRC ${${target}_SRC_PATH}/*.c ${${target}_SRC_PATH}/*.cpp)
file(GLOB ${target}_SRC ${${target}_SRC_PATH}/*.c ${${target}_SRC_PATH}/*.cpp)
file(GLOB ${target}_C_SRC ${${target}_SRC_PATH}/*.c )
file(GLOB ${target}_CXX_SRC ${${target}_SRC_PATH}/*.cpp)

set(${target}_INC_PATH "${CMAKE_CURRENT_SOURCE_DIR}/include/")
set(${target}_ROOT_INC_PATH "${CMAKE_SOURCE_DIR}/include/")

# Tests
#
# Might need the common test definitions under src/tests/include, so add it to
# the global include path.
include_directories(src/tests/include)

set(${target}_TEST_PATH ${CMAKE_CURRENT_SOURCE_DIR}/tests)
file(GLOB c_tests ${${target}_TEST_PATH}/*-test.c)
file(GLOB c_test_harness ${${target}_TEST_PATH}/*_test.c ${${target}_TEST_PATH}/*.h ${${target}_TEST_PATH}/*.hpp)
file(GLOB cxx_tests ${${target}_TEST_PATH}/*-test.cpp)
file(GLOB cxx_test_harness ${${target}_TEST_PATH}/*_test.cpp  ${${target}_TEST_PATH}/*.hpp)

################################################################################
# Target Definitions                                                           #
################################################################################
# now we can add project-local config
if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/project-local.cmake )
  set(current_proj_name ${target})
  include(${CMAKE_CURRENT_LIST_DIR}/project-local.cmake OPTIONAL)
endif()

# We are not the root project--we are a submodule. Add ourselves to the
# dependencies of the root target.
if (NOT IS_ROOT_PROJECT)
  # For my projects, all submodules EXCEPT one called tests are assumed to be
  # OBJECT libraries (i.e. transient targets only for logical organization
  # that are all rolled into the binary blob of the root target).
  if (NOT "${target}" STREQUAL "tests")

    # We may actually be part of a larger project, and thus our target has
    # already been created but a separate submodule depending on us.
    if (NOT TARGET ${target})

      # If you have two different projects with the same submodule, say
      # 'common', then you will need to prefix the targets with the project
      # name so that they are unique and all your sources end up getting
      # compiled. Because you need to handle *NOT* adding a target if it
      # already exists, not doing this will inexplicably leave some source
      # files out of compilation of the module that gets processed SECOND by
      # cmake.
      #
      # It's safer just to do this all the time
      if (${target} STREQUAL "${current_proj_name}")
        add_library(${target} OBJECT ${${target}_SRC})
      else()
        add_library(${current_proj_name}-${target} OBJECT ${${target}_SRC})
      endif()
    endif()
    else() # handling tests submodule
      if (NOT TARGET ${target})
        if (${target} STREQUAL "${current_proj_name}")
          add_library(${target} OBJECT ${${target}_SRC})
        else()
          add_library(${current_proj_name}-${target} ${${target}_SRC})
        endif()
      endif()
  endif()
endif()

################################################################################
# Code Checking/Analysis Options                                               #
################################################################################
# If the root project declared itself to have recursive dirs
# (i.e. semi-independent subjprojects, then register each submodules' source
# independently so that it can be built/checked independently. Otherwise, add
# the source as one big blob.)
if (${${root_target}_HAS_RECURSIVE_DIRS})
  if (NOT IS_ROOT_PROJECT)
    register_checkers(${target} ${${target}_SRC})
    register_auto_formatters(${target} ${${target}_SRC})
    register_auto_fixers(${target} ${${target}_SRC})
  endif()
else()
  if (IS_ROOT_PROJECT)
    register_checkers(${target} ${${target}_ROOT_SRC})
    register_auto_formatters(${target} ${${target}_ROOT_SRC})
    register_auto_fixers(${target} ${${target}_ROOT_SRC})
  endif()
endif()

################################################################################
# Testing Options                                                              #
################################################################################
if (BUILD_TESTS)
  include(testing)
endif()

################################################################################
# Deployment Options                                                           #
################################################################################
if (IS_ROOT_PROJECT)
  include(deploy)
endif()