! NOTES: Variables have subscript suffixes

module md
    implicit none
    private
    public :: Particle, Particles, Simulation
    
    !--------- Start of type declarations -----------
    !------------------------------------------------
    type Particle
        real :: mass_
        real, dimension(3) :: force_
        real, dimension(3) :: prev_force_
        real, dimension(3) :: position_
        real, dimension(3) :: velocity_

    contains
        procedure, public :: zero_force
        procedure, public :: update_prev_force
        procedure, public :: update_velocity
        procedure, public :: update_position

    end type Particle

    !------------------------------------------------
    type, public :: Particles
        type(Particle), dimension(12), public :: list_

    contains
        procedure, public :: set_velocities => pset_velocities
        procedure, public :: print_positions => pprint_positions
        procedure, public :: calculate_forces
        procedure, public :: update_velocities
        procedure, public :: update_positions

    end type Particles

    !------------------------------------------------
    type, public :: LJPotential
        real, dimension(3), public :: f_

    contains
        procedure, public :: add_force => padd_force

    end type LJPotential
    
    !------------------------------------------------
    type, public :: Simulation
        type(Particles), public:: particles_
        type(LJPotential), public :: potential_
        integer, private :: num_steps_
        real, private :: time_step_

    contains
        procedure, public :: run => prun

    end type Simulation
    !---------- End of type declarations -----------

    !-------- Start of constructor defns -----------
    !-----------------------------------------------
    interface Particles               
        procedure :: new_particles
    end interface Particles

     
    interface Simulation
        procedure :: new_simulation
    end interface Simulation


    interface LJPotential
        procedure :: new_potential
    end interface LJPotential
    !------------ End of constructors --------------

    
    !------------ Start of methods -----------------
    !-----------------------------------------------
    contains                      

        subroutine zero_force(this)
            ! Zero the force on a particle
            
            class(Particle), intent(inout) :: this
            integer :: k

            do k = 1, 3
                this%force_(k) = 0.0
            enddo

        end subroutine zero_force

        
        subroutine update_prev_force(this)
            ! Set the previous force on a particle
            ! from the current value of the force
            
            class(Particle), intent(inout) :: this
            integer :: k

            do k = 1, 3
                this%prev_force_(k) = this%force_(k)
            enddo

        end subroutine update_prev_force

        
        subroutine update_velocity(this, dt)
            ! Update the current velocity based on the 
            ! current and previous force

            class(Particle), intent(inout) :: this
            real, intent(in) :: dt
            integer :: k

            do k = 1, 3
                ! v_k += (f_k(i) + f_k(i-1)) dt / (2M)
                this%velocity_(k) = (this%velocity_(k) &
                                    + ((this%force_(k) + this%prev_force_(k)) / 2.0 &
                                       * dt / this%mass_)                           &
                                    )
            enddo

        end subroutine update_velocity


        subroutine update_position(this, dt)
            ! Update the current position based on the 
            ! velocity and acceleration, for a timstep dt

            class(Particle), intent(inout) :: this
            real, intent(in) :: dt
            integer :: k

            ! self.velocity * dt + self.acceleration * dt**2

            do k = 1, 3
                ! x_k += v_k dt  + (f_k / M) dt^2
                this%position_(k) = (this%position_(k)                        &
                                     + (this%velocity_(k) * dt)               &
                                     + (this%force_(k) / this%mass_) * dt*dt  &
                                     )
            enddo

        end subroutine update_position


        type(Particles) function new_particles(position_filename)
            ! Implementation of the constructor
            ! Generate a set of particles given a file with
            ! their positions defined by:
            ! x0  y0  z0
            ! x1  y1  z1

            character(len = 100), intent(in) :: position_filename
            integer :: i, k, io_status 
            integer :: read_unit = 9

            open(unit=read_unit,         &
                 action="read",          &
                 file=position_filename, &
                 status="old",           &
                 iostat=io_status)

            if (io_status /= 0) stop "Error opening file"

            do i = 1,12
                read(read_unit, *) &
                        new_particles%list_(i)%position_(1), &
                             new_particles%list_(i)%position_(2), &
                               new_particles%list_(i)%position_(3)
                
                do k = 1, 3
                    new_particles%list_(i)%prev_force_(k) = 0.0
                enddo
                new_particles%list_(i)%mass_ = 1.0
               
             enddo

            close(read_unit) ! Close position_filename

            ! call new_particles%set_pair_list()

        end function new_particles


        subroutine pset_velocities(this, filename_)
            ! Set the velocities for each particle from a
            ! file containing velocities for each particle

            class(Particles), intent(inout) :: this
            character(len = 100), intent(in) :: filename_
            integer :: i
            integer :: read_unit = 9

            open(unit=read_unit, action="read", file=filename_, status="old")

            do i = 1,size(this%list_)
                read(read_unit, *) &
                        this%list_(i)%velocity_(1), &
                             this%list_(i)%velocity_(2), &
                               this%list_(i)%velocity_(3)
            enddo

            close(read_unit)

        end subroutine pset_velocities


        subroutine pprint_positions(this)
            ! Print the positions into a .txt file

            class(Particles), intent(in) :: this

            integer :: print_unit = 10
            integer :: i

            open(unit=print_unit,            &
                 action="write",             &
                 file="final_positions.txt", & 
                 status="new")

            do i = 1, size(this%list_)
                write(print_unit, *)   &
                    this%list_(i)%position_(1),            &
                        this%list_(i)%position_(2),        &
                            this%list_(i)%position_(3) 

            enddo

            close(print_unit, status="keep")

        end subroutine pprint_positions

        
        subroutine calculate_forces(this, potential_)
            ! Calculate the forces on all the particles
            class(Particles), intent(inout) :: this
            class(LJPotential), intent(in) :: potential_
            integer :: i, j

            do i = 1, size(this%list_)
                call this%list_(i)%update_prev_force()
                call this%list_(i)%zero_force()

                do j = 1, size(this%list_)
                    if (i /= j) then

                        call potential_%add_force(this%list_(i), &
                                                this%list_(j))
                    end if
                enddo

            enddo

        end subroutine calculate_forces

        subroutine update_velocities(this, dt)
            ! Update the velocities of all particles

            class(Particles), intent(inout) :: this
            real, intent(in) :: dt
            integer :: i


            do i = 1, size(this%list_)
                call this%list_(i)%update_velocity(dt)
            enddo

        end subroutine update_velocities

        subroutine update_positions(this, dt)
            ! Update the positions of all the particles
            
            class(Particles), intent(inout) :: this
            real, intent(in) :: dt
            integer :: i
           

            do i = 1, size(this%list_)
                call this%list_(i)%update_position(dt)
            enddo

        end subroutine update_positions

        !-----------------------------------------------

        type(LJPotential) function new_potential(epsilon_, &
                                                 sigma_)
            ! Construct a new LJ potential from the 
            ! well depth and particle interaction range

            real, intent(in) :: epsilon_, sigma_

            new_potential%f_(1) = epsilon_/2.0
            new_potential%f_(2) = 12.0 * sigma_**12
            new_potential%f_(3) = -6.0 * sigma_**6

        end function new_potential

        subroutine padd_force(this, particle_i_, particle_j_)
            ! Add the force on particle i due to the presence
            ! of particle j
            class(LJPotential), intent(in) :: this
            class(Particle), intent(inout) :: particle_i_
            class(Particle), intent(in) :: particle_j_
    
            real, dimension(5) :: v

            v(1) = particle_i_%position_(1) - particle_j_%position_(1)  ! dx
            v(2) = particle_i_%position_(2) - particle_j_%position_(2)  ! dy
            v(3) = particle_i_%position_(3) - particle_j_%position_(3)  ! dz
            
            v(4) = sqrt(v(1) * v(1) + v(2) * v(2) + v(3) * v(3))        ! r
            v(5) = this%f_(1) * (this%f_(2) * v(4)**(-14) + this%f_(3) * v(4)**(-8))
            
            particle_i_%force_(1) = particle_i_%force_(1) + v(5) * v(1)   ! f_x + c * dx
            particle_i_%force_(2) = particle_i_%force_(2) + v(5) * v(2)   ! f_y + c * dy
            particle_i_%force_(3) = particle_i_%force_(3) + v(5) * v(3)   ! f_z + c * dz

        end subroutine padd_force


        type(Simulation) function new_simulation(particles_, &
                                                 potential_, &
                                                 num_steps_, &
                                                 time_step_)
            ! Create a new simulation from a set of particles
            ! along with a potential and 

            class(Particles), intent(in) :: particles_
            class(LJPotential), intent(in) :: potential_
            integer, intent(in) :: num_steps_
            real, intent(in) :: time_step_

            new_simulation%particles_ = particles_
            new_simulation%potential_ = potential_

            if (num_steps_ <= 0) stop "Number of simulation steps must be positive" 
            new_simulation%num_steps_ = num_steps_

            if (time_step_ <= 0.0) stop "Timestep must be positive"
            new_simulation%time_step_ = time_step_

        end function new_simulation

        subroutine prun(this)
            ! Run the simulation using the defined number
            ! of steps
        
            class(Simulation), intent(inout) :: this
            integer :: step            

            call this%particles_%calculate_forces(this%potential_)

            do step = 0, this%num_steps_
               
                call this%particles_%update_positions(this%time_step_)
                call this%particles_%calculate_forces(this%potential_)
                call this%particles_%update_velocities(this%time_step_)

            enddo

        end subroutine prun

end module md


program run_md
    use md
    implicit none

    !----------------------------------------- Type definitions
    character(len=100) :: filename_
    type(Particles) :: particles_    
    type(Simulation) :: simulation_
    type(LJPotential) :: potential_
    !-----------------------------------------

    ! --------- Initalise particles ----------
    filename_ = "positions.txt"
    particles_ = Particles(position_filename=filename_)

    filename_ = "velocities.txt"
    call particles_%set_velocities(filename_)

    ! --------- Initalise potential ----------
    potential_ = LJPotential(epsilon_=100.0, & 
                             sigma_=1.7)

    ! --------- Initalise simulation ---------
    simulation_ = Simulation(particles_=particles_, &
                             potential_=potential_, &
                             num_steps_=10000,      &
                             time_step_=0.01)

    call simulation_%run()
    call simulation_%particles_%print_positions()

end program

