module main_inner

    use params,            only : dp
    use loop_var,          only : file_w_name
    use readmod,           only : read_wfc
    use fg_calc,           only : convolution, reflection, fftw_convolution
    use zfs_calc,          only : calc_rho, calc_I_zz
    use mpi_var,           only : mpi_get_var
    use convtime,          only : convtime_sub
    use writemod,          only : write_grid, write_wfc, write_over_grid
    use fftwmod,           only : calc_grid_dim, reshape_wfc

    implicit none

contains

    ! To-Do can pass in min and max to do making this easy to insert in mpi loop
    ! currently 1, tot_to_do is assumed (serial)

    subroutine inner_routine(verbosity, direct_flag, npw, dim_G, grid, export_dir, loop_size, loop_array, I_zz_out)
    ! evaluates inner routine looping over loop_array values
    ! returns I_zz_out -- a portion of the I_zz value
    
        ! input variables
        integer, intent(in)                             :: npw, dim_G, loop_size
        integer, dimension(npw, dim_G), intent(in)      :: grid
        character(len=256), intent(in)                  :: export_dir
        integer, dimension(loop_size,3), intent(in)     :: loop_array
        logical, intent(in)                             :: direct_flag
        character(len=16), intent(in)                   :: verbosity

        ! internal variables
        character(len=256)                              :: file_w1, file_w2
        integer                                         :: i_dumb
        complex(dp), allocatable                        :: wfc1(:), wfc2(:)
        complex(dp), allocatable                        :: f1_G(:), f2_G(:), f2_minusG (:), f3_G(:), rho_G(:)
        complex(dp)                                     :: I_zz_part

        ! mpi variables
        integer                                         :: nproc, myrank
        logical                                         :: is_root

        ! values for timing
        real :: start, current   ! internal values for printing timing
        real :: step, percent          ! i/num_row
        integer :: check, increment
        character(len=12) :: formatted_time !! output of conver_time

        ! return variables
        complex(dp), intent(out)                        :: I_zz_out


        ! get mpi variables
        call mpi_get_var(nproc, myrank, is_root)

        ! initialize timing
        call cpu_time(start)
        step = 0.10 ! can edit
        check = floor(step * real (loop_size))
        increment = check


        ! begin loop
        I_zz_out = 0
        do i_dumb = 1, loop_size

        !< Define file_w1 and file_w2 names >!
            call file_w_name(export_dir, loop_array(i_dumb,:), file_w1, file_w2)

        !< Read in complex array of wfc 1 and 2 (wfc1, wfc2) >!
            allocate (wfc1(npw), wfc2(npw))
            call read_wfc(file_w1,npw,wfc1)
            call read_wfc(file_w2,npw,wfc2)

            

        !< Calculate f1(G), f2(-G), f3(G) >!
            allocate (f1_G(npw), f2_G(npw), f2_minusG(npw), f3_G(npw))


            if ( direct_flag ) then
                call convolution(npw, dim_G, grid, wfc1, wfc1, f1_G)
                call convolution(npw, dim_G, grid, wfc2, wfc2, f2_G)
                call convolution(npw, dim_G, grid, wfc1, wfc2, f3_G)
            else
                call fftw_convolution(npw, dim_G, grid, wfc1, wfc1, f1_G, verbosity, 1)
                call fftw_convolution(npw, dim_G, grid, wfc2, wfc2, f2_G, verbosity, 2)
                call fftw_convolution(npw, dim_G, grid, wfc1, wfc2, f3_G, verbosity, 3)
            end if

            if ( verbosity == "high" ) then
                call inner_verbosity(npw, dim_G, grid, wfc1, wfc2, f1_G, f2_G, f3_G)
            end if

            ! call printComplexArray(f1_G, npw, npw)

            call reflection(npw, dim_G, grid, f2_G, f2_minusG)
            deallocate (wfc1, wfc2, f2_G)

        !< Calculate ρ(G,-G) >!
            allocate (rho_G(npw))
            call calc_rho(npw,f1_G,f2_minusG,f3_G,rho_G)

            ! done with f(G) functions
            deallocate (f1_G, f2_minusG, f3_G)

        !< Calculate matrix element I_zz >!
            call calc_I_zz(npw,dim_G,grid,rho_G,I_zz_part)
            
            ! done with rho_G
            deallocate (rho_G)
        
        !< Sum I_zz part within loop >!
            if (loop_array(i_dumb,1) == 2) then
                I_zz_out = I_zz_out - I_zz_part
            else ! ((loop_array(i_dumb,1) == 1) .or. (loop_array(i_dumb,1) == 3))
                I_zz_out = I_zz_out + I_zz_part
            end if
        

        !< timing lines >!
            if ( is_root ) then
                if ( i_dumb .ge. check ) then
                    percent = real(i_dumb)/real(loop_size)
                    call cpu_time(current)
                    call convtime_sub(current, formatted_time)
                    print "(a15,f4.2,a13,a12)", "     Progress: ",percent,"   cpu_time: ", formatted_time
                    check = check + increment
                end if
            end if


        end do ! i_dumb loop
            
    
    end subroutine inner_routine


    subroutine inner_verbosity(npw, dim_G, grid, wfc1, wfc2, f1_G, f2_G, f3_G)

        integer, intent(in)                             :: npw, dim_G
        integer, dimension(npw, dim_G), intent(in)      :: grid
        complex(dp), dimension(npw), intent(in)         :: wfc1, wfc2, f1_G, f2_G, f3_G

        ! internal
        character(len=16)                               :: dump_dir = "zfs.dump"
        character(len=256)                              :: dump_gr, dump_w1, dump_w2, dump_f1, dump_f2, dump_f3
        integer, dimension(3)                           :: grid_dim
        complex(dp), allocatable                        :: wfc(:,:,:) ! dummy for file dumping
        integer, parameter                              :: center = 0

        call calc_grid_dim(npw, grid, grid_dim)
        allocate(wfc(grid_dim(1), grid_dim(2), grid_dim(3)))


        call execute_command_line('if [ ! -d zfs.dump ]; then mkdir zfs.dump; fi')

        dump_gr = trim(dump_dir) // "/grid.txt"
        dump_w1 = trim(dump_dir) // "/wfc1.txt"
        dump_w2 = trim(dump_dir) // "/wfc2.txt"
        dump_f1 = trim(dump_dir) // "/f1_G.txt"
        dump_f2 = trim(dump_dir) // "/f2_G.txt"
        dump_f3 = trim(dump_dir) // "/f3_G.txt"
        call write_grid(grid, npw, dim_G, dump_gr)
        call write_wfc(wfc1, npw, dump_w1)
        call write_wfc(wfc2, npw, dump_w2)
        call write_wfc(f1_G, npw, dump_f1)
        call write_wfc(f2_G, npw, dump_f2)
        call write_wfc(f3_G, npw, dump_f3)


        dump_w1 = trim(dump_dir) // "/wfc1-og.txt"
        dump_w2 = trim(dump_dir) // "/wfc2-og.txt"
        dump_f1 = trim(dump_dir) // "/f1_G-og.txt"
        dump_f2 = trim(dump_dir) // "/f2_G-og.txt"
        dump_f3 = trim(dump_dir) // "/f3_G-og.txt"
        call reshape_wfc(npw, grid_dim, grid, wfc1, wfc, center)
        call write_over_grid(size(shape(wfc)), shape(wfc), wfc, dump_w1)
        call reshape_wfc(npw, grid_dim, grid, wfc2, wfc, center)
        call write_over_grid(size(shape(wfc)), shape(wfc), wfc, dump_w2)
        call reshape_wfc(npw, grid_dim, grid, f1_G, wfc, center)
        call write_over_grid(size(shape(wfc)), shape(wfc), wfc, dump_f1)
        call reshape_wfc(npw, grid_dim, grid, f2_G, wfc, center)
        call write_over_grid(size(shape(wfc)), shape(wfc), wfc, dump_f2)
        call reshape_wfc(npw, grid_dim, grid, f3_G, wfc, center)
        call write_over_grid(size(shape(wfc)), shape(wfc), wfc, dump_f3)



    end subroutine inner_verbosity


end module main_inner