module is_real_m
  use real32_m,   only : isabs, isnear, isrel
  use real64_m,   only : isabs, isnear, isrel
  use real128_m,  only : isabs, isnear, isrel
  implicit none
  private
  public :: isabs, isnear, isrel

end module is_real_m