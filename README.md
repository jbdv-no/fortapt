# ForTAPt: A Fortran implementation of [http://testanything.org/](http://testanything.org/) (TAP)

Testing does not have to be complicated; without it we are lost.

TAP stands for Test Anything Protocol, and is a textual
protocol supported by many testing tools, and build servers
such as Jenkins.

[ForTAPt][1], or _Fortran Test Anything Protocol toolbox_, is a minimal modern
Fortran TAP implementation providing:
- TAP _producer_ module (inspired by Perl's Test::More module) made available in
  user code via `use fortapt_m` for creating tests, and
- command line TAP _consumer_ program / test runner `runtests` for running and
  summarizing test results.

The command line TAP consumer program, `runtests`, works as a simple test 
harness for bare needs. Perl's prove(1) can also be used for now as long as one 
remember to let the test programs have the suffix ".t"

The test module has some additions for comparing floating point
numbers: absolute and relative comparison with the subroutines
`isabs` and `isrel`, in addition to `isnear`, which uses division
instead of subtraction as `isabs`.

Other than that compile time overloading is used for the
subroutines `is` ~~and `isnt`~~. There is no support for subtests. They
would be nice to have, but you can just write more test programs
or use plain old subroutines to divide the work, so most likely
they will not be implemented.

There are also 2 public streams for test output and diagnostic
notes, which by default are assigned to `OUTPUT_UNIT` and
`ERROR_UNIT`.

See [http://testanything.org/tap-specification.html](http://testanything.org/tap-specification.html)
to understand the output that the test module is supposed to produce. The
subroutines are transparent and easy to understand once you understand the
simple test protocol (TAP).

The philosophy behind this implementation is to have something
simple to quickly get on with testing while at the same
time it is easy to modify and extend for one's own purpose:
All too often it is too difficult to remove something from
a library. It's better to strike a balance, and make it easy
to add to a library while still having an implementation that
takes care of the most common things.

[ForTAPt][1] comes with the OpenBSD/ISC license.

## Installation

[ForTAPt][1] is built and packaged using the open source Fortran Package Manager
[fpm][2], for trivial integration into user projects. 

The package is built simply by issuing the following command
```
fpm build
```
This creates a `./build/<FC>_<BUILD>` directory containing a static library
`fortapt/libfortapt`, the consumer program `app/runtest` and an example test
program `test/test_example`. 

By default, `<FC>=gfortran` and `<BUILD>=debug`. To build with e.g. `ifort` in
release mode, type
```
fpm build --release --compiler ifort
``` 
See [fpm's documentation][3] for other options and details.

To see the test harness in action, instruct fpm to run the test program using 
the test runner 
```
fpm test --runner ./build/gfortran_debug/app/runtests
```

To make [ForTAPt][1] a dependency of your own projects, simply by add the 
following lines to the `[[test]]` section of your project's `fpm.toml` file. 
```toml
fortapt = { git = "https://github.com/jbdv-no/fortapt.git"}
```


The `*.f90` Fortran source files making up `fortapt_m` are located in the 
`./src` directory - this includes `*.inc` files `is_int`, `isabs_real`, 
`isnear_real` and `isrel_real` that are `include`'d as 
[_poor man's_ templates](https://doi.org/10.1145/274104.274108) to
support different `integer` and `real` kinds. 

Source code for the command line TAP consumer program `runtests.f90` is found in
the `./app` folder, and source code of an example program `test_examples.f90`
illustrating the use of `fortrapt_m` is located in the `./test` folder.

While a `Makefile` replicating some of `fpm`'s behaviour is also provided, 
illustrating the use of ForTAPt for non-fpm projects, the build options are more
limited, and fpm should always be considered as the most up to date reference.

## Synopsis

```Fortran
use fortapt_m

call plan(23)
! or
call skip_all(reason)
! or see done_testing

! Various ways to say 'ok'
call ok(got .eq. expected, test_name) ! test names are optional

call   is(got, expected, test_name)
call isnt(got, expected, test_name)

call isabs(got, expected, epsilon, test_name)
call isrel(got, expected, epsilon, test_name)
call isnear(got, expected, test_name)

! Rather than WRITE (ERROR_UNIT,'(A)') "# here's what went wrong"
call diag("here's what went wrong")

if (.not. have_some_feature()) then
   call skip(why, how_many) ! how_many is optional and default 1
else
   call ok(foo(), test_name)
   call is(foo(42), 23, test_name)
   ! ...
end if

call todo(why, how_many)
call ok(foo(), test_name)
call is(foo(42), 23, test_name)
! ...

call pass(test_name)
call fail(test_name)

! Stop test program after writing why rather than ERROR STOP
call bail_out(why)
```

## Description

### Subroutines

  * `plan`/`skip_all`
  * `done_testing`
  * `ok`
  * `is`~~/`isnt`~~
  * `isabs`~~/`isntabs`~~
  * `isrel`~~/`isntrel`~~
  * `isnear`~~/`isntnear`~~
  * `pass`/`fail`
  * `skip`/`todo`
  * `note`/`diag`
  * `bail_out`

The examples use "`=>`" in a comment to indicate output.

See [http://search.cpan.org/~mschwern/Test-Simple/lib/Test/More.pm](http://search.cpan.org/~mschwern/Test-Simple/lib/Test/More.pm) for a more detailed explanation and raison d'être of the test 
routines.

## To plan or not to plan

The number of tests to run is part of a test program, so that the test
harness (TAP consumer) can report if any test wasn't run at all.

You indicate this either at the beginning or at the end of a test
program. The number of tests can be calculated in both instances.

Calling `skip_all` stops the test immediately after writing the reason why
on `TEST_UNIT`.

### Examples:

```Fortran
call plan(23)
! => 1..23

call plan(size(keys) * 3) ! Given size(keys) = 4
! => 1..12

call skip_all("Only relevant on OpenBSD")
! => 1..0 # Skipped: Only relevant on OpenBSD

call done_testing ! Simply does nothing if you planned ahead

call done_testing(11)
! => 1..11

call done_testing(cases * 5) ! Given cases = 6
! => 1..30
```

## Test names


Test names are optional, and by default nothing more than test result
"`ok`" or "`not ok`" including a test number is output. Including them gives
you an idea of what failed.

What would you rather see?

```
ok 34 - basic standard variance
not ok 35 - root mean square
ok 36 - volt == ampere * ohm
```

or

```
ok 34
not ok 35
ok 36
```

It also makes it easier to find tests in your program, e.g. it's easier
to search for "root mean square" than "35". On the other hand the test
number uniquely identifies a test.

### Examples:

```Fortran
call ok(3 == 3, 'Integer equivalence')
! => ok 1 - Integer equivalence

call ok(leq("Dines", "Dennis"))
! => not ok 2

call is(5, 2+2, '2 + 2 == 5')
! => not ok 3 - 2 + 2 == 5
! => #  Failed test '2 + 2 == 5'
! => #       got: 4
! => #  expected: 5
```

A failed test outputs some more diagnostic output about why. Diagnostic
output lines begins with a number sign (octothorpe), "`#`".

## How tests do comparisons

You can stick to using routine `ok` to do tests, but some convenient
routines are supplied for easier comparison of different types. In
particular the `is` routine is overloaded for different types.

There are also a few special `is` routines for comparison of
floating point numbers whose representation by definition
is inexact: `isabs`, `isrel`, and `isnear`. The routine `isabs` is
good for comparison of small numbers while `isrel` is good
for comparison of large numbers. They both take an optional
`epsilon` which by default is the intrinsic `epsilon(got)`.
The routine `isnear` is similar to `isabs`, but uses division instead
of subtraction. Originally the routine was supposed to use the
intrinsic `nearest(x, s)`, which returns the nearest different
machine number in the direction given by the sign of the real `s`,
but then I discovered 2 ways of doing relative comparisons of
floating point numbers. One can still use `nearest` to compare
the floating point numbers A and B:

```Fortran
    call ok(nearest(A, -1.0) <= B .and. B <= nearest(A, +1.0))
```

Using `nearest` in such a way considers a near miss to be a hit,
but it seems more fragile than analyzing the calculation and
taking precision and accuracy into account.

For other values, just use the routine `is` with the result as
first argument and the expected result as second argument.

### Examples:

```Fortran
call is(3, 3)
call is("Dines", "Dines")
call is(.true., .false.)
call is(point(2, 3), point(2, 3)) ! Given operator(==) is overloaded.

call isabs(sqrt(2.0), 1.4142, 0.5e-3) ! 3 decimal digit precision
call isrel(10023.0, 10025.0, 0.5e-4) ! 4 largest digits precision
```

In summary:

```Fortran
is(a,b): is a equal to b?
isabs(a, b): abs(a) - abs(b) < e, where e = eps
isrel(a, b): abs(a) - abs(b) < e, where e = (abs(a) + abs(b)) * eps
isnear(a,b): abs(abs(a) / abs(b) - 1) <= e, where e = eps
```

Complex numbers cannot be compared directly with relative
operators or equality operators. In that case use either the
intrinsic functions `real` and `imag`, or the pseudo-components
(since Fortran 2003) `%re` and `%im` to compare the real and imaginary
parts of a complex number.

### Examples:

```Fortran
call is(real(a), real(b))
call is(imag(a), imag(b))
call is(a%re, b%re)
call is(a%im, b%im)
```

## Testing arrays

Deep comparison of elements in arrays or derived types doesn't
make a lot of sense in Fortran, in part because it can be
overloaded on derived types, but also because very often better
comparison techniques can be used instead. It depends on the
problem. Hence they are not as useful, and has not been implemented.

## Complex tests

This test module does not implement subtests. They could be useful, but
on the other hand they would require so much more to set up that it would
defeat the purpose. Separating stuff into test programs will handle most
cases with ease anyway, and the rest with minimal pain. It is possible
to use program generation if need be or just plain old subroutines.

If having complicated tests, one can use the routines `pass` and `fail`,
which are synonymous with `ok(.true.)` and `ok(.false.)` to tell whether a
test is to pass or fail.

### Examples:

```Fortran
call pass
! => ok 40
call pass("support for linear regression")
! => ok 41 - support for linear regression
call fail
! => not ok 42
call fail("hairy numbers does not work")
! => not ok 43 - hairy numbers does not work
```

In that case it is also useful to write one's own notes and
diagnostics. Both the routines `note` and `diag` outputs a string
as a single line preceded with a number sign (octothorpe),
"`#`", but `note` does it on the test output, which will not be
seen in a test harness, while `diag` does it on the diagnostic
output which is always visible. By default test output unit is
`OUTPUT_UNIT`, and diagnostic output is `ERROR_UNIT`.

```Fortran
call note("Tempfile is " // tempfile)
! => # Tempfile is XYZ123456
call diag("There is no XYZ, check that /etc/XYZ.ini is set up right")
! => # There is no XYZ, check that /etc/XYZ.ini is set up right
```

Currently there is no overloaded subroutine that will take several
strings for several lines, since that has not been very useful, but
maybe in the future.

## Conditional tests

One can skip a test if there is insufficient conditions to run it, or
it doesn't make sense, or it's impossible to do so. In that case one
calls `skip` _instead of_ the test routines. Skipped tests are always
reported as being ok. Please note that calling skip unconditionally,
i.e. outside an if block or similar is surely a mistake. If the test
program is planned, this mistake will be caught by the test harness,
or simply by the test program failing by error.

One does not skip tests with failures or tests with only stubbed-out
code to be tested. For that one uses todo tests.

One can indicate a test as unfinished and yet to be done by calling the
routine `todo`. The test must still be run, and it is expected to fail. Any
todo test that passes is supposed to be reported by any test harness as
unexpectedly passing, so one can remove the todo status, once the work
is done.

Both `skip` and `todo` routines take an optional `test_name` and an optional
`how_many`, which is default `1`.

### Examples:

```Fortran
call skip
! => ok 50 # Skipped
call skip("No test data on the network")
! => ok 51 # SKIP: No test data on the network
call skip("No APP_DATA directory", 3)
! => ok 52 # SKIP: No APP_DATA directory
! => ok 53 # SKIP: No APP_DATA directory
! => ok 54 # SKIP: No APP_DATA directory
call skip(2)
! => ok 55 # SKIP
! => ok 56 # SKIP

call todo
call ok(.false.)
! => not ok 57 - # TODO
call todo("Lookup details in the cryptic article")
call ok(.false.)
! => not ok 58 - # TODO: Lookup details in the cryptic article
call todo
call ok(.false., "Monte carlo test set up")
! => not ok 59 - Monte carlo test set up # TODO
call todo("Resolve learning problems")
call is(supervise(data), 97.0, "Bayes with 97% class")
! => not ok 60 - Bayes with 97% class # TODO: Resolve learning problems

call todo("Halting problem unsolved", 3)
call ok(.false., "Infinite loop")
call ok(.false., "Infinite recursion")
call ok(.false., "Infinite Turing tape")
! => not ok 61 - Infinite loop # TODO: Halting problem unsolved
! => not ok 62 - Infinite recursion # TODO: Halting problem unsolved
! => not ok 63 - Infinite Turing tape # TODO: Halting problem unsolved
call todo(2)
call ok(.false., "Stubbed-out")
call ok(.false., "Stubbed-out")
! => not ok 64 - # TODO
! => not ok 65 - # TODO
```

Skipping a todo test has not been implemented yet. Maybe it'll be useful,
maybe not. Currently skipping a test means also skipping a todo test.

## Diagnostic output

The `note` routine writes a string on the `TEST_UNIT` (default `OUTPUT_UNIT`),
also known as the TAP stream, together with the other test lines without
interfering with the test harness. The output is not visible when run
from a test harness. It is useful for notes, headlines, error correction,
and other things that are not exactly problems.

The `diag` routine writes a string on the `DIAG_UNIT` (default `ERROR_UNIT`),
and is always visible, even when run from a test harness. Output about
gotten and expected outputs are written this way. It is useful for
diagnostic output in complex tests (see [Complex tests](#complex-tests) above)

The `TEST_UNIT` and `DIAG_UNIT` can be set to other unit for the purpose
of redirecting the TAP or diagnostic stream elsewhere for particular
testing purposes: They are public from the test module.

## Stopping a test

The `bail_out` routine does an `error stop` after writing an optional message.

### Examples:

```Fortran
call bail_out
! => Bail out!

call bail_out("PostgreSQL is not running")
! => Bail out! PostgreSQL is not running
```

## Caveats

The `fortapt_m` module is not thread safe. You can run test programs in parallel
or use test routines with coarrays, but the `fortapt_m` module itself is 
_"thread ignorant"_ and is inherently sequential. You can of course divide your
tests into `subroutines`, and are encouraged to do so.

## Exit codes

The status/exit code has some historical complications both
for test programs as well as for Fortran in general, so it's
not supported at all. A test program exits with status code `0`
(zero) on those platforms that have such a thing, but in reality
it depends on the fortran processor (compiler).

## History

The `fortapt_m` module is a minor refactoring of [Fortran-testanything][4] that 
was inspired by Perl's simple Test, Test::More and Test Anything Protocol (TAP) 
that Perl's Test::Harness handles. In Perl the tool prove(1) handles TAP.

The great idea is to separate tests from test result consumers via a
simple text based protocol.

It turns out that the Test Anything Protocol is easy, simple, and
transparent to implement in Fortran itself. There is no need for
heavy tooling even in big, elaborate test suites. Perl itself is
proof of that. It is customary for a perl module uploaded to the
Comprehensive Perl Archive Network (CPAN) to be accompanied with
tests, and currently there are beyond 25000 modules on CPAN.

~~There is a curious lack of~~ Fortran test libraries ~~written
in Fortran itself. They~~ usually require a preprocessor or a
scripting language to do collection, preprocessing, transcription
and processing of the tests. Examples of popular ones are Fruit,
ftunit, pFUnit, flibs, FortUnit, FUnit, and ObjecxxFTK:

 * [Fruit](https://gitlab.com/everythingfunctional/fruit) (fortranxunit): Fortran Unit Test Framework, BSD-like license, requires Ruby, active in 2015,
 * ftunit (NASA): NASA open source license 1.3, requires Ruby, active in 2015,
 * [pFUnit](https://github.com/Goddard-Fortran-Ecosystem/pFUnit) (NASA): NASA open source license 1.3, requires Python,
 * [flibs](http://flibs.sourceforge.net/ftnunit.html) (Arjen Markus): BSD-like license, requires Tcl, stopped in 2008,
 * FortUnit: GPLv2 license, requires Perl, stopped in 2004 and seems gone (no source),
 * FUnit: requires Ruby, stopped in 2009,
 * [ObjecxxFTK](https://objexx.com/ObjexxFTK.html#UnitTest): requires Python; perpetual, royalty-free license for source allowing client modifications - modest license fee.

As of 2021, there are at least a couple of test libraries written
in Fortran itself to choose from (for keeping your code healthy...):
 * [Vegetables](https://gitlab.com/everythingfunctional/vegetables) 
   (Brad Richardson): A Fortran testing framework written using functional 
   programming principles, MIT License, active in 2021.
 * [naturalFRUIT](https://github.com/cibinjoseph/naturalFRUIT) (Cibin Joseph): A
   Fortran based unit testing framework derived from the original 
   [Fruit](https://gitlab.com/everythingfunctional/fruit), BSD-3-Clause, active
   in 2021.
 
[ForTAPt][1] is less capable than these latest Fortran only test libraries, but 
with its _"small is beautiful"_ philosophy, it hopefully lowers the bar so much, 
that there is no excuse for not writing unit tests in Fortran projects that may 
otherwise forsake this crucial component. [ForTAPt][1] is a first step, bare 
bones, minimal, pure modern Fortran toolbox, without any dependencies other than
a fairly recent Fortran compiler. This is due to the separation between test 
producers and test consumers. While one can use Perl's prove(1) tool as a test 
harness, one can also use any other test harness written in any other 
programming language implementation, e.g. the plugins in the Jenkins build 
server to handle the TAP streams and make pretty reports. [ForTAPt][1] comes 
with its own little test harness if one does not have or does not want to
install Perl.

Frameworks such as pFUnit comes with much more support
for things such as MPI, OpenMP, and MPICH; array tools
for checking size, rank, and shape; preprocessing; and
OO-support. [ForTAPt][1] on the other hand tries to be
small and easily modifiable. Adding small functions and test
subroutines to supplement specific use cases is easy.

Testing does not have to be complicated.

## License

[ForTAPt][1] comes with the OpenBSD/ISC license,
i.e. the ISC license anno 2003, the one without the "and/or"
conjunction. Lawyers have told me that it does not make any legal
difference in its context, which is already quite clear, and so
a simpler language is preferred, hence just the "and" junction
as in the original license. By the way, the original ISC license
is extremely close to the words of the original BSD license,
but without any words made unnecessary by the Berne Convention.

It is one of the least restrictive licenses under the Berne
Convention.

[1]: https://github.com/jbdv-no/fortapt
[2]: https://github.com/fortran-lang/fpm
[3]: https://github.com/fortran-lang/fpm/blob/master/manifest-reference.md
[4]: https://github.com/dennisdjensen/fortran-testanything