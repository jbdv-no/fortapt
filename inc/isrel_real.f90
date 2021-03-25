! Template parameter: wp (working precision)
! Template free identifiers: testline, tests
subroutine isrel_real(got, expected, eps, msg)
   real(kind=wp),    intent(in)           :: got, expected
   real(kind=wp),    intent(in), optional :: eps
   character(len=*), intent(in), optional :: msg
   real(kind=wp)                          :: tolerance

   ! eps = (abs(a) + abs(b)) * 0.5e-10_wp
   ! Relative accuracy within the 10 most significant digits
   tolerance = (abs(got) + abs(expected))
   if (present(eps)) then
      tolerance = tolerance * eps
   else
      tolerance = tolerance * epsilon(got)
   end if
   call isabs(got, expected, tolerance, msg)
end subroutine isrel_real
