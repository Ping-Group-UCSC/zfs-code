module loop_var

    implicit none

contains
    subroutine max_index(ispin, band_max, occ_up, occ_dn, iband_max, jband_max)
    ! for each loop of ispin different upper limits (iband_max/jband_max) must be used..
    ! based on spin occupation (occ_up/occ_dn) and band_max
    ! returns two integers: iband_max and jband_max

        ! input variables
        integer, intent(in)  :: ispin, band_max, occ_up, occ_dn

        ! output variables
        integer, intent(out) :: iband_max, jband_max

        ! define spin up max
        if ( band_max < occ_dn ) then
            iband_max = band_max
        else
            iband_max = occ_dn
        end if

        ! define spin dn max
        if ( band_max < occ_up ) then
            jband_max = band_max
        else
            jband_max = occ_up
        end if

        ! if ispin = 1 then j_max = i_max = spin up max
        if ( ispin == 1 ) then
            iband_max = jband_max
        ! if ispin = 3 then i_max = j_max = spin dn max
        else if ( ispin == 3 ) then
            jband_max = iband_max
        end if
        ! otherwise (ispin = 2) and i_max/j_max are correctly defined above


    end subroutine max_index


    subroutine file_w_name(export_dir, loop_array_piece, file_i, file_j)
    ! subroutine for generating wfc file names to be read
    ! outputs file_w1 and file_w2 which both have the format:
    !       export_dir/wfc(spin)_(band).txt
    ! 'ispin' and 'band' are read in via loop_array_piece
        
        ! input variables
        character (len=256), intent(in)     :: export_dir
        integer, dimension(3), intent(in)   :: loop_array_piece

        ! internal variables
        character(len=10)                   :: str_iband, str_jband   ! converted integer band index to string
        character(len=5)                    :: pre_i, pre_j              ! prefix for wfc file name

        ! output variables
        character (len=256), intent(out)    :: file_i, file_j

        ! convert i and j to strings -- flipped which file is read by wfc1 and wfc2 compared to older implementation
        write (str_iband, "(i5)") loop_array_piece(3)
        write (str_jband, "(i5)") loop_array_piece(2)

        ! define prefix of wfc file names
        if ( loop_array_piece(1) == 1 ) then
            pre_i = "wfc1_"
            pre_j = "wfc1_"
        else if ( loop_array_piece(1) == 2 ) then
            pre_i = "wfc2_"
            pre_j = "wfc1_"
        else ! if ( loop_array_piece(1) == 3 ) then
            pre_i = "wfc2_"
            pre_j = "wfc2_"
        end if

        ! define file names with full path
        file_j = trim(export_dir) // "/" // pre_j // trim(adjustl(str_iband)) // ".txt"
        file_i = trim(export_dir) // "/" // pre_i // trim(adjustl(str_jband)) // ".txt"

        ! print which wfc's are being worked on
        ! print *, "Working on ", ( pre_i // trim(adjustl(str_iband)) ), " and ", ( pre_j // trim(adjustl(str_jband)) )

    end subroutine file_w_name


    subroutine init_loop_array(band_min, band_max, occ_up, occ_dn, loop_size, loop_array)
    ! intialize loop_array variable
    ! outut loop_size and loop_array
    ! loop_array = ((ispin, iband, jband), ... )

        ! input variables
        integer, intent(in)                 :: band_min, band_max, occ_up, occ_dn

        ! internal variables
        integer                             :: ispin, iband, jband, iband_max, jband_max

        ! return variables
        integer, intent(out)                :: loop_size
        integer, allocatable, intent(out)   :: loop_array(:,:)

        ! calculate loop_size in order to allocate correct space for loop_array
        loop_size = 0
        do ispin = 1, 3
            ! calc i_mac and j_max
            call max_index(ispin, band_max, occ_up, occ_dn, iband_max, jband_max)

            do iband = band_min, iband_max
                do jband = iband, jband_max

                    ! if (( jband == iband ) .and. ( ispin .ne. 2 )) then
                    if ( jband == iband ) then
                        cycle
                    end if

                    loop_size = loop_size + 1

                end do
            end do

        end do

        ! allocate loop_array and generate loop_array (loop_size is rewritten)
        allocate(loop_array(loop_size,3))
        loop_size = 0
        do ispin = 1, 3
            call max_index(ispin,band_max, occ_up, occ_dn, iband_max, jband_max)

            do iband = band_min, iband_max
                do jband = iband, jband_max

                    ! if (( jband == iband ) .and. ( ispin .ne. 2 )) then
                    if ( jband == iband ) then
                        cycle
                    end if

                    loop_array(loop_size + 1, 1) = ispin
                    loop_array(loop_size + 1, 2) = iband
                    loop_array(loop_size + 1, 3) = jband
                    loop_size = loop_size + 1

                end do
            end do
            
        end do

    end subroutine init_loop_array


end module loop_var
