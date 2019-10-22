module convtime
    implicit none

contains
    subroutine convtime_sub(time_in,time_out)
    ! passes the real time_in (in seconds)
    ! returns the string time_out formatted

        real, intent(in) :: time_in

        integer :: hour, minute, total ! internal
        real :: second                 ! internal

        character(len=12), intent(out) :: time_out

        total = int(time_in)  ! used for integer division

        hour = total / 3600
        minute = (total - 3600*hour) / 60
        second =  time_in - 3600*hour - 60*minute ! second will carry a decimal value

        write( time_out, "(i2,a1,i2,a1,f5.2,a1)") hour, "h", minute, "m", second, "s"

    end subroutine convtime_sub


end module convtime
