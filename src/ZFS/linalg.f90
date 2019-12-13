module linalg

    use params,            only : dp

    implicit none

contains


    subroutine eigenvalues_symmetric(matrix, dim, eigs, evecs)
    ! compute eigenvalues and eigenvectors of a symmetric matrix
    ! input: square symmetric matrix of rank (dim)
    ! output: eigs (length dim), evecs (dim x dim)
        
        ! input
        integer, intent(in)         :: dim
        real(dp), intent(in)        :: matrix(dim, dim)
        ! internal
        integer                     :: LWORK, INFO
        integer, parameter          :: LWMAX = 1000
        real(dp)                    :: WORK(LWMAX)
        ! output
        real(dp), intent(out)       :: evecs(dim, dim), eigs(dim)

        ! copy matrix
        evecs = matrix
        ! query
        LWORK = -1
        call dsyev( 'Vectors', 'Upper', 3, evecs, 3, eigs, WORK, LWORK, INFO )
        LWORK = min( LWMAX, int( WORK( 1 ) ) )
        ! preform solver
        call dsyev( 'Vectors', 'Upper', 3, evecs, 3, eigs, WORK, LWORK, INFO )

        if  ( INFO > 0 ) then
            print *, 'Failed to compute eigenvalues.'
            stop
        endif
    
    end subroutine eigenvalues_symmetric


end module linalg