module writemod

    use params, only : dp

    implicit none
    
contains

    subroutine write_grid(grid, npw, dim_G, file_G)
    ! write grid to formatted file

        integer, intent(in)                                 :: npw, dim_G
        integer, dimension(npw, dim_G), intent(in)          :: grid
        character(len=256), intent(in)                      :: file_G
        integer                                             :: i ! dummy index

        open (unit=10, file=file_G)
        do i = 1, npw
            write (10,*) grid(i,:)
        end do
        ! TODO -- add format to print?
        close (10)

    end subroutine write_grid


    subroutine write_wfc(wfc, npw, file_w)
    ! write wfc to formatted file
        
        integer, intent(in)                                 :: npw
        complex(dp), dimension(npw), intent(in)             :: wfc
        character(len=256), intent(in)                      :: file_w
        integer                                             :: i ! dummy index

        open (unit=10, file=file_w)
        do i = 1, npw
            write (10,100) real(wfc(i)), " , ", aimag(wfc(i))
        end do
        100 format(2x,e13.6e2,a3,e13.6e2)
        close(10)

    end subroutine write_wfc


    subroutine write_over_grid(array_rank, array_shape, array, file_w)
    ! write wfc as a rank 3 array (the shape it assumes in the fft subroutines)
        integer, intent(in)                                 :: array_rank
        integer, dimension(array_rank), intent(in)          :: array_shape
        complex(dp), dimension(array_shape(1), array_shape(2), array_shape(3)), &
            & intent(in)                                    :: array
        character(len=256), intent(in)                      :: file_w
        integer                                             :: i, j, k

        open (unit=10, file=file_w)
        do i = 1, array_shape(1)
            do j = 1, array_shape(2)
                do k = 1, array_shape(3)
                    write (10,100) i - 1, j - 1, k - 1, " :  ", & 
                        & real(array(i, j, k)), " , ", aimag(array(i, j, k))
                end do
            end do
        end do
        100 format (1x,i4,i4,i4,a,e14.6e3,a,e14.6e3)
        close(10)

    end subroutine write_over_grid


    subroutine write_grid_b(grid, npw, dim_G, file_G)
    ! write grid to unformatted binary file
    ! TODO -- have format be an option to pass to subroutine and combine with above

        integer, intent(in)                                 :: npw, dim_G
        integer, dimension(npw, dim_G), intent(in)          :: grid
        character(len=256), intent(in)                      :: file_G

        open (unit=10, file=file_G, form='unformatted')
        write (10) grid
        close (10)

    end subroutine write_grid_b


    subroutine write_wfc_b(wfc, npw, file_w)
    ! write wfc to unformatted binary file
    ! TODO -- have format be an option to pass to subroutine and combine with above
        
        integer, intent(in)                                 :: npw
        complex(dp), dimension(npw), intent(in)             :: wfc
        character(len=256), intent(in)                      :: file_w

        open (unit=10, file=file_w, form='unformatted')
        write (10) wfc
        close(10)

    end subroutine write_wfc_b


end module writemod
