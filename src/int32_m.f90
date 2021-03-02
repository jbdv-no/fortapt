module int32_m
  !!
  !! Provide functionality for comparing scalar integers of `kind=int32`
  !!
  use, intrinsic :: iso_fortran_env,  only : WP => int32
  use test_base_m,                    only : testline
  use test_base_m,                    only : tests
  implicit none
  private
  public :: is

  interface is
    module procedure is_int
  end interface

  ! integer, parameter :: WP = int32

contains

  include 'is_int.inc'

end module int32_m