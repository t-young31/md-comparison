"""
Object orintated (OO) Python implementation
"""
from math import sqrt


class _3DVector:
    """3D vector. Initialised as the zero vector"""

    def __init__(self,
                 x: float = 0.0,
                 y: float = 0.0,
                 z: float = 0.0):
        """Vector in 3D space, with x, y, z components"""

        self._x = x
        self._y = y
        self._z = z

    @property
    def x(self) -> float:
        return self._x

    @x.setter
    def x(self, value):
        self._x = float(value)

    @property
    def y(self) -> float:
        return self._y

    @y.setter
    def y(self, value):
        self._y = float(value)

    @property
    def z(self) -> float:
        return self._z

    @z.setter
    def z(self, value):
        self._z = float(value)

    def zero(self) -> None:
        self._x, self._y, self.z = 0.0, 0.0, 0.0

    def __iadd__(self, other: '_3DVector') -> '_3DVector':
        """Inplace addition of another vector to this one"""
        self._x += other.x
        self._y += other.y
        self._z += other.z
        return self

    def __add__(self, other: '_3DVector'):
        """Addition of another vector to this one"""
        x0, y0, z0 = self._x, self._y, self._z
        x1, y1, z1 = other.x, other.y, other.z

        return self.__class__(x=x0+x1, y=y0+y1, z=z0+z1)

    def __mul__(self, other: float) -> '_3DVector':
        """Multiply this vector by a scalar"""
        x, y, z = self._x, self._y, self._z
        return self.__class__(x=other*x, y=other*y, z=other*z)

    def __repr__(self):
        return f'{self.__class__.__name__}({self._x}, {self._y}, {self._z})'


class Position(_3DVector):
    """Position in 3D space: R"""


class Velocity(_3DVector):
    """Velocity in 3D space: dR/dt"""


class Force(_3DVector):
    """Force vector: -dE/dx, -dE/dy, -dE/dz"""


class Acceleration(_3DVector):
    """Acceleration vector: dv/dt"""


class Mass(float):
    """Mass (weight)"""


class _PostiveFloat(float):

    def __new__(cls, value):
        if float(value) < 0:
            raise ValueError(f'{cls.__name__} must be positive. Had: {value}')

        return float.__new__(cls, value)


class Timestep(_PostiveFloat):
    """Time-step (dt)"""


class _PostiveInteger(int):

    def __new__(cls, value):
        if int(value) <= 0:
            raise ValueError(f'{cls.__name__} must be positive. Had: {value}')

        return int.__new__(cls, value)


class NumberOfSimulationSteps(_PostiveInteger):
    """n_steps"""


class Particle:

    def __init__(self):
        """Particle initialised with a default position and velocity"""

        self.mass = Mass(1.0)
        self.position = Position()
        self.velocity = Velocity()

        self._prev_force = Force()
        self._force = Force()

    @property
    def force(self) -> Force:
        """Current force"""
        return self._force

    @force.setter
    def force(self, value: Force) -> None:
        """Set a new value of the force"""
        self._prev_force = self._force
        self._force = value

    @property
    def acceleration(self) -> Acceleration:
        """Acceleration derived using F = ma"""
        a = Acceleration(x=self._force.x / self.mass,
                         y=self._force.y / self.mass,
                         z=self._force.z / self.mass)
        return a

    @property
    def prev_acceleration(self) -> Acceleration:
        """Acceleration derived using F = ma"""
        a = Acceleration(x=self._prev_force.x / self.mass,
                         y=self._prev_force.y / self.mass,
                         z=self._prev_force.z / self.mass)
        return a

    def update_position(self, dt: float) -> None:
        """Update the position according to a velocity verlet update"""
        self.position += self.velocity * dt + self.acceleration * dt**2

    def update_velocity(self, dt: float) -> None:
        """Update the position according to a velocity verlet update"""
        self.velocity += (self.acceleration + self.prev_acceleration) * (dt / 2.)


class Particles(list):

    def __init__(self,
                 positions_filename:  str,
                 velocities_filename: str):
        """List of particles constructed from positions and velocities file"""
        super().__init__()

        for _ in range(self._n_particles(positions_filename)):
            self.append(Particle())

        self._set_all('position', positions_filename)
        self._set_all('velocity', velocities_filename)

    def calculate_forces(self) -> None:
        """Calculate the force on each particle according to the energy
        function

            E = Σ a ((b/r_ij)^12 - (b/r_ij)^6)
                ij

        where i, j enumerate over all particles.
        """
        a = 100.0
        b = 2.0

        f0, f1, f2 = a/2.0, 12 * b**12, -6 * b**6

        for i, particle_i in enumerate(self):

            particle_i.force.zero()

            for j, particle_j in enumerate(self):

                if i == j:     # Only consider i != j
                    continue

                dx = particle_i.position.x - particle_j.position.x
                dy = particle_i.position.y - particle_j.position.y
                dz = particle_i.position.z - particle_j.position.z
                r = sqrt(dx*dx + dy*dy + dz*dz)

                const = f0 * (f1 * r**(-14) + f2 * r**(-8))

                particle_i.force += Force(x=const * dx,
                                          y=const * dy,
                                          z=const * dz)
        return None

    def print_xyz_file(self,
                       filename: str,
                       append:   bool = False) -> None:
        """Print an xyz file of the particles"""

        with open(filename, 'a' if append else 'w') as xyz_file:

            print(f'{len(self)}\n', file=xyz_file)
            for particle in self:

                pos = particle.position
                print(f'H  {pos.x:.5f}  {pos.y:.5f}  {pos.z:.5f}',
                      file=xyz_file)

        return None

    def _set_all(self,
                 attr:     str,
                 filename: str
                 ) -> None:
        """
        Set the positions or velocities of all the particles from a file.
        Expecting a file format of:

            x0   y0   z1
            x1   y1   z1
            .    .    .

        where x0 etc. are floating point numbers.

        -----------------------------------------------------------------------
        Arguments:
            attr: Attribute to set. One of {'position', 'velocity'}

            filename:

        Raises:
            (IOError): If the file does not exist

            (ValueError): If the file is malformatted
        """
        for i, line in enumerate(open(filename,  'r')):

            if self._is_blank(line):
                break

            try:
                vec = getattr(self[i], attr)
                vec.x, vec.y, vec.z = line.split()

            except ValueError:
                raise ValueError(f'Could not convert {line} to x, y, z '
                                 f'components')

            except IndexError:
                raise ValueError(f'Could not set position for particle {i} '
                                 f'only had {len(self)} particles!')

        return None

    @staticmethod
    def _is_blank(line: str) -> bool:
        return len(line.split()) == 0

    @staticmethod
    def _n_particles(filename: str) -> int:
        """Number of particles present in a file"""
        return sum(len(line.split()) == 3 for line in open(filename, 'r'))


class Simulation:
    """Simulation of a set of particles"""

    def __init__(self,
                 particles:        Particles,
                 timestep:         float,
                 n_steps:          int,
                 print_trajectory: bool = False):
        """Construct a simulation from a set of properties"""

        self.particles = particles

        self._timestep = Timestep(timestep)
        self._n_steps = NumberOfSimulationSteps(n_steps)
        self._print_trajectory = bool(print_trajectory)

    def run(self) -> None:
        """Run molecular dynamics"""

        self._clear_trajectory_file()

        self.particles.calculate_forces()

        for _ in range(self._n_steps):

            if self._print_trajectory:
                self.particles.print_xyz_file(filename='trajectory.xyz',
                                              append=True)

            self.update_positions()
            self.particles.calculate_forces()
            self.update_velocities()

        return None

    def update_positions(self) -> None:
        """Update the position of all the particles in the simulation"""

        for particle in self.particles:
            particle.update_position(dt=self._timestep)

        return None

    def update_velocities(self) -> None:
        """Update the velocity of all the particles in the simulation"""

        for particle in self.particles:
            particle.update_velocity(dt=self._timestep)

        return None

    @staticmethod
    def _clear_trajectory_file() -> None:
        open('trajectory.xyz', 'w').close()


if __name__ == '__main__':

    cluster = Particles(positions_filename='data/positions.txt',
                        velocities_filename='data/velocities.txt')

    simulation = Simulation(particles=cluster,
                            n_steps=1000,
                            timestep=0.01)
    simulation.run()
    # simulation.particles.print_xyz_file(filename='final_pos.xyz')
