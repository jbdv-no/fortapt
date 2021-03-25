module real32_m
  !!
  !! Provide functionality for determining if two scalar real numbers of
  !! `kind=real32` are close to each other in an absolute or relative sense
  !!
  use, intrinsic :: iso_fortran_env,  only : WP => real32
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

  ! integer, parameter :: WP = real32

contains

  include 'inc/isabs_real.f90'
  include 'inc/isnear_real.f90'
  include 'inc/isrel_real.f90'

end module real32_m