module main_mpi

    use params,            only : dp
    use main_inner,        only : inner_routine
    use printmod,          only : printIntegerArray
    use mpi_var,           only : mpi_get_var
    use mpi

    implicit none

contains

    subroutine mpi_routine(verbosity, direct_flag, npw, dim_G, grid, export_dir, loop_size, loop_array, I_zz)
    ! evaluates inner routine looping over loop_array values
    ! returns I_zz_out -- a portion of the I_zz value
    
        ! input variables -- fed to inner loop
        integer, intent(in)                             :: npw, dim_G, loop_size
        integer, dimension(npw, dim_G), intent(in)      :: grid
        character(len=256), intent(in)                  :: export_dir
        integer, dimension(loop_size,3), intent(in)     :: loop_array
        logical                                         :: direct_flag
        character(len=16), intent(in)                   :: verbosity
        
        ! mpi variables
        integer                                         :: nproc, myrank, root_rank
        logical                                         :: is_root
        integer                                         :: ierr, status(MPI_STATUS_SIZE)

        ! internal variables -- dummy variables
        integer                                         :: arank, i, remainder
        ! internal variables -- interfaced with inner_routine
        integer                                         :: myloop_size, mystart
        integer, allocatable                            :: myloop_array(:,:)
        complex(dp)                                     :: myI_zz, yourI_zz

        ! return variables
        complex(dp), intent(out)                        :: I_zz

        call mpi_get_var(nproc, myrank, is_root)

        if ( is_root ) then
            root_rank = myrank
        end if


        ! calculate lowest loop size (integer division) and remainder
        myloop_size = loop_size / nproc
        remainder = mod(loop_size, nproc)

        ! increase loop size in case of a remainder
        if ( myrank .lt. remainder ) then
            myloop_size = myloop_size + 1
        end if

        ! calculate starting position
        if (myrank .lt. remainder ) then
            mystart = myloop_size * myrank + 1
        else
            mystart = myloop_size * myrank + remainder + 1
        end if

        ! allocate loop_array and form from subsection of loop_array defined by start and loop size
        allocate( myloop_array( myloop_size, 3 ) )
        ! print *, myrank, "'s start is: ", mystart, "  and end is", mystart + myloop_size -1
        do i = 1, myloop_size
            myloop_array( i, : ) = loop_array( (mystart + i - 1), : )
        end do

        ! ! compare with full loop array
        ! print *, myrank, "'s loop array is: "
        ! call printIntegerArray( myloop_array, myloop_size, 3, myloop_size )

        ! compute inner routine
        call inner_routine(verbosity, direct_flag, npw, dim_G, grid, export_dir, myloop_size, myloop_array, myI_zz)


        ! ! report myI_zz
        ! print *, "My rank is ", myrank, " myI_zz is ", myI_zz



        ! collect and sum myI_zz into final I_zz
        call MPI_REDUCE(myI_zz, I_zz, 1, MPI_DOUBLE_COMPLEX, MPI_SUM, root_rank, MPI_COMM_WORLD, ierr)


        
    
    end subroutine mpi_routine


end module main_mpi