module indexmod

    implicit none

contains
    subroutine find_index(num_row, num_col, big_array, small_array, location)
    ! returns index of small_array in big_array if found
    ! if small array is not in big_array, returns zero

        integer, intent(in) :: num_row, num_col
        integer, dimension(num_row,num_col), intent(in) :: big_array
        integer, dimension(num_col), intent(in) :: small_array
        integer, intent(out) :: location
        integer :: i  ! dummy index

        location = 0
        do i = 1, num_row
            if (all(big_array(i,:) == small_array)) then
                location = i
                exit
            end if
        end do

    end subroutine find_index


end module indexmod
