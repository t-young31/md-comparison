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
    type Particles
        type(Particle), dimension(12) :: list_
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
            integer :: i

            open(unit = 9, file=position_filename, status="old")


            do i = 1,12
                read(3, *) new_particles%list_(i)%position_(1), &
                             new_particles%list_(i)%position_(2), &
                               new_particles%list_(i)%position_(3)
            enddo

            close(9) ! Close position_filename

        end function new_particles

end module md


program run_md
    use md
    implicit none

    character(len=100) :: filename_
    type(Particles) :: particles_    

    filename_ = "positions.txt"
    particles_ = Particles(position_filename=filename_)
   
end program
