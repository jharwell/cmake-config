Requirements to use LIBRA
=========================

Platform Requirements
---------------------

- A recent version of Linux.

- cmake >= 3.9 (``cmake`` on ubuntu)

- make >= 3.2 (``make`` on ubuntu)

- cppcheck >= 1.72. (``cppcheck`` on ubuntu)

- graphviz (``graphviz`` on ubuntu)

- doxygen (``doxygen`` on ubuntu)

- gcc/g++ >= 9.0 (``gcc-9`` on ubuntu). Only required if you want to use the GNU
  compilers. If you want to use another compiler, this is not required. gcc-9
  rather than gcc-8 is required for C++17 because of std::filesystem usage,
  which does not work well with gcc-8 on ubuntu.

- icpc/icc >= 18.0. Only required if you want to use the Intel
  compilers. If you want to use another compiler, this is not required.

- clang/clang++ >= 6.0. Only required if you want to use the LLVM compilers or
  any of the static checkers. If you want to use another compiler, this is not
  required.

Compiler Support
----------------

- ``g++/gcc``
- ``clang++/clang``
- ``icpc/icc``

A recent version of any supported compiler can be selected as the
``CMAKE_CXX_COMPILER`` via command line [Default=``g++``]. The correct compile
options will be populated (as in the ones defined in the corresponding .cmake
files in this repository). Same for ``CMAKE_C_COMPILER``. Note that the C and
CXX compiler vendors should always match, in order to avoid strange build
issues.

.. IMPORTANT:: If you are want to use the intel compiler suite, you will have to
               download and install it from Intel's website. It installs to a
               non-standard location, so prior to being able to use it in the
               terminal like clang or gcc, you will need to source the compiler
               definitions::

                 . /opt/intel/bin/compilervars.sh -arch intel64 -platform linux

               Assuming you have installed the suite to ``/opt/intel`` and are
               running bash.

Clang Tooling
-------------

Everything should have version >= 6.0 for best results. However, if that version
of the tools is not in the package repositories, you can replace it with 5.0 or
4.0, and things should still work.

- Base tooling and clang-check (``libclang-6.0-dev`` and ``clang-tools-6.0``).

- clang-format >= 6.0 (``clang-format-6.0``).

- clang-tidy >= 4.0 (``clang-tidy-6.0``).

Assumptions
-----------

LIBRA makes the following assumptions about all code repositories it is used as
the build framework for:

- All C++ source files end in ``.cpp``, and all C++ header files end in ``.hpp``.

- All C source files end in ``.c`` and all C header files end in ``.h``.

- All source files for a repository must live under ``src/`` in the root.

- All include files for a repository must live under ``include/<repo_name>`` in
  the root.

- All tests (either C or C++) for a project/submodule must live under the
  ``tests/`` directory in the root of the project, and should end in
  ``-test.cpp`` so it is clear they are not source files.

- If a C++ file lives under ``src/my_module/my_file.cpp`` then its corresponding
  include file is found under ``include/<repo_name>/my_module/my_file.hpp``
  (same idea for C, but with the corresponding extensions).

- All projects must include THIS repository as a submodule under ``libra/`` in
  the project root, and link a ``CmakeLists.txt`` in the root of the repository
  to the ``libra/cmake/project.cmake`` file in this repository.

- All projects must include a ``project-local.cmake`` in the root of the
  repository containing any project specific bits (i.e. adding subdirectories,
  what libraries to create, etc.).Within it, the following variables can be set
  to affect configuration:

  - ``set(${target}_CHECK_LANGUAGE "value")``. This should be specified BEFORE
    any subdirectories, external projects, etc. are specified. ``${target}`` is
    a variable handed to the project local file specifying the name of the
    executable/library to create. The ``"value"`` can be either "C" or "C++",
    and defines the language that the different checkers will use for checking
    the project.
