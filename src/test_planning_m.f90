module test_planning_m
  use test_base_m, only: test_unit, tests
  implicit none

  private
  public :: bail_out, done_testing, plan, skip_all
  integer, private :: planned = 0

contains

  subroutine bail_out(msg)
     character(len=*), intent(in), optional :: msg
     if (present(msg)) then
        write (test_unit, '("Bail out! ",A)') msg
     else
        write (test_unit, '("Bail out!")')
     end if
     stop
  end
  
  subroutine done_testing(howmany)
     integer, intent(in), optional :: howmany

     ! Put plan at the end of test output
     if (present(howmany)) then
        call plan(howmany)
     else
        if (planned == 0) call plan(tests)
        ! else - We already have a plan
     end if
  end

  subroutine plan(tests)
     integer, intent(in) :: tests

     select case (tests)
     case (:-1)
        call bail_out("A plan with a negative number of tests")
     case (0)
        write (test_unit, '("1..0")')
        stop ! The same as skip_all without a given reason
     case (1:)
        if (planned > 0) &
           & call bail_out("More than one plan in test output")
        planned = tests
        write (test_unit, '("1..",I0)') planned
     end select
  end


  subroutine skip_all(msg)
     character(len=*), intent(in), optional :: msg
     if (present(msg)) then
        write (test_unit, '("1..0 # Skipped: ",A)') msg
     else
        write (test_unit, '("1..0 # Skipped all")')
     end if
     stop
  end

end module test_planning_m