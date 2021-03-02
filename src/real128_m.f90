module real128_m
  !!
  !! Provide functionality for determining if two scalar real numbers of
  !! `kind=real128` are close to each other in an absolute or relative sense
  !!
  use, intrinsic :: iso_fortran_env,  only : WP => real128
  use test_base_m,                    only : testline
  use test_base_m,                    only : tests
  implicit none
  private
  public :: isabs, isnear, isrel

  interface isabs
    module procedure isabs_real
  end interface

  interface isnear
    module procedure isnear_real
  end interface

  interface isrel
    module procedure isrel_real
  end interface

  ! integer, parameter :: WP = real128

contains

  include 'isabs_real.inc'
  include 'isnear_real.inc'
  include 'isrel_real.inc'

end module real128_m