C++ Development Guide
=====================

Coding Style
------------

Follows the Google C++ style guide, except in the ways noted in the following
subsections.

Files
#####

- All source files have the ``.cpp`` extension, and all header files have the
  ``.hpp`` extension (not a ``.h`` extension), to clearly distinguish them from
  C code, and not to confuse the tools used.

- Exactly one class/struct definition per ``.cpp``\/``.hpp`` file, unless there
  is a very good reason to do otherwise. class/struct definitions nested within
  other classes/structs are exempt from this rule, but their use should still be
  minimized and well documented if they reside in the ``public`` part of the
  enclosing class.

- The namespace hierarchy exactly corresponds to the directory hierarchy that
  the source/header files for classes can be found in.

Naming
######

- All file, class, variable, enum, namespace, etc. names are
  ``specified_like_this``, NOT ``specifiedLikeThis`` or
  ``SpecifiedLikeThis``. Rationale: Most of the time you shouldnot really need
  to know whether the thing in between ``::`` is a class, namespace, enum,
  etc. You really only need to know what operations it has. This also makes the
  code play nicely with the STL/boost from a readability point of view.

- All structs that are "types" (e.g. convenient wrappers around a boolean
  status + possibly valid result of an operation) should have a ``_t`` postfix
  so that it is clear when constructing them that they are types and it is not a
  function being called (calls with ``()`` can seem ambiguous if you don't know
  the code). Types are collections of data members that generally should be
  treatable as POD, even if they are not (e.g. contain a std::vector).

- All mathematical constants (e.g. ints, doubles, etc) should be
  ``kSPECIFIED_LIKE_THIS``: MACRO CASE + a preceding ``k``.

- All static class constants (you should not have non-static class constants)
  that are any kind of object should be ``kSpecifiedLikeThis``: Upper
  CamelCase + a preceding ``k``.

- All enum values should be ``ekSPECIFIED_LIKE_THIS``: MACRO_CASE + a preceding
  ``ek``. The rationale for this is that it is useful to be able to tell at a
  glance if a constant is a mathematical one or only serves as a logical
  placeholder to make the code more understandable. The preceding ``ek`` does
  hinder at-a-glance readability somewhat, but that is outweighed by the
  increased at-a-glance code comprehension.

- All template parameters should be in ``CamelCase`` and preceded with a
  ``T``. This is to make it very easy to tell at a glance that something is a
  template parameter, rather than an object type, in a templated class/function.

- All enum names should be postfixed with ``_type``, in order to enforce
  semantic similarity between members when possible (i.e. if it does not make
  sense to do this, should you really be using an enum vs. a collection of
  ``constexpr`` values?).

- ``#define`` for literal constants should be avoided, as it pollutes the global
  namespace. ``constexpr`` values in an appropriate namespace should be used
  instead.

Class Layout
############

- Follow the Google C++ style ordering: ``public`` -> ``protected`` ->
  ``private`` layout, generally speaking. However, there are some cases when
  putting public accessors/mutators AFTER the declaration of private variables
  which they access/modify is required (e.g. ``RCPPSW_WRAP_FUNC()``).

- Within each access modifier section, the layout should be (in order):

    - ``using`` declarations (types or functions from base classes).
    - Type definitions.
    - Class constants (should hopefully be ``static constexpr const``).
    - Functions.

  The choice of this ordering is somewhat arbitrary, but it is necessary to have
  SOME sort of ordering, and this is already how I was generally doing most
  classes.

- Within the ``public`` section, the constructor, destructor, and any copy/move
  operators should be listed first among all the functions.

Miscellaneous
#############

- Always use strongly typed enums (class enums) whenever possible to avoid name
  collisions. Sometimes this is not possible without extensive code contortions.

- Non-const static variables should be avoided.

- Do not use Hungarian notation. Linus was right--it _is_ brain damaged.

- Class nesting should be avoided.

Linting
-------

Code should pass the google C++ linter, ignoring the following items. For
everything else, the linter warnings should be addressed.

- Use of non-const references--I do this regularly. When possible, const
  references should be used, but sometimes it is more expressive and
  self-documenting to use a non-const reference in many cases.

- Header ordering (this is done by ``clang-format``, as configured.

- Line length >= 80 ONLY if it is only 1-2 chars too long, and breaking the
  line would decrease readability. The formatter generally takes care of this.

Code should pass the clang-tidy linter, which checks for style elements like:

- All members prefixed with ``m_``

- All constant members prefixed with ``mc_``.

- All global variables prefixed with ``g_``.

- All functions less than 100 lines, with no more than 5 parameters/10
  branches. If you have something longer than this, 9/10 times it can and
  should be split up.

Function Parameters
-------------------

Most of these are from Herb Sutter's excellent C++ guidelines on smart pointers
[here](https://herbsutter.com/2013/05/29/gotw-89-solution-smart-pointers/)).

- If a constructor has more than 3-5 parameters, *especially* if many/all of the
  parameters are primitive types the compiler will silently convert (a
  ``double`` is passed where an ``int`` is expected, for example), then the
  constructor should be made to take a pointer/lvalue reference/rvalue reference
  to a parameter struct containing tnhe primitive members, in order to reduce
  the chance of subtle bugs due to silent primitive conversions if the order of
  two of the parameters is swapped at the call site.

- Function inputs should use ``const`` to indicate that the parameter is
  input-only (``&`` or ``*``), and cannot be modified in the function body.

- Function inputs should use ``&&`` to indicate the the parameter will be
  consumed by the function and further use after the function is called is
  invalid.

- Function inputs should pass by reference (not by constant reference), to
  indicate that the parameter is an input-output parameter. The number of
  parameters of this type should be minimized.

- Only primitive types should be passed by value; all other more complex types
  should be passed by reference, constant reference, or by pointer. If for some
  reason you *DO* pass a non-primitive type by value, the doxygen function
  header should clearly explain why.

- ``std::shared_ptr`` should be passed by VALUE to a function when the function
  is going to take a copy and share ownership, and ONLY then.

- Pass ``std::shared_ptr`` by ``&`` if the function is itself not going to take
  ownership, but a function/object that it calls will. This will avoid the copy
  on calls that don't need it.

- ``const std::shared_ptr<T>&`` should be not be used--use ``const T*`` to indicate
  non-owning access to the managed object.

- ``std::unique_ptr`` should be passed by VALUE to a "consuming" function
  (i.e. whatever function is ultimately going to claim ownership of the object).

- ``std::unique_ptr`` should NOT be passed by reference, unless the function
  needs to replace/update/etc the object contained in the unique_ptr. It should
  never be passed by constant reference.

- Raw pointers should be used to express the idea that the pointed to object is
  going to outlive the function call and the function is just going to
  observe/modify it (i.e. non-owning access).

- ``const`` parameters should be declared before non-``const`` parameters when
  possible, unless doing so would make the semantics of the function not make
  sense.

Documentation
-------------

As I was told in my youth::

  If it is hard to document, it is probably wrong

To that end all contributions *must* be properly documented.

- All classes should have:

    - A doxygen brief
    - A group tag
    - A detailed description for non-casual users of the class

- All non-getter/non-setter member functions should be documentated with at
  least a brief, UNLESS those functions are overrides/inherited from a parent
  class, in which case they should be left blank (usually) and their
  documentation be in the class in which they are initially declared. All
  parameters should be documented.

Tricky/nuanced issues with member variables should be documented, though in
general the namespace name + class name + member variable name + member variable
type should be enough documentation. If its not, chances are you are naming
things somewhat obfuscatingly and need to refactor.

Testing
-------

As I was also told in my youth::

  If it is hard to test, it is almost assuredly wrong

To that end, all NEW classes should have some basic unit tests associated with
them, when possible (one for each major public function that the class
provides). For any *existing* classes that have *new* public functions added, a
new unit test should also be added. It is not possible to create unit tests for
all classes, as some can only be tested in an integrated manner, but there many
that can and should be tested in a stand alone fashion.
