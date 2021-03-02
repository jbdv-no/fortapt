module test_base_m
  use, intrinsic :: iso_fortran_env, only: output_unit, error_unit
  implicit none

  private
  public :: diag_unit, test_unit
  public :: diag, fail, note, ok, pass, testline, tests, todo

  ! Kept as variables instead of aliases,
  ! so that test output or diagnostic output can be redirected
  integer :: test_unit = output_unit, diag_unit = error_unit

  integer :: tests = 0, todos = 0
  character(len=120) :: todomsg = ""

  interface todo
     module procedure todo_i, todo_s, todo_s_i, todo
  end interface

contains

  subroutine diag(msg)
     character(len=*), intent(in) :: msg
     write (diag_unit, '("# ",A)') trim(msg) ! only trailing spaces
  end

  subroutine note(msg)
     character(len=*), intent(in) :: msg
     write (test_unit, '("# ",A)') trim(msg)
  end

  subroutine testline(ok, msg, idmsg, gotmsg, expectedmsg)
     logical, intent(in) :: ok
     character(len=*), intent(in) :: msg, idmsg, gotmsg, expectedmsg

     tests = tests + 1
     if (.not. ok) call out("not ")
     write (test_unit, '("ok ",I0)', advance="NO") tests

     if (msg /= "" .or. todos > 0) call out(" - ")

     if (msg /= "") call out(trim(msg))

     if (todos > 0) then
        todos = todos - 1
        if (msg /= "") call out(" ")
        call out("# TODO")
        if (todomsg .ne. "") then
           call out(": ")
           call out(trim(todomsg))
        end if
     end if
     if (todos == 0) todomsg = ""

     write (test_unit, *) ""

     if (.not. ok) then
        ! 3 spaces prepended = 4 spaces indentation after # on diag
        if (idmsg /= "") call diag("   " // idmsg)
        if (gotmsg /= "") call diag("   " // gotmsg)
        if (expectedmsg /= "") call diag("   " // expectedmsg)
     end if
  contains
     subroutine out(str)
        character(len=*), intent(in) :: str
        write (test_unit, '(A)', advance="NO") str
     end
  end subroutine testline

  subroutine ok(condition, msg)
     logical, intent(in) :: condition
     character(len=*), intent(in), optional :: msg
     if (present(msg)) then
        call testline(condition, msg, "", "", "")
     else
        call testline(condition,  "", "", "", "")
     end if
  end

  subroutine pass(msg)
     character(len=*), intent(in), optional :: msg
     call ok(.true., msg)
  end

  subroutine fail(msg)
     character(len=*), intent(in), optional :: msg
     call ok(.false., msg)
  end

  subroutine todo_s_i(msg, howmany)
     character(len=*), intent(in) :: msg
     integer, intent(in) :: howmany
     todomsg = msg
     todos = howmany
  end

  subroutine todo
     call todo_s_i("", 1)
  end

  subroutine todo_s(msg)
     character(len=*), intent(in) :: msg
     call todo_s_i(msg, 1)
  end

  subroutine todo_i(howmany)
     integer, intent(in) :: howmany
     call todo_s_i("", howmany)
  end

end module test_base_m