module zfs_calc

    use params, only : dp, bohr_to_m, mu_B, mu_0, ge, joules_to_ev, planck_constant, speed_of_light

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


    subroutine calc_D_ab(omega, I_ab, D_en, D_fr1, D_fr2)
    ! calculate final ZFS parameter
    ! all constants are in SI ; except for h which is eV*s to convert from energy to freq
    ! D = mu_0 * ge**2 * mu_B**2 / omega * I_ab
    ! returns real values D_en and D_fr, (units of eV and GHz)

        real(dp), dimension(3,3), intent(in)        :: I_ab
        real(dp), dimension(3,3), intent(out)       :: D_en, D_fr1, D_fr2
        real(dp)                                    :: omega

        omega = omega * (bohr_to_m)**3        ! units of omega converted from bohr^3 to m^3

        D_en  = mu_B**2 * ge**2 * mu_0 / omega * joules_to_ev * I_ab / 2.0_dp       ! units of eV
        D_fr1 = D_en / planck_constant / 1.0D9                                      ! units of GHz
        D_fr2 = D_en / planck_constant / speed_of_light / 1.0D2                     ! units of cm-1
    
    end subroutine calc_D_ab


    subroutine zfs_parameters(eigs, evecs)
    ! D_z = 3/2 max(eigs)

        real(dp), dimension(3), intent(in)                  :: eigs
        real(dp), dimension(3, 3), intent(in)               :: evecs
        integer                                             :: zi, xi1, xi2 ! indices for sorted eigs
        integer                                             :: idumb ! dummy variable

        zi = maxloc(eigs, 1)
        xi1 = minloc(eigs, 1)

        do idumb = 1, 3
            if ((idumb /= zi) .and. (idumb /= xi1)) xi2 = idumb
        end do
        
        write(*,100) 1.5_dp * eigs(zi), abs(eigs(xi1) - eigs(xi2)) * 0.5_dp
        100 format(5x, "D(GHz) = ", f12.6, 3x, "E(GHz)", f12.6)

    end subroutine zfs_parameters

end module zfs_calc
