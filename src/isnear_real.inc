! Template parameter: WP (working precision)
! Template free identifiers: testline, tests
subroutine isnear_real(got, expected, eps, msg)
   real(kind=WP),    intent(in)           :: got, expected
   real(kind=WP),    intent(in), optional :: eps
   character(len=*), intent(in), optional :: msg
   character(len=:), allocatable          :: testmsg, idmsg
   character(len=120)                     :: gotmsg, expectedmsg
   logical                                :: good
   real(kind=WP)                          :: tolerance

   if (present(msg)) then
      allocate(character(len=len_trim(msg)+20) :: testmsg, idmsg)
      write (unit=idmsg, fmt='(A,A,A)') 'Failed test: "', trim(msg), '"'
      testmsg = trim(msg)
   else
      allocate(character(len=30) :: testmsg, idmsg)
      write (unit=idmsg, fmt='(A,I0)') 'Failed test no. ', tests + 1
      testmsg = ""
   end if
   write (unit=gotmsg,      fmt='(A,G0)') '     got: ', got
   write (unit=expectedmsg, fmt='(A,G0)') 'expected: ', expected

   if (present(eps)) then
      tolerance = eps
   else
      tolerance = epsilon(got) ! minimun eps for which 1 + eps /= 1
   end if
   ! Relative accuracy around 1.0_WP
   ! Semantics of isnear means using <=, and not <, c.f. epsilon(got)
   good = abs(got / expected - 1.0_WP) <= tolerance
   call testline(good, testmsg, idmsg, gotmsg, expectedmsg)
end subroutine isnear_real
