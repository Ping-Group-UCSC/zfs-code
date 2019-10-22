module printmod

    use params, only : dp

    implicit none

contains

    subroutine printIntegerArray(array_in, num_row, num_col, num_lines)
    ! prints integer array for display (e.g. Grid)

        integer, intent(in)                                 :: num_row, num_col
        integer, dimension(num_row,num_col), intent(in)     :: array_in
        integer, intent(in)                                 :: num_lines
        integer                                             :: i ! dummy index

        do i = 1,num_lines
            print *, array_in(i,:)
        end do
        print *

    end subroutine printIntegerArray


    subroutine printComplexArray(array_in, num_row, num_lines)
    ! prints complex array for display e.g. wfc, f_G, rho_G

        integer, intent(in)                                 :: num_row
        complex(dp), dimension(num_row), intent(in)         :: array_in
        integer, intent(in)                                 :: num_lines
        integer                                             :: i ! dummy index

        do i = 1,num_lines
            print "(a2,e13.6e2,a3,e13.6e2)", "  ", real(array_in(i)), " , ", aimag(array_in(i))
        end do
        print *

    end subroutine printComplexArray


    subroutine print_over_grid(array_rank, array_shape, array)
        
        integer, intent(in)                                 :: array_rank
        integer, dimension(array_rank), intent(in)          :: array_shape
        complex(dp), dimension(array_shape(1), array_shape(2), array_shape(3)), &
            & intent(in)                                    :: array
        integer                                             :: i, j, k


        do i = 1, array_shape(1)
            do j = 1, array_shape(2)
                do k = 1, array_shape(3)
                    print 100, i - 1, j - 1, k - 1, " :  ", & 
                        & real(array(i, j, k)), " , ", aimag(array(i, j, k))
                end do
            end do
        end do

        100 format (1x,i4,i4,i4,a,e14.6e3,a,e14.6e3)
        print *

    end subroutine print_over_grid


end module printmod
