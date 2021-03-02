module fortapt_m
  !!
  !! A Test Anything Protocol (TAP) producer module inspired by Perl's
  !! Test::More module for planning and setting up tests.
  !!
  use test_base_m,      only: diag
  use test_base_m,      only: diag_unit
  use test_base_m,      only: fail
  use test_base_m,      only: note
  use test_base_m,      only: ok
  use test_base_m,      only: pass
  use test_base_m,      only: test_unit
  use test_base_m,      only: todo

  use test_planning_m,  only: plan
  use test_planning_m,  only: done_testing
  use test_planning_m,  only: skip_all
  use test_planning_m,  only: bail_out

  use test_more_m,      only: is
  use test_more_m,      only: isabs
  use test_more_m,      only: isrel
  use test_more_m,      only: isnear
  use test_more_m,      only: skip
  implicit none
  public
end module fortapt_m