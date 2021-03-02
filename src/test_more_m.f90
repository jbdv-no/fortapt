module test_more_m
  use test_base_m,      only : testline, tests, test_unit
  use test_planning_m,  only : bail_out ! for negative skips
  use is_int_m,         only : is
  use is_real_m,        only : isabs, isrel, isnear

  ! Complex numbers cannot be compared, hence no is_c module

  implicit none

  private
  public :: is, isabs, isrel, isnear, skip

  interface skip
     module procedure skip_i, skip_s, skip_s_i, skip
  end interface

  interface is
     module procedure is_s, is_l
  end interface

contains

  subroutine skip_s_i(msg, howmany)
     character(len=*), intent(in) :: msg
     integer, intent(in) :: howmany
     character(len=120) skipmsg
     integer i

     if (howmany <= 0) then
        call bail_out("Skipped non-positive number of tests")
     end if

     if (msg == "") then
        skipmsg = "# SKIP"
     else
        skipmsg = "# SKIP: " // trim(msg)
     end if

     do i = 1, howmany
        tests = tests + 1
        write (test_unit, '("ok ",I0," ",A)') tests, trim(skipmsg)
     end do
  end

  subroutine skip
     call skip_s_i("", 1)
  end

  subroutine skip_s(msg)
     character(len=*), intent(in) :: msg
     call skip_s_i(msg, 1)
  end

  subroutine skip_i(howmany)
     integer, intent(in) :: howmany
     call skip_s_i("", howmany)
  end

  ! Duplicates of is_i routines in file is_i.inc and ditto is_r
  ! They are not factored any further, because it is easier
  ! to see all the output together rather than in separate routines

  subroutine is_s(got, expected, msg)
     character(len=*), intent(in) :: got
     character(len=*), intent(in) :: expected
     character(len=*), intent(in), optional :: msg
     character(len=:), allocatable :: testmsg, idmsg
     character(len=120) gotmsg, expectedmsg
     logical good

     if (present(msg)) then
        allocate(character(len=len_trim(msg)+20) :: testmsg, idmsg)
        write (unit=idmsg, fmt='(A,A,A)') 'Failed test: "', trim(msg), '"'
        testmsg = trim(msg)
     else
        allocate(character(len=30) :: testmsg, idmsg)
        write (unit=idmsg, fmt='(A,I0)') 'Failed test no. ', tests + 1
        testmsg = ""
     end if
     write (unit=gotmsg,      fmt='(A,A,A)') '     got: "', got, '"'
     write (unit=expectedmsg, fmt='(A,A,A)') 'expected: "', expected, '"'

     good = got == expected
     call testline(good, testmsg, idmsg, gotmsg, expectedmsg)
  end

  subroutine is_l(got, expected, msg)
     logical, intent(in) :: got, expected
     character(len=*), intent(in), optional :: msg
     character(len=:), allocatable :: testmsg, idmsg
     character(len=120) gotmsg, expectedmsg
     logical good

     if (present(msg)) then
        allocate(character(len=len_trim(msg)+20) :: testmsg, idmsg)
        write (unit=idmsg, fmt='(A,A,A)') 'Failed test: "', trim(msg), '"'
        testmsg = trim(msg)
     else
        allocate(character(len=30) :: testmsg, idmsg)
        write (unit=idmsg, fmt='(A,I0)') 'Failed test no. ', tests + 1
        testmsg = ""
     end if
     write (unit=gotmsg,      fmt='(A,L1)') '     got: ', got
     write (unit=expectedmsg, fmt='(A,L1)') 'expected: ', expected

     good = got .eqv. expected
     call testline(good, testmsg, idmsg, gotmsg, expectedmsg)
  end

end module test_more_m