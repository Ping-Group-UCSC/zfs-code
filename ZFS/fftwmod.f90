module fftwmod

    use params,            only : dp
    use, intrinsic :: iso_c_binding

    implicit none

    include 'fftw3.f03'

contains
    
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    subroutine calc_grid_dim(npw, grid, grid_dim)
    ! return grid_dim a rank 1 dim 3 array specifying the number of gx, gy, and gz
        integer, intent(in)                                 :: npw
        integer, dimension(npw, 3), intent(in)              :: grid
        integer, dimension(3), intent(out)                  :: grid_dim
        integer                                             :: i
    
        do i = 1, 3
            grid_dim(i) = maxval(grid(:,i)) * 2 + 1
        end do
    
    end subroutine calc_grid_dim
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    subroutine reshape_wfc(npw, grid_dim, grid, wfc, wfc_g, center)
        integer, intent(in)                                 :: npw
        integer, dimension(3), intent(in)                   :: grid_dim
        integer, dimension(npw,3), intent(in)               :: grid
        complex(dp), dimension(npw), intent(in)             :: wfc
        integer                                             :: i ! dummy index
        integer, dimension(3)                               :: ng
        complex(dp), dimension(grid_dim(1), grid_dim(2), grid_dim(3)), &
            & intent(out)                                   :: wfc_g
        integer, intent(in)                                 :: center
        
        do i = 1, npw
    
            ! should change mod_grid to a function which can take arrays as arg's
            ng(1) = mod_grid(grid(i,1), grid_dim(1))
            ng(2) = mod_grid(grid(i,2), grid_dim(2))
            ng(3) = mod_grid(grid(i,3), grid_dim(3))
    
            ! print 100, grid(i,1), " = ", ng(1), grid(i,2), " = ", ng(2), grid(i,3), " = ", ng(3)
    
            wfc_g(ng(1), ng(2), ng(3)) = wfc(i)
        end do
    
        ! 100 format (i3,a,i3,4x,i3,a,i3,4x,i3,a,i3)
    
    contains
    
        integer function mod_grid(a, n)
            ! input a{-n...n} return mod_grid{c...n*2+c}
    
            integer :: a, b, n
    
            if ( a >= center ) then 
                b = a
            else
                b = a + n
            end if
            
            if (center == 0) then
                mod_grid = b + 1
            else if (center == 1) then
                mod_grid = b
            else 
                print *, "invalid center"
            end if
    
        end function mod_grid
    
    end subroutine reshape_wfc
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    subroutine inv_reshape_wfc(npw, grid_dim, grid, wfc_g, wfc, center)
        ! identical to above except input wfc_g and return wfc
        ! everything below is the same except assigment of wfc_g(ng(1),ng(2),ng(3)) to wfc(i)
        integer, intent(in)                                 :: npw
        integer, dimension(3), intent(in)                   :: grid_dim
        integer, dimension(npw,3), intent(in)               :: grid
        complex(dp), dimension(npw), intent(out)            :: wfc
        integer                                             :: i ! dummy index
        integer, dimension(3)                               :: ng
        complex(dp), dimension(grid_dim(1), grid_dim(2), grid_dim(3)), &
            & intent(in)                                    :: wfc_g
        integer, intent(in)                                 :: center
        
        do i = 1, npw
    
            ng(1) = mod_grid(grid(i,1), grid_dim(1))
            ng(2) = mod_grid(grid(i,2), grid_dim(2))
            ng(3) = mod_grid(grid(i,3), grid_dim(3))
    
            ! print 100, grid(i,1), " = ", ng(1), grid(i,2), " = ", ng(2), grid(i,3), " = ", ng(3)
    
            wfc(i) = wfc_g(ng(1), ng(2), ng(3))
    
        end do
    
        ! 100 format (i3,a,i3,4x,i3,a,i3,4x,i3,a,i3)
    
    contains
    
        integer function mod_grid(a, n)
            ! input a{-n...n} return mod_grid{c...n*2+c}

            integer :: a, b, n

            if ( a >= center ) then 
                b = a
            else
                b = a + n
            end if
            
            if (center == 0) then
                mod_grid = b + 1
            else if (center == 1) then
                mod_grid = b
            else 
                print *, "invalid center"
            end if

        end function mod_grid
    
    end subroutine inv_reshape_wfc
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    subroutine calc_fft(grid_dim, wfc_in, wfc_out, back_flag)
        ! return grid_dim a rank 1 dim 3 array specifying the number of gx, gy, and gz
    
        use, intrinsic :: iso_c_binding
        include 'fftw3.f03'
    
        integer, dimension(3), intent(in)                   :: grid_dim
        complex(dp), dimension(grid_dim(1), grid_dim(2), grid_dim(3)), &
            & intent(in)                                    :: wfc_in
        complex(dp), dimension(grid_dim(1), grid_dim(2), grid_dim(3)), &
            & intent(out)                                    :: wfc_out
        logical                                              :: back_flag
        integer (kind=8)                                     :: plan
    
        if ( back_flag ) then
            ! R -> G (Backward)
            call dfftw_plan_dft_3d(plan, grid_dim(1), grid_dim(2), grid_dim(3), &
            & wfc_in, wfc_out, FFTW_BACKWARD, FFTW_ESTIMATE)
        else
            ! G -> R (Forward)
            call dfftw_plan_dft_3d(plan, grid_dim(1), grid_dim(2), grid_dim(3), &
            & wfc_in, wfc_out, FFTW_FORWARD, FFTW_ESTIMATE)
        end if
    
        call dfftw_execute_dft(plan, wfc_in, wfc_out)
        call dfftw_destroy_plan(plan)
    
    end subroutine calc_fft
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!




end module