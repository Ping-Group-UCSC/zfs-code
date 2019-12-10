module params
    implicit none

    integer, parameter :: dp = selected_real_kind(14,200)

    type tcell
        real(dp)                    :: omega
        real(dp), dimension(3,3)    :: a, b
    end type tcell


end module params
