import numpy as np
from scipy.spatial import distance_matrix


def modified_distance_matrix(_positions):
    """Distance matrix between particles with a large value on the diagonal"""
    return distance_matrix(_positions, _positions) + 999.9*np.eye(n_particles)


if __name__ == '__main__':

    n_particles = 12
    min_sep = 2.0  # reduced units

    while True:
        pos = np.random.uniform(low=-4, high=4, size=(n_particles, 3))

        if np.min(modified_distance_matrix(pos)) > min_sep:
            break

    with open('positions.txt', 'w') as pos_file:
        for (x, y, z) in pos:
            print(f'{x:.8f} {y:10f} {z:10f}', file=pos_file)

    with open('velocities.txt', 'w') as vel_file:
        for (x, y, z) in np.random.uniform(low=-1, high=1, size=(n_particles, 3)):
            print(f'{x:.8f} {y:10f} {z:10f}', file=vel_file)
