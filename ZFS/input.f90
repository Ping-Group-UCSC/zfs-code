!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
!%%      Read input file      %%
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

module input

    implicit none

contains
    subroutine command_input(file_in)
    ! read command_input
    ! reuses code from input "inpfile.f90" from QE code
    ! return name of input file "file_in"

        character(len=256) :: input_file
        character(len=256), intent(out) :: file_in

        integer :: narg ! internal parameter
        integer :: i ! dummy index
        logical :: found


        found = .false.
        narg = command_argument_count()
        input_file = ' '

        do i = 1, (narg -1)
            call get_command_argument(i,input_file)
            if ( trim(input_file) == '-i'     .or. &
                 trim(input_file) == '-in'    .or. &
                 trim(input_file) == '-inp'   .or. &
                 trim(input_file) == '-input' ) then

                call get_command_argument((i+1),input_file)
                found = .true.
                exit
            end if
        end do

        file_in = input_file

    end subroutine command_input


    subroutine parse_input(file_in, export_dir, band_min, band_max, occ_up, occ_dn, alat, direct_flag)
    ! read input file
    ! ideas:
    !    -> read in export_dir, band_min, band_max, occ_min, occ_dn, alat
    !    -> other possibility: cut (user can limit the number of plane waves used)
    !       -- would require subroutine to reduce Grid
    !    -> other possibility: verbosity (low= regular, mid= more, high= prints everything)
    ! for high verbosity mode; could think about file generation to save f(G)'s

    ! need to add some errors for input file -- most common type of mistake for user

    ! Example input file: (order matters!)
    ! Arbitrary title                  ! first line ignored
    ! export_dir = "Path/to/export/"   ! path to export_dir files
    ! band_min = 124                   ! minimum band index used in calculation
    ! band_max = 128                   ! maximum band index used in calculation
    ! occ_up = 128                     ! number of spin up occupied states
    ! occ_dn = 126                     ! number of spin down occupied states
    ! alat = 7.1365880966D0            ! lattice constant in angstrom
    ! direct_flag = .false.            ! if true, preform direct convolution instead of fft

        use params, only : dp
        character(len=256), intent(in)      :: file_in
        character(len=256), intent(out)     :: export_dir
        integer, intent(out)                :: band_min, band_max, occ_up, occ_dn
        real(dp), intent(out)               :: alat
        logical, intent(out)                :: direct_flag

        character(len=20) :: label        ! internal value; ignored
        character(len=10) :: separator    ! internal value; ignored
        ! character(len=4) :: indent="    " ! internal value; for formatting printed output

        open (2, file=file_in)
          read(2,*) ! 1st line ignored
          read(2,*) label, separator, export_dir
          read(2,*) label, separator, band_min
          read(2,*) label, separator, band_max
          read(2,*) label, separator, occ_up
          read(2,*) label, separator, occ_dn
          read(2,*) label, separator, alat
          read(2,*) label, separator, direct_flag
        close(2)

    end subroutine
    

    subroutine print_input ( file_in, export_dir, band_min, band_max, occ_up, occ_dn, alat, direct_flag )
    ! print parsed input for user

        use params, only : dp

        ! input variables
        character(len=256), intent(in)  :: file_in
        character(len=256), intent(in)  :: export_dir
        integer, intent(in)             :: band_min, band_max, occ_up, occ_dn
        real(dp), intent(in)            :: alat
        logical, intent(in)             :: direct_flag

        ! internal variables
        character(len=4) :: indent="    "

        print *, "Input file read from: ",trim(file_in)
        print *," ",                   indent, "Parsing input file"
        print *," ",                   indent, "Read Grid and wfc from  : ", " ", trim(export_dir)
        print "(a5,a27,i5,a6,i5,a5)",  indent, "Bands to be included    : ", band_min, "(Min) ", band_max, "(Max)"
        print "(a5,a27,i5,a6,i5,a5)",  indent, "Occupied states         : ", occ_up, "(Up)  ", occ_dn, "(Dn) "
        print "(a5,a27,f10.6)",        indent, "Lattice Parameter (Ang) : ", alat
        if ( direct_flag ) then
            print *," ",                   indent, "Convolution             : ", " Direct"
        else
            print *," ",                   indent, "Convolution             : ", " FFT"
        end if

        print *
        
    end subroutine

end module input
