module readmod

    use params, only : dp

    implicit none

contains

    subroutine read_length(file_in, length)

        character(len=256), intent(in)                      :: file_in
        integer, intent(out)                                :: length

        length = 0
        open(unit=2, file=file_in)
        do
            read (2,*,end=10)
            length=length+1
        end do
        10 close (2)

    end subroutine read_length


    subroutine read_grid(file_in, num_row, num_col, array_out)

        character(len=256), intent(in)                      :: file_in
        integer, intent(in)                                 :: num_row, num_col
        integer, dimension(num_row,num_col), intent(out)    :: array_out
        integer                                             :: i,j ! dummy index

        open(unit=2, file=file_in)
        do i = 1,num_row
            read(2,*) (array_out(i,j), j=1,num_col)
        end do
        close(2)

    end subroutine read_grid


    subroutine read_wfc(file_in, num_row, array_out)

        character(len=256), intent(in)                      :: file_in
        integer, intent(in)                                 :: num_row
        complex(dp), dimension(num_row), intent(out)        :: array_out
        integer                                             :: i ! dummy index

        open(unit=2, file=file_in)
        do i = 1,num_row
            read(2,*) array_out(i)
        end do
        close(2)

    end subroutine read_wfc


    subroutine read_cell(file_in, cell)

        use params, only : dp, tcell

        character(len=256), intent(in)                      :: file_in
        type(tcell), intent(out)                            :: cell
        integer                                             :: i, j
        
        open(unit=2, file=file_in)
        read(2,*) cell%omega
        do i = 1, 3
            read(2,*) (cell%a(i,j), j=1,3)
        end do
        do i = 1, 3
            read(2,*) (cell%b(i,j), j=1,3)
        end do
        close(2)
    
    end subroutine read_cell


end module
