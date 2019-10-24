module fg_calc

    use params, only : dp
    use indexmod, only : find_index
    use writemod,          only : write_grid, write_wfc, write_over_grid
    use fftwmod

    implicit none

contains
    subroutine convolution(num_row,dim_G,Grid,wfc1,wfc2,f_G)
    ! evaluates convolution of wfc1 and wfc2
    ! f(G) = sum_G' conjg(wfc1(G-G')) * wfc2(G')
    ! note wfc1 and wfc2 needn't be wfc1/wfc2 of main program
    ! returns complex array f_G of dim num_row
        use omp_lib
        use convtime, only : convtime_sub

        integer, intent(in) :: num_row, dim_G
        integer, dimension(num_row,dim_G), intent(in) :: Grid
        complex(dp), dimension(num_row), intent(in) :: wfc1, wfc2
        complex(dp), dimension(num_row), intent(out) :: f_G

        integer, dimension(dim_G) :: gvec, gpvec, diff ! internal arrays

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
                call find_index(num_row,dim_G,Grid,diff,k)   ! if diff not in Grid: return 0; else: return index of G-G'
                if ( k .ne. 0 ) then                           ! if diff not 0: evaluate sum_value; else: wfc1(G-G') ~ 0 and sum_value not changed
                    sum_value = sum_value + conjg(wfc1(k)) * wfc2(j)
                end if
            end do
            f_G(i) = sum_value

        end do
        !$OMP end do

        !$OMP END PARALLEL

    end subroutine convolution

    subroutine reflection(num_row,dim_G,Grid,f_G,f_minusG)
    ! reflects f2(G) to obtain f2(-G)
    ! i -> G -> -G -> j   (j determined by find_index)
    ! f_minusG(i) = f_G(j)
    ! returns complex array f_minusG of dim num_row

        integer, intent(in) :: num_row, dim_G
        integer, dimension(num_row,dim_G), intent(in) :: Grid
        complex(dp), dimension(num_row), intent(in) :: f_G
        complex(dp), dimension(num_row), intent (out) :: f_minusG

        integer, dimension(dim_G) :: minusG ! internal vector
        integer :: i,j ! dummy index

        do i = 1, num_row
            minusG = -Grid(i,:)
            call find_index(num_row,dim_G,Grid,minusG,j) ! find minusG in Grid ; return j
            f_minusG(i) = f_G(j)
        end do

    end subroutine reflection


    subroutine fftw_convolution(npw, dim_G, grid, wfc1, wfc2, f_g_out, verbosity, step)
    ! evaluates fft_convolution of wfc1 and wfc2
    ! f(G) = ifft{ conjg(wfc1_r) * wfc2_r }
    ! returns complex array f_G of dim npw

        use convtime, only : convtime_sub
        use printmod

        !!!! verbosity
        character(len=16), intent(in) :: verbosity
        ! this is used to tell which step we are on for verbosity printing
        integer, intent(in) :: step

        integer, intent(in) :: npw, dim_G
        integer, dimension(npw, dim_G), intent(in)              :: grid
        complex(dp), dimension(npw), intent(in)                 :: wfc1, wfc2
        integer, dimension(3)                                   :: grid_dim
        complex(dp), allocatable                                :: &
            & wfc1_g(:,:,:), wfc2_g(:,:,:), wfc1_r(:,:,:), wfc2_r(:,:,:), &
            & f_r(:,:,:), f_g(:,:,:)
        integer, parameter                                      :: center = 0 ! 
        complex(dp), dimension(npw), intent(out)                :: f_g_out

        call calc_grid_dim(npw, grid, grid_dim)

        !TODO -- in place fourier transforms to avoid disgusting code

        ! TODO -- here we can make wfc1 & wfc2 artificially larger with extra padded zeroes
        allocate(wfc1_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        allocate(wfc2_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        wfc1_g = complex(0, 0)
        wfc2_g = complex(0, 0)
        ! reshape to rank 3 over grid explicit with positive indices following fftw structure
        call reshape_wfc(npw, grid_dim, grid, wfc1, wfc1_g, center)
        call reshape_wfc(npw, grid_dim, grid, wfc2, wfc2_g, center)

        ! calculate fft g -> r
        allocate(wfc1_r(grid_dim(1), grid_dim(2), grid_dim(3)))
        allocate(wfc2_r(grid_dim(1), grid_dim(2), grid_dim(3)))
        call calc_fft(grid_dim, wfc1_g, wfc1_r, .false.)
        call calc_fft(grid_dim, wfc2_g, wfc2_r, .false.)
        deallocate(wfc1_g, wfc2_g)

        ! calculate f_r = conjg(wfc1_r)* wfc2_r
        allocate(f_r(grid_dim(1), grid_dim(2), grid_dim(3)))
        f_r = conjg(wfc1_r) * wfc2_r

        ! under verbosity high mode print real space wavefunctions and f(r)
        if ( verbosity == "high" ) then
            call fft_verbosity(npw, dim_G, grid, grid_dim, wfc1_r, wfc2_r, f_r, step)
        end if
        deallocate(wfc1_r, wfc2_r)

        ! calculate f_g = ifft{f_r}
        allocate(f_g(grid_dim(1), grid_dim(2), grid_dim(3)))
        call calc_fft(grid_dim, f_r, f_g, .true.)
        deallocate(f_r)
        f_g = f_g / size(f_g)

        ! reshape f_g
        call inv_reshape_wfc(npw, grid_dim, grid, f_g, f_g_out, center)      

    end subroutine fftw_convolution


    subroutine fft_verbosity(npw, dim_G, grid, grid_dim, wfc1_r, wfc2_r, f_r, step)
        
        integer, intent(in)                                             :: step, npw, dim_G
        integer, dimension(npw, dim_G), intent(in)                      :: grid
        integer, dimension(3), intent(in)                               :: grid_dim
        complex(dp), dimension(grid_dim(1), grid_dim(2), grid_dim(3))   :: wfc1_r, wfc2_r, f_r
        ! internal
        complex(dp), dimension(npw)                     :: wfc ! dummy array for dumping
        integer, parameter                              :: center = 0
        character(len=16)                               :: dump_dir = "zfs.dump"
        character(len=256)                              :: dump_f

        wfc = complex(0, 0)
        
        call execute_command_line('if [ ! -d zfs.dump ]; then mkdir zfs.dump; fi')

        if ( step == 1 ) then
            ! step 1 => dump f1(r)
            dump_f = trim(dump_dir) // "/f1_r-og.txt"
            call write_over_grid(size(shape(f_r)), shape(f_r), f_r, dump_f)
            call inv_reshape_wfc(npw, grid_dim, grid, f_r, wfc, center)
            dump_f = trim(dump_dir) // "/f1_r.txt"
            call write_wfc(wfc, npw, dump_f)
        else if ( step == 2 ) then
            ! step 2 => dump f2(r)
            dump_f = trim(dump_dir) // "/f2_r-og.txt"
            call write_over_grid(size(shape(f_r)), shape(f_r), f_r, dump_f)
            call inv_reshape_wfc(npw, grid_dim, grid, f_r, wfc, center)
            dump_f = trim(dump_dir) // "/f2_r.txt"
            call write_wfc(wfc, npw, dump_f)
        else if ( step == 3 ) then
            ! step 3 => dump f3(r)
            dump_f = trim(dump_dir) // "/f3_r-og.txt"
            call write_over_grid(size(shape(f_r)), shape(f_r), f_r, dump_f)
            call inv_reshape_wfc(npw, grid_dim, grid, f_r, wfc, center)
            dump_f = trim(dump_dir) // "/f3_r.txt"
            call write_wfc(wfc, npw, dump_f)
            ! in step 3 also dump wfc1_r and wfc2_r
            dump_f = trim(dump_dir) // "/wfc1_r-og.txt"
            call write_over_grid(size(shape(wfc1_r)), shape(wfc1_r), wfc1_r, dump_f)
            call inv_reshape_wfc(npw, grid_dim, grid, wfc1_r, wfc, center)
            dump_f = trim(dump_dir) // "/wfc1_r.txt"
            call write_wfc(wfc, npw, dump_f)
            dump_f = trim(dump_dir) // "/wfc2_r-og.txt"
            call write_over_grid(size(shape(wfc2_r)), shape(wfc2_r), wfc2_r, dump_f)
            call inv_reshape_wfc(npw, grid_dim, grid, wfc2_r, wfc, center)
            dump_f = trim(dump_dir) // "/wfc2_r.txt"
            call write_wfc(wfc, npw, dump_f)
        end if

    end subroutine fft_verbosity


end module fg_calc
