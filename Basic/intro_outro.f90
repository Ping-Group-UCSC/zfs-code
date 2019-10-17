!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
!%%    output intro & outro   %%
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

module intro_outro

    implicit none

    character(10) :: date
    character(12) :: time

contains

    subroutine calc_date_and_time()
        call date_and_time(DATE=date,TIME=time)
    
        date = date(5:6) // "/" // date(7:8) // "/" // date(1:4)
        time = time(1:2) // ":" // time(3:4) // ":" // time(5:6)
    end subroutine calc_date_and_time


    subroutine intro()
    ! simple subroutine for intro printed at the beginning of the calculation

        call calc_date_and_time()
    
        print *
        print *, "Program ZFS v2 | TIME: begins on ", date, " at ", time
        print *

    end subroutine intro


    subroutine outro()
    ! simple subroutine for outro printed at the ending of the calculation

        call calc_date_and_time()
    
        print *
        print *, "Done :) | TIME: calculation ends on ", date, " at ", time
        print *

    end subroutine outro


end module intro_outro
