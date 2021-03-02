module int8_m
  !!
  !! Provide functionality for comparing scalar integers of `kind=int8`
  !!
  use, intrinsic :: iso_fortran_env,  only : WP => int8
  use test_base_m,                    only : testline
  use test_base_m,                    only : tests
  implicit none
  private
  public :: is

  interface is
    module procedure is_int
  end interface

  ! integer, parameter :: WP = int8

contains

  include 'is_int.inc'

end module int8_m