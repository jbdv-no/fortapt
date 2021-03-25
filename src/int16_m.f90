module int16_m
  !!
  !! Provide functionality for comparing scalar integers of `kind=int16`
  !!
  use, intrinsic :: iso_fortran_env,  only : WP => int16
  use test_base_m,                    only : testline
  use test_base_m,                    only : tests
  implicit none
  private
  public :: is

  interface is
    module procedure is_int
  end interface

  ! integer, parameter :: WP = int16

contains

  include 'inc/is_int.f90'

end module int16_m