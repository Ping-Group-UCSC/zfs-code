module params
    implicit none

    integer, parameter :: dp = selected_real_kind(14,200)

    type tcell
        real(dp)                    :: omega
        real(dp), dimension(3,3)    :: a, b
    end type tcell

    real(dp), parameter :: bohr_to_m = 5.29177D-11               ! bohr to meters
    real(dp), parameter :: mu_B = 9.274009994D-24                ! bohr magneton : J/T  =  m^2 A
    real(dp), parameter :: mu_0 = 1.2566370614D-06               ! vacuum permeability : N/A^2
    real(dp), parameter :: ge = 2.00231930436256D0               ! g-factor for electron : unitless
    real(dp), parameter :: joules_to_ev = 6.2415093433D+18       ! joules to eV
    real(dp), parameter :: planck_constant = 4.135667662D-15     ! planck's constant : eV*s
    real(dp), parameter :: speed_of_light = 2.99792458D8         ! speed of light : m/s


end module params
