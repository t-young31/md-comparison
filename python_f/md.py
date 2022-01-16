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


def _read_xyz_file_to_flat_array(filename: str):
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


def _calculate_forces(r:                  List[float],
                      force_function:     Callable,
                      force_coefficients: List[float]
                      ) -> List[float]:
    """Calculate the forces on each particle"""

    forces = []

    n_particles = len(r) // 3

    for i in range(n_particles):

        pos_i = r[3 * i:3 * i + 3]
        force = [0.0, 0.0, 0.0]   # Zero initial force on particle i

        for j in range(n_particles):

            pos_j = r[3 * j:3 * j + 3]
            fx, fy, fz = force_function(pos_i,
                                        pos_j,
                                        force_coefficients)
            force[0] += fx
            force[1] += fy
            force[2] += fz

        forces += force  # Extend the flat array

    return forces


def _update_positions(r:  List[float],
                      v:  List[float],
                      a:  List[float],
                      dt: float
                      ) -> None:
    """Update positions using velocities and accelerations in place"""

    n_particles = len(r) // 3

    for i in range(n_particles):
        for k in range(3):           # x, y, z

            idx = 3*i + k
            r[idx] += v[idx] * dt + a[idx] * dt ** 2

    return None


def _update_velocities(v:     List[float],
                       new_a: List[float],
                       a:     List[float],
                       dt:    float
                       ) -> None:
    """Update velocities using current and new accelerations in place"""

    n_particles = len(v) // 3

    for i in range(n_particles):
        for k in range(3):  # x, y, z

            idx = 3 * i + k
            v[idx] += (new_a[idx] + a[idx]) * (dt / 2.0)

    return None


def _force_to_acceleration(f: List[float]
                           ) -> List[float]:
    """Calculate the acceleration using F = ma"""
    mass = 1.0

    return [f_k / mass for f_k in f]


def run_md(r:                  List[float],
           v:                  List[float],
           force_function:     Callable,
           force_coefficients: List[float],
           n_steps:            int,
           timestep:           float
           ) -> None:
    """Run velocity verlet molecular dynamics (MD), updating positions and
    velocities in place"""

    f = _calculate_forces(r, force_function, force_coefficients)
    dt = _checked_positive(timestep)

    for _ in range(_checked_positive(n_steps)):

        a = _force_to_acceleration(f)
        _update_positions(r, v, a, dt)
        new_f = _calculate_forces(r, force_function, force_coefficients)
        new_a = _force_to_acceleration(new_f)
        _update_velocities(v, new_a, a, dt)

        f = new_f

    return None


def print_txt_file(array:    List[float],
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

    positions = read_positions(filename='data/positions.txt')
    velocities = read_velocities(filename='data/velocities.txt')

    run_md(r=positions,
           v=velocities,
           force_function=ljpairwise_force,
           force_coefficients=coeffs,
           n_steps=10000,
           timestep=0.01)

    print_txt_file(positions, filename='positions.txt')
