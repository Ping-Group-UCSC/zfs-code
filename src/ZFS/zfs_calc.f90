module zfs_calc
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
!%%      ZFS calculation      %%
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    use params, only : dp

    implicit none

contains
    subroutine calc_rho(num_row, f1, f2, f3, rho)
    ! calculate rho_G from f1_G, f2_minusG, f3_minusG
    ! rho(G,-G) = f1(G)*f2(G) - |f3(G)|^2
    ! returns complex array rho of dim num_row

        integer, intent(in) :: num_row
        complex(dp), dimension(num_row), intent(in) :: f1, f2, f3
        complex(dp), dimension(num_row), intent(out) :: rho

        integer :: i ! dummy index

        do i = 1, num_row
            rho(i) = f1(i)*f2(i) - conjg(f3(i))*f3(i)
        end do

    end subroutine calc_rho

    ! subroutine calc_I_zz(num_row,num_col,Grid,rho_G, I_zz)
    ! ! calculate matrix element I_zz -- will eventually expand to compute arbitrary matrix elem.
    ! ! I_ab = sum_G rho(G,-G) * (G_a*G_b/G^2 - delta_ab/3)
    ! ! --> I_zz = sum_G rho(G,-G) * (G_z^2/G^2 - 1/3)
    ! ! Note: G_a*G_b/G^2 raises error under G->0 ; limit simplifies to 1 ; see if statement below for treatment
    ! ! Note: does not include factor of 4*pi*Omega which is added at lest step
    ! ! returns single complex value I_zz (imaginary value should be very small)

    !     integer, intent(in) :: num_row, num_col
    !     integer, dimension(num_row,num_col), intent(in) :: Grid
    !     complex(dp), dimension(num_row), intent(in) :: rho_G

    !     complex(dp), intent(out) :: I_zz

    !     real(dp) :: prod_Gab, mag_G  ! internal quantities
    !     complex(dp) :: sum_value     ! internal quantity; for sum over G

    !     integer :: i ! dummy index

    !     sum_value = (0,0)
    !     do i =1, num_row
    !         ! convert integer to double
    !         prod_Gab = dble(Grid(i,3)*Grid(i,3))
    !         mag_G = dble(Grid(i,1)**2 + Grid(i,2)**2 + Grid(i,3)**2)
    !         ! skip G = (0,0,0)
    !         if (mag_G .ne. 0) then
    !             ! (G_a*G_b/G^2 - delta_ab/3 -- here assume a = b = z)
    !             sum_value = sum_value + rho_G(i) * ( prod_Gab /mag_G - 1.0/3.0 )
    !         end if
    !     end do
    !     I_zz = sum_value
        

    ! end subroutine calc_I_zz

!!!!!!!!!!!!!!!! new
    subroutine calc_I_ab(npw, dim_G, grid, b, rho_G, I_ab_part)
    ! calculate full I_ab matrix
    ! I_ab = \sum_G rho(G,-G) * (G_a G_b/G^2 - delta_ab/3)
    ! note G_ab = G_a G_b/G^2  and  d3_ab = delta_ab/3

        ! input variables
        integer, intent(in)                                 :: npw, dim_G
        integer, dimension(npw, dim_G), intent(in)          :: grid
        complex(dp), dimension(npw), intent(in)             :: rho_G
        real(dp), dimension(3,3), intent(in)                :: b
        ! output variables
        real(dp), dimension(dim_G, dim_G), intent(out)      :: I_ab_part
        ! internal variables
        real(dp), dimension(3)                              :: bG
        real(dp), dimension(dim_G, dim_G)                   :: G_ab, d3_ab
        integer                                             :: i, j ! dummy index

        ! initialize delta_ab / 3
        d3_ab = 0.0_dp
        forall (j = 1:dim_G) d3_ab(j,j) = 1.0_dp / 3.0_dp

        I_ab_part = 0.0_dp
        ! skip G = 0, corresponding to i = 1
        do i = 2, npw
            ! calculate bG (i.e. converted from crystal coordinates to xyz)
            bG = matmul(transpose(b), dble(grid(i,:)))
            ! calculate G_ab
            forall (j = 1:dim_G) G_ab(j,:) = bG(j) * bG(:)
            ! print *, grid(i,:), "|", bG, "|", G_ab, "|", G_ab / (bG(1)**2 + bG(2)**2 + bG(3)**2)
            G_ab = G_ab / (bG(1)**2 + bG(2)**2 + bG(3)**2)
            ! calculate and sum I_ab_part
            I_ab_part = I_ab_part + rho_G(i) * ( G_ab - d3_ab )
        end do

    end subroutine calc_I_ab
!!!!!!!!!!!!!!!! endnew


    ! subroutine calc_ZFS(alat,I_zz,D_en,D_fr1, D_fr2)
    ! ! calculate final ZFS parameter
    ! ! all constants are in SI ; except for h which is eV*s to convert from energy to freq
    ! ! D = mu_0 * ge**2 * mu_B**2 / omega * 3/2 * I_zz
    ! ! returns real values D_en and D_fr, (units of eV and GHz)

    !     real(dp), intent(in) :: alat
    !     complex(dp), intent(in) :: I_zz
    !     real(dp), intent(out) :: D_en, D_fr1, D_fr2
    !     real(dp) :: omega, ang_to_m, mu_B, mu_0, ge, joules_to_ev, planck_constant, speed_of_light ! internal parameters

    !     ang_to_m = 1.0D-10                    ! angstrom to meters
    !     omega = (alat*ang_to_m)**3            ! units of omega is m^3
    !     mu_B = 9.274009994D-24                ! bohr magneton : J/T  =  m^2 A
    !     mu_0 = 1.2566370614D-06               ! vacuum permeability : N/A^2
    !     ge = 2.00231930436256D0               ! g-factor for electron : unitless
    !     joules_to_ev = 6.2415093433D+18       ! joules to eV
    !     planck_constant = 4.135667662D-15     ! planck's constant : eV*s
    !     speed_of_light = 2.99792458D8         ! speed of light : m/s

    !     D_en  = mu_B**2 * ge**2 * mu_0 / omega * joules_to_ev * 1.5D0 * real(I_zz)  ! units of eV
    !     D_fr1 = D_en / planck_constant / 1.0D9                                      ! units of GHz !!!!! TYPO !!!!!! 10.0D9 , should be 1.0D9
    !     D_fr2 = D_en / planck_constant / speed_of_light / 1.0D2                     ! units of cm-1


    ! end subroutine calc_ZFS


!!!!!!!! new
    subroutine calc_ZFS(omega, I_ab, D_en, D_fr1, D_fr2)
        ! calculate final ZFS parameter
        ! all constants are in SI ; except for h which is eV*s to convert from energy to freq
        ! D = mu_0 * ge**2 * mu_B**2 / omega * I_ab
        ! returns real values D_en and D_fr, (units of eV and GHz)
    
            real(dp), dimension(3,3), intent(in)        :: I_ab
            real(dp), dimension(3,3), intent(out)       :: D_en, D_fr1, D_fr2
            real(dp) :: omega, bohr_to_m, mu_B, mu_0, ge, joules_to_ev, planck_constant, speed_of_light
    
            ! ang_to_m = 1.0D-10                    ! angstrom to meters
            bohr_to_m = 5.29177D-11               ! bohr to meters
            omega = omega * (bohr_to_m)**3        ! units of omega converted from bohr^3 to m^3
            mu_B = 9.274009994D-24                ! bohr magneton : J/T  =  m^2 A
            mu_0 = 1.2566370614D-06               ! vacuum permeability : N/A^2
            ge = 2.00231930436256D0               ! g-factor for electron : unitless
            joules_to_ev = 6.2415093433D+18       ! joules to eV
            planck_constant = 4.135667662D-15     ! planck's constant : eV*s
            speed_of_light = 2.99792458D8         ! speed of light : m/s
    
            D_en  = mu_B**2 * ge**2 * mu_0 / omega * joules_to_ev * I_ab / 2.0_dp       ! units of eV
            D_fr1 = D_en / planck_constant / 1.0D9                                      ! units of GHz
            D_fr2 = D_en / planck_constant / speed_of_light / 1.0D2                     ! units of cm-1
    
        end subroutine calc_ZFS
!!!!!!!! end new

end module zfs_calc
