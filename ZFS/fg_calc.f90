module fg_calc
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
!%%    f(G) calculations      %%
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    use params, only : dp
    use indexmod, only : find_index

    implicit none

contains
    subroutine convolution(num_row,num_col,Grid,wfc1,wfc2,f_G)
    ! evaluates convolution of wfc1 and wfc2
    ! f(G) = sum_G' conjg(wfc1(G-G')) * wfc2(G')
    ! note wfc1 and wfc2 needn't be wfc1/wfc2 of main program
    ! returns complex array f_G of dim num_row
        use omp_lib
        use convtime, only : convtime_sub

        integer, intent(in) :: num_row, num_col
        integer, dimension(num_row,num_col), intent(in) :: Grid
        complex(dp), dimension(num_row), intent(in) :: wfc1, wfc2
        complex(dp), dimension(num_row), intent(out) :: f_G

        integer, dimension(num_col) :: gvec, gpvec, diff ! internal arrays

        integer :: i,j,k         ! dummy index, i : G, j : G', k : G-G'
        complex(dp) :: sum_value     ! internal value for the summation over G'

        ! values for OMP
        integer :: id, num_threads

        ! Initialize f_G (summed later within OMP loop)
        do i = 1, num_row
            f_G(i) = (0, 0)
        end do

        ! Begin OMP section
        ! !$OMP PARALLEL SHARED() PRIVATE()
        !$OMP PARALLEL PRIVATE(i, id, num_threads, j, gvec, sum_value, gpvec, diff, k)

        num_threads = omp_get_num_threads()
        id = omp_get_thread_num()

        !$OMP do
        do i = 1, num_row ! loop over G
        
            gvec = Grid(i,:)
            sum_value = (0,0)    ! start of G/i loop sum_value returns to 0
            do j = 1, num_row    ! loop over G'
                gpvec = Grid(j,:)
                diff = gvec - gpvec
                call find_index(num_row,num_col,Grid,diff,k)   ! if diff not in Grid: return 0; else: return index of G-G'
                if ( k .ne. 0 ) then                           ! if diff not 0: evaluate sum_value; else: wfc1(G-G') ~ 0 and sum_value not changed
                    sum_value = sum_value + conjg(wfc1(k)) * wfc2(j)
                end if
            end do
            f_G(i) = sum_value

        end do
        !$OMP end do

        !$OMP END PARALLEL

    end subroutine convolution

    subroutine reflection(num_row,num_col,Grid,f_G,f_minusG)
    ! reflects f2(G) to obtain f2(-G)
    ! i -> G -> -G -> j   (j determined by find_index)
    ! f_minusG(i) = f_G(j)
    ! returns complex array f_minusG of dim num_row

        integer, intent(in) :: num_row, num_col
        integer, dimension(num_row,num_col), intent(in) :: Grid
        complex(dp), dimension(num_row), intent(in) :: f_G
        complex(dp), dimension(num_row), intent (out) :: f_minusG

        integer, dimension(num_col) :: minusG ! internal vector
        integer :: i,j ! dummy index

        do i = 1, num_row
            minusG = -Grid(i,:)
            call find_index(num_row,num_col,Grid,minusG,j) ! find minusG in Grid ; return j
            f_minusG(i) = f_G(j)
        end do

    end subroutine reflection


    subroutine fftw_convolution(npw, num_col, grid, wfc1, wfc2, f_g_out)
    ! evaluates fft_convolution of wfc1 and wfc2
    ! f(G) = ifft{ conjg(wfc1_r) * wfc2_r }
    ! returns complex array f_G of dim npw

        use convtime, only : convtime_sub
        use printmod
        use fftwmod

        integer, intent(in) :: npw, num_col
        integer, dimension(npw, num_col), intent(in)            :: grid
        complex(dp), dimension(npw), intent(in)                 :: wfc1, wfc2
        integer, dimension(3)                                   :: grid_dim
        complex(dp), allocatable                                :: &
            & wfc1_g(:,:,:), wfc2_g(:,:,:), wfc1_r(:,:,:), wfc2_r(:,:,:), &
            & f_r(:,:,:), f_g(:,:,:)
        integer, parameter                                      :: center = 0 ! 
        complex(dp), dimension(npw), intent(out)                :: f_g_out

        call calc_grid_dim(npw, grid, grid_dim)

        ! call printComplexArray(wfc2, npw, npw)

        !TODO -- in place fourier transforms to avoid disgusting code



        allocate(wfc1_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        allocate(wfc2_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        ! need to pad wfc with zeroes
        wfc1_g = complex(0, 0)
        wfc2_g = complex(0, 0)
        ! reshape to rank 3 over grid explicit with positive indices following fftw structure
        call reshape_wfc(npw, grid_dim, grid, wfc1, wfc1_g, center)
        call reshape_wfc(npw, grid_dim, grid, wfc2, wfc2_g, center)

        ! call print_over_grid(size(shape(wfc1_g)), shape(wfc1_g), wfc1_g)
        ! call inv_reshape_wfc(npw, grid_dim, grid, wfc1_g, f_g_out, center)
        ! call printComplexArray(f_g_out, npw, npw)


        allocate(wfc1_r(grid_dim(1), grid_dim(2), grid_dim(3)))
        allocate(wfc2_r(grid_dim(1), grid_dim(2), grid_dim(3)))
        call calc_fft(grid_dim, wfc1_g, wfc1_r, .false.)
        call calc_fft(grid_dim, wfc2_g, wfc2_r, .false.)
        deallocate(wfc1_g, wfc2_g)


        ! call print_over_grid(size(shape(wfc1_r)), shape(wfc1_r), wfc1_r)


        ! ! straight back to G
        ! allocate(f_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        ! call calc_fft(grid_dim, wfc1_r, f_g, .true.)
        ! f_g = f_g / size(f_g)
        ! call print_over_grid(size(shape(f_g)), shape(f_g), f_g)



        ! calculate f_r = conjg(wfc1_r)* wfc2_r
        allocate(f_r(grid_dim(1), grid_dim(2), grid_dim(3)))
        f_r = conjg(wfc1_r) * wfc2_r

        ! call print_over_grid(size(shape(f_r)), shape(f_r), f_r)

        deallocate(wfc1_r, wfc2_r)

        ! calculate f_g = ifft{f_r}
        allocate(f_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        call calc_fft(grid_dim, f_r, f_g, .true.)
        deallocate(f_r)
        f_g = f_g / size(f_g)

        ! call print_over_grid(size(shape(f_g)), shape(f_g), f_g)

        ! reshape f_g
        call inv_reshape_wfc(npw, grid_dim, grid, f_g, f_g_out, center)
        ! call printComplexArray(f_g_out, npw, npw)










        ! original begins here
        ! ! prep input wfc
        ! allocate(wfc1_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        ! allocate(wfc2_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        ! ! need to pad wfc with zeroes
        ! wfc1_g = complex(0, 0)
        ! wfc2_g = complex(0, 0)
        ! ! reshape to rank 3 over grid explicit with positive indices following fftw structure
        ! call reshape_wfc(npw, grid_dim, grid, wfc1, wfc1_g, center)
        ! call reshape_wfc(npw, grid_dim, grid, wfc2, wfc2_g, center)

        ! call print_over_grid(size(shape(wfc1_g)), shape(wfc1_g), wfc1_g, center)
        ! print *
        ! print *
        ! call print_over_grid(size(shape(wfc2_g)), shape(wfc2_g), wfc2_g, center)

        ! ! fft forward G -> R
        ! allocate(wfc1_r(grid_dim(1), grid_dim(2), grid_dim(3)))
        ! allocate(wfc2_r(grid_dim(1), grid_dim(2), grid_dim(3)))
        ! call calc_fft(grid_dim, wfc1_g, wfc1_r, .false.)
        ! call calc_fft(grid_dim, wfc2_g, wfc2_r, .false.)
        ! deallocate(wfc1_g, wfc2_g)
        ! ! print *, "shape of wfc1_r: ", shape(wfc1_r), "  and size:", size(wfc1_r)
        ! print *
        ! print *
        ! call print_over_grid(size(shape(wfc1_r)), shape(wfc1_r), wfc1_r, center)
        ! ! print *, "shape of wfc2_r: ", shape(wfc2_r), "  and size:", size(wfc2_r)
        ! print *
        ! print *
        ! call print_over_grid(size(shape(wfc2_r)), shape(wfc2_r), wfc2_r, center)
        ! ! call inv_reshape_wfc(npw, grid_dim, grid, wfc1_r, f_g_out, center)
        ! ! call printComplexArray(f_g_out, npw, npw)

        ! ! ! fft backward R -> G
        ! ! allocate(f_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        ! ! call calc_fft(grid_dim, wfc1_r, f_g, .true.)
        ! ! f_g = f_g / size(f_g)
        ! ! call inv_reshape_wfc(npw, grid_dim, grid, f_g, f_g_out, center)
        ! ! call printComplexArray(f_g_out, npw, npw)


        ! ! calculate f_r = conjg(wfc1_r)* wfc2_r
        ! allocate(f_r(grid_dim(1), grid_dim(2), grid_dim(3)))
        ! f_r = conjg(wfc1_r) * wfc2_r
        ! deallocate(wfc1_r, wfc2_r)

        ! ! calculate f_g = ifft{f_r}
        ! allocate(f_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        ! call calc_fft(grid_dim, f_r, f_g, .true.)
        ! deallocate(f_r)
        ! f_g = f_g / size(f_g)

        ! ! reshape f_g
        ! call inv_reshape_wfc(npw, grid_dim, grid, f_g, f_g_out, center)
        ! ! call printComplexArray(f_g_out, npw, npw)
        




        

        



    end subroutine fftw_convolution


end module fg_calc
