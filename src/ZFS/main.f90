!
!  Original Version Created Wed. June 19th 2019 by Tyler J. Smart
!  This code calculates the ZFS parameter as in the PRB:
!    ”First principles method for the calculation of zero-field splitting tensors in periodic systems”,
!    M. J. Rayson and P. R. Briddon, Physical Review B 77, 035119 (2008)
!


program main

!< modules and subroutines >!
    use params,            only : dp, tcell
    use mpi_var,           only : mpi_get_var
    use intro_outro,       only : intro, outro
    use input,             only : command_input, parse_input, print_input
    use loop_var,          only : init_loop_array, read_all_wfc
    use readmod,           only : read_length, read_grid, read_wfc, read_cell
    use printmod,          only : printIntegerArray, printComplexArray, print_cell, print_real_array, print_eigs
    use main_inner,        only : inner_routine
    use main_mpi,          only : mpi_routine
    use zfs_calc,          only : calc_D_ab, zfs_parameters
    ! use linalg,            only : eigenvalues_symmetric
    use mpi

    implicit none

    
!< user input variables >!
    character(len=256)          :: file_in, export_dir
    real(dp)                    :: alat
    integer                     :: band_min, band_max, occ_up, occ_dn
    logical                     :: direct_flag
    character(len=16)           :: verbosity

!< read in from converted_export >!
    type(tcell)                 :: cell

!< internal variables >!
    ! mpi variables
    integer                     :: nproc, ierr, myrank, root_rank
    logical                     :: is_root
    ! loop array containing ispin, iband , and jband
    integer, allocatable        :: loop_array(:,:)
    integer                     :: loop_size
    ! dimensions and file names
    integer                     :: npw, dim_G = 3
    character(len=256)          :: file_G, file_wfc, file_cell
    ! main functions
    integer, allocatable        :: grid(:,:)                                            ! dim (npw,3)
    complex(dp), allocatable    :: wfc1(:), wfc2(:)                                     ! dim (npw) defined over grid
    complex(dp), allocatable    :: f1_G(:), f2_G(:), f2_minusG (:), f3_G(:), rho_G(:)   ! dim (npw) defined over grid
    real(dp), dimension(3,3)    :: I_ab
    integer                     :: idumb
    ! other
    character(len=4)            :: indent="    "
    character(len=64)           :: prog="ZFS"

!< output variables >!
    ! ZFS parameters in eV, GHz, and cm-1
    real(dp), dimension(3,3)    :: D_en, D_fr1, D_fr2, evecs
    real(dp), dimension(3)      :: eigs


    ! new
    integer                     :: nbnd
    complex(dp), allocatable    :: wfc_all(:,:,:)


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                            Beginning program                              !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!< initialize mpi and get nproc, myrank, and is_root >!
    call MPI_INIT (ierr) 
    call mpi_get_var(nproc, myrank, is_root)

!< print introduction >!
    if ( is_root ) then
        call intro(prog)
    end if

!< Read input file >!
    call command_input(file_in)
    call parse_input(file_in, export_dir, band_min, band_max, occ_up, occ_dn, alat, direct_flag, verbosity)
    if ( is_root ) then
        call print_input( file_in, export_dir, band_min, band_max, occ_up, occ_dn, alat, direct_flag, verbosity)
    end if

!< Read in number of plane waves (npw) >!
    file_G  = trim(export_dir) // "/" // "grid.txt"
    call read_length(file_G,npw)

!< Read in grid of G vectors (grid) >!
    allocate (grid(npw,dim_G))
    call read_grid(file_G,npw,dim_G,grid)

!< Read in cell >!
    file_cell = trim(export_dir) // "/" // "cell.txt"
    call read_cell(file_cell, cell)
    ! if ( is_root ) call print_cell(cell)


!< Begin Calculation >!
    if ( is_root ) then
        print *
        print *, "================================"
        print *, "Beginning Calculation of ZFS"
        print *
    end if

!< Below begins structure of do loop over bands specified by input file !

    ! create loop_array = ((ispin, i, j) ... )
    call init_loop_array(band_min, band_max, occ_up, occ_dn, loop_size, loop_array)

    ! Read in all wfc
    if ( is_root ) then
        print *, indent, "Reading wavefunction files from ", trim(export_dir)
        print *, indent, indent, "this may take some time ..."
    end if
    call read_all_wfc(npw, export_dir, loop_size, loop_array, wfc_all)
    if ( is_root ) then
        print *, indent, "Done reading wavefunction files!"
        print *
    end if

    ! Report information
    if ( is_root ) then
        print "(a5,a29,i15)", indent, "number of steps to compute = ", loop_size
        if ( loop_size .le. 20 ) call printIntegerArray(loop_array, loop_size, 3, loop_size)
        print *, indent, "nspin, nbnd, npw = ", shape(wfc_all)
        print *
    end if

    nbnd = size(wfc_all(1,:,1))
    
    ! if ( is_root ) call check_wfc_all(size(wfc_all(:,1,1)), size(wfc_all(1,:,1)), size(wfc_all(1,1,:)), wfc_all)

!< Call to the main subroutine which compute I_ab >!
    if ( is_root ) print *, indent, "computing D_ab"
    ! call mpi_routine(verbosity, direct_flag, npw, dim_G, grid, cell%b, export_dir, loop_size, loop_array, I_ab)
    call mpi_routine(verbosity, direct_flag, npw, dim_G, grid, nbnd, wfc_all, cell%b, export_dir, loop_size, loop_array, I_ab)


!< Calculate ZFS >!
    if ( is_root ) then
        print *
        print *, "================================"
        print *, "Matrix D_ab (GHz) = "
        call calc_D_ab(cell%omega, I_ab, D_en, D_fr1, D_fr2)
        call print_real_array(D_fr1, 3, 3)

        ! print *
        ! print *, "================================"
        ! print *, "Computing Eigenvalues of D_ab"
        ! call eigenvalues_symmetric(D_fr1, 3, eigs, evecs)
        ! call print_eigs(eigs, evecs, 3)

        ! print *
        ! print *, "================================"
        ! print *, "Zero Field Splitting Parameters"
        ! call zfs_parameters(eigs, evecs)
    end if


!< print outro >!
    if ( is_root ) then
        call outro()
    end if

    call MPI_FINALIZE (ierr)


end program main


subroutine check_wfc_all(nspin, nbnd, npw, wfc_all)

    use params, only : dp
    use printmod, only : printComplexArray

    integer, intent(in)                                     :: nspin, nbnd, npw
    complex(dp), dimension(nspin, nbnd, npw), intent(in)    :: wfc_all

    integer :: ispin, iband


    do ispin = 1, nspin
        do iband = 1, nbnd
            print *, "Here is wfc ", ispin, " ", iband
            call printComplexArray(wfc_all(ispin,iband,:), npw, npw)
            print *
            print *
        end do
    end do



end subroutine check_wfc_all
