! NOTES: Variables have subscript suffixes

module md
    implicit none
    private
    public :: Particle, Particles
    
    !------------------------------------------------
    type Particle
        real :: mass
        real, dimension(3) :: force_
        real, dimension(3) :: prev_force_
        real, dimension(3) :: position_
        real, dimension(3) :: velocity_
    end type Particle

    !------------------------------------------------
    type, public :: Particles
        type(Particle), dimension(12), public :: list_
    contains
        procedure, public :: set_velocities => pset_velocities
    
    end type Particles

    interface Particles               ! overloaded constructor
        procedure :: new_particles
    end interface Particles

    contains                          ! Methods

        type(Particles) function new_particles(position_filename)
            ! Implementation of the constructor
            ! Generate a set of particles given a file with
            ! their positions defined by:
            ! x0  y0  z0
            ! x1  y1  z1

            character(len = 100), intent(in) :: position_filename
            integer :: i, io_status 
            integer :: read_unit = 9

            open(unit=read_unit, action="read", file=position_filename, status="old", iostat=io_status)

            if (io_status /= 0) stop "Error opening file"

            do i = 1,12
                read(read_unit, *) &
                        new_particles%list_(i)%position_(1), &
                             new_particles%list_(i)%position_(2), &
                               new_particles%list_(i)%position_(3)
            enddo

            close(read_unit) ! Close position_filename

        end function new_particles


        subroutine pset_velocities(this, filename_)
            ! Set the velocities for each particle from a
            ! file containing velocities for each particle

            class(Particles), intent(inout) :: this
            character(len = 100), intent(in) :: filename_
            integer :: i
            integer :: read_unit = 9

            open(unit=read_unit, action="read", file=filename_, status="old")


            do i = 1,12
                read(read_unit, *) &
                        this%list_(i)%velocity_(1), &
                             this%list_(i)%velocity_(2), &
                               this%list_(i)%velocity_(3)
            enddo

            close(read_unit)

        end subroutine pset_velocities

end module md


program run_md
    use md
    implicit none

    integer i

    character(len=100) :: filename_
    type(Particles) :: particles_    

    filename_ = "positions.txt"
    particles_ = Particles(position_filename=filename_)

    filename_ = "velocities.txt"
    call particles_%set_velocities(filename_)

    
    ! TODO: Remove
    do i = 1,12
        write(*,fmt='(A,ES15.3E3)') " ", particles_%list_(i)%velocity_(1)
    enddo

end program

