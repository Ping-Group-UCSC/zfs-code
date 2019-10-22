module mpi_var

    use mpi

    implicit none

contains

    subroutine mpi_get_var( nproc, myrank, is_root)
    ! simple subroutine to get mpi variables

        ! internal variables
        integer              :: ierr
        integer, parameter   :: root_rank = 0
        ! output variables
        integer, intent(out) :: nproc, myrank
        logical, intent(out) :: is_root

        call MPI_COMM_RANK (MPI_COMM_WORLD, myrank, ierr)
        call MPI_COMM_SIZE (MPI_COMM_WORLD, nproc, ierr)

        if ( myrank .eq. root_rank ) then
            is_root = .true.
        else
            is_root = .false.
        end if

    end subroutine mpi_get_var

end module mpi_var