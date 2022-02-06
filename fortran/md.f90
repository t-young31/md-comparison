module md
    implicit none
    private
    public :: Particle, Particles
    
    !------------------------------------------------
    type Particle
        real, dimension(3) :: force

    end type Particle

    !------------------------------------------------
    type Particles
        type(Particle), dimension(12) :: list
    end type Particles

    interface Particles               ! overloaded constructor
        procedure :: new_particles
    end interface Particles

    contains                          ! Methods

        type(Particles) function new_particles(position_filename)
            ! Implementation of the constructor
        
            character(len = 100), intent(in) :: position_filename
            ! DO things

        end function new_particles

end module md


program run_md
    use md
    implicit none

    character(len=100) :: filename
    type(Particles) :: particles_    

    filename = "positions.txt"
    particles_ = Particles(position_filename=filename)
   
end program
