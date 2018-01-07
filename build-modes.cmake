################################################################################
# Development Mode                                                             #
################################################################################
set(CDFLAGS "")
foreach(arg ${C_DIAG_OPTIONS} ${C_PARALLEL_OPTIONS} ${C_CHECK_OPTIONS} ${CC_DEV_DEFS} ${EXTRA_FLAGS})
  set(CDFLAGS "${CDFLAGS} ${arg}")
endforeach(arg)

set(CMAKE_C_FLAGS_DEV ${CDFLAGS} CACHE string
  "Flags used by the C compiler during development builds."
  FORCE)

set(CXXDFLAGS "")
foreach(arg ${CXX_DIAG_OPTIONS} ${CXX_PARALLEL_OPTIONS} ${CXX_CHECK_OPTIONS} ${CC_DEV_DEFS} ${EXTRA_FLAGS})
  set(CXXDFLAGS "${CXXDFLAGS} ${arg}")
endforeach(arg)

set(CMAKE_CXX_FLAGS_DEV ${CXXDFLAGS} CACHE string
  "Flags used by the CXX compiler during development builds."
  FORCE)

################################################################################
# Optimized Mode                                                               #
################################################################################
foreach(arg ${C_OPT_OPTIONS} ${C_DIAG_OPTIONS} ${C_PARALLEL_OPTIONS} ${CC_OPT_DEFS} ${EXTRA_FLAGS})
  set(OPTCFLAGS "${OPTCFLAGS} ${arg}")
endforeach(arg)

set(CMAKE_C_FLAGS_OPT ${OPTCFLAGS} CACHE string
  "Flags used by the C compiler during optimized builds."
  FORCE)

foreach(arg ${CXX_OPT_OPTIONS} ${CXX_DIAG_OPTIONS} ${CXX_PARALLEL_OPTIONS} ${CC_OPT_DEFS} ${EXTRA_FLAGS})
  set(OPTCXXFLAGS "${OPTCXXFLAGS} ${arg}")
endforeach(arg)

set(CMAKE_CXX_FLAGS_OPT ${OPTCXXFLAGS} CACHE string
  "Flags used by the C++ compiler during optimized builds."
  FORCE)

# Update the documentation string of CMAKE_BUILD_TYPE for GUIs
set( CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING
  "Choose the type of build, options are: DEV OPT."
      FORCE )