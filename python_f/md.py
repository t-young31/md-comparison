"""
Functional Python implementation
"""
from math import sqrt
from typing import List, Callable, Any


def _checked_positive(value: Any) -> Any:
    """Ensure a value is positive"""

    if float(value) < 0:
        raise ValueError(f'Value must be positive. Had {value}')

    return value


def _read_xyz_file_to_flat_array(filename):
    """Read vectors from a file with lines x, y, z.. on each line, Generates
    a row-major flat array with form (x0, y0, z0, x1, y1, ...)"""

    array = []

    for line in open(filename, 'r'):
        for item in line.split():
            array.append(float(item))

    return array


def read_positions(filename: str) -> List[float]:
    return _read_xyz_file_to_flat_array(filename)


def read_velocities(filename: str) -> List[float]:
    return _read_xyz_file_to_flat_array(filename)


def ljpairwise_force(position_i:   List[float],
                     position_j:   List[float],
                     coefficients: List[float]
                     ) -> List[float]:
    """Force on particle i due to particle j"""

    def is_close(_a, _b): return abs(_a - _b) < 1E-10

    if all(is_close(a, b) for a, b in zip(position_i, position_j)):
        # No self interaction
        return [0.0, 0.0, 0.0]

    dx = position_i[0] - position_j[0]
    dy = position_i[1] - position_j[1]
    dz = position_i[2] - position_j[2]
    r = sqrt(dx * dx + dy * dy + dz * dz)

    const = coefficients[0] * (coefficients[1] * r**(-14)
                               + coefficients[2] * r**(-8))

    return [const * dx, const * dy, const * dz]


def calculate_lj_force_coefficients(epsilon: float,
                                    sigma:   float
                                    ) -> List[float]:
    """Constant coefficients used in the force evaluation"""
    return [epsilon / 2.0, 12 * sigma ** 12, -6 * sigma ** 6]


def _calculate_forces(positions:          List[float],
                      force_function:     Callable,
                      force_coefficients: List[float]
                      ) -> List[float]:
    """Calculate the forces on each particle"""

    forces = []

    n_particles = len(positions) // 3

    for i in range(n_particles):

        pos_i = positions[3*i:3*i + 3]
        force = [0.0, 0.0, 0.0]   # Zero initial force on particle i

        for j in range(n_particles):

            pos_j = positions[3*j:3*j + 3]
            fx, fy, fz = force_function(pos_i,
                                        pos_j,
                                        force_coefficients)
            force[0] += fx
            force[1] += fy
            force[2] += fz

        forces += force  # Extend the flat array

    return forces


def _update_positions(positions, velocities, accelerations, dt) -> None:
    """Update positions using velocities and accelerations in place"""

    n_particles = len(positions) // 3

    for i in range(n_particles):
        for k in range(3):           # x, y, z

            idx = 3*i + k
            positions[idx] += velocities[idx] * dt + accelerations[idx] * dt**2

    return None


def _update_velocities(velocities, new_acceleration, accelerations, dt) -> None:
    """Update velocities using current and new accelerations in place"""

    n_particles = len(velocities) // 3

    for i in range(n_particles):
        for k in range(3):  # x, y, z

            idx = 3 * i + k
            velocities[idx] += (new_acceleration[idx] + accelerations[idx]) * (dt / 2.0)

    return None


def _force_to_acceleration(forces) -> List[float]:
    """Calculate the acceleration using F = ma"""
    mass = 1.0

    return [f/mass for f in forces]


def run_md(positions:          List[float],
           velocities:         List[float],
           force_function:     Callable,
           force_coefficients: List[float],
           n_steps:            int,
           timestep:           float
           ) -> List[float]:
    """Run velocity verlet molecular dynamics (MD)"""

    forces = _calculate_forces(positions, force_function, force_coefficients)

    for _ in range(_checked_positive(n_steps)):

        accelerations = _force_to_acceleration(forces)

        _update_positions(positions,
                          velocities,
                          accelerations,
                          timestep)

        new_forces = _calculate_forces(positions,
                                       force_function,
                                       force_coefficients)

        new_accelerations = _force_to_acceleration(new_forces)

        _update_velocities(velocities,
                           new_accelerations,
                           accelerations,
                           timestep)

        forces = new_forces

    return positions


def print_txt_file(array: List[float],
                   filename: str
                   ) -> None:
    """Print a .txt file from a flat array in the shape Nx3"""

    with open(filename, 'w') as txt_file:

        for i, item in enumerate(array):
            print(item,
                  end='\n' if (i+1 % 3 == 0) else ' ',
                  file=txt_file)

    return None


if __name__ == '__main__':

    coeffs = calculate_lj_force_coefficients(epsilon=100, sigma=1.7)

    final_positions = run_md(
                   positions=read_positions(filename='data/positions.txt'),
                   velocities=read_velocities(filename='data/velocities.txt'),
                   force_function=ljpairwise_force,
                   force_coefficients=coeffs,
                   n_steps=10000,
                   timestep=0.01
                   )

    print_txt_file(final_positions, filename='positions.txt')
