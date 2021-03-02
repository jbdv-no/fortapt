! Template parameter: wp (working precision)
! Template free identifiers: testline, tests
subroutine isabs_real(got, expected, eps, msg)
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
      tolerance = epsilon(got)
   end if
   ! eps = 0.5e-10_WP
   ! Absolute accuracy within the 10 least significant digits
   good = abs(got - expected) < tolerance
   call testline(good, testmsg, idmsg, gotmsg, expectedmsg)
end subroutine isabs_real
