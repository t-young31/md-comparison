"""Run all the MD using folder/run.sh for each implementation"""
import os
from subprocess import Popen
from time import time


def impl_dir_names():
    """Directories in the current working directory"""
    return [fn for fn in os.listdir(os.getcwd())
            if os.path.isdir(fn) and not (fn == 'data' or fn.startswith('.'))]


def calculate_runtime(_dir_name) -> float:
    """Run the process and time the output"""

    if not os.path.exists(f'{_dir_name}/run.sh'):
        raise exit(f'Cannot run {_dir_name}. No run.sh present')

    process = Popen(['bash', f'{_dir_name}/run.sh'])

    start_time = time()
    process.wait()
    return time() - start_time


def validate(_dir_name, data_filename) -> bool:
    """Is the output data correct? Requires data_filename to exist"""

    true_data = [-51.94655,  -15.87820,  -11.01517, -52.32266,  -18.29836,
                 -8.13170, -52.68305,  -17.63152,  -11.17722, -52.18111,
                 -15.30363,  -9.20726, -53.57031,  -18.05413,  -9.54410,
                 -53.55112,  -16.16643,  -11.99575, -50.79991,  -17.38123,
                 -11.04779, -50.48398,  -15.94329,  -9.81626, -54.56761,
                 -17.50742,  -11.07744, -53.22817,  -16.63110,  -8.29212,
                 -53.53828,  -16.25973,  -10.10888, -51.91791,  -17.13060,
                 -9.55226]

    observed_data = []
    for line in open(data_filename, 'r'):
        for item in line.split():
            observed_data.append(float(item))

    return all(abs(obs_pos - true_pos) < 1E-3
               for obs_pos, true_pos in zip(observed_data, true_data))


if __name__ == '__main__':

    print('Code          time / s     Validated')
    print('------------------------------------')

    for name in impl_dir_names():

        runtime = calculate_runtime(name)
        validated = validate(name, data_filename='positions.txt')
        os.remove('positions.txt')

        print(f'{name:<15s}{runtime:<15.5f}{"✓" if validated else "✗":<15s}')
