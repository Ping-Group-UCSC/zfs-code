module main_inner

    use params,            only : dp
    use loop_var,          only : file_w_name
    use readmod,           only : read_wfc
    use fg_calc,           only : convolution, reflection, fftw_convolution
    use zfs_calc,          only : calc_rho, calc_I_zz
    use mpi_var,           only : mpi_get_var
    use convtime,          only : convtime_sub

    use printmod, only : printComplexArray

    implicit none

contains

    ! To-Do can pass in min and max to do making this easy to insert in mpi loop
    ! currently 1, tot_to_do is assumed (serial)

    subroutine inner_routine( direct_flag, npw, dim_G, grid, export_dir, loop_size, loop_array, I_zz_out )
    ! evaluates inner routine looping over loop_array values
    ! returns I_zz_out -- a portion of the I_zz value
    
        ! input variables
        integer, intent(in)                             :: npw, dim_G, loop_size
        integer, dimension(npw, dim_G), intent(in)      :: grid
        character(len=256), intent(in)                  :: export_dir
        integer, dimension(loop_size,3), intent(in)     :: loop_array
        logical                                         :: direct_flag

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
        
        ! testing flag !!!!!!! delete
        logical                                         :: ltest !!!!!!! delete


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

            ltest = .false.

            if (ltest) then !!!!!!! delete
                ! call fftw_convolution(npw, dim_G, grid, wfc1, wfc1, f1_G)
                call convolution(npw, dim_G, grid, wfc1, wfc1, f1_G)
                call printComplexArray(f1_G, npw, npw)
            else !!!!!!! delete

                if ( direct_flag ) then
                    call convolution(npw, dim_G, grid, wfc1, wfc1, f1_G)
                    call convolution(npw, dim_G, grid, wfc2, wfc2, f2_G)
                    call convolution(npw, dim_G, grid, wfc1, wfc2, f3_G)
                else
                    call fftw_convolution(npw, dim_G, grid, wfc1, wfc1, f1_G)
                    call fftw_convolution(npw, dim_G, grid, wfc2, wfc2, f2_G)
                    call fftw_convolution(npw, dim_G, grid, wfc1, wfc2, f3_G)
                end if

            end if !!!!!!! delete

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


end module main_inner