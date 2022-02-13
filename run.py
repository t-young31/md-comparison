"""Run all the MD using folder/run.sh for each implementation"""
import os
from subprocess import Popen
from time import time


def impl_dir_names():
    """Directories in the current working directory"""

    for item in os.listdir(os.getcwd()):
        if not os.path.isdir(item):
            continue

        if any((item.startswith('.'),
                item.startswith('_'),
                item == 'data')):
            continue

        yield item


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

    if not os.path.exists(data_filename):
        return False

    true_data = [18.01831, 14.40616,  -10.75076,
                 17.73558, 12.99332,  -13.22536,
                 17.61069, 12.14905,  -11.49700,
                 16.79659, 13.15575,  -10.07627,
                 19.02293, 13.33301,  -11.89145,
                 17.55034, 16.12730,  -11.31246,
                 18.67987, 12.78238,  -10.08327,
                 16.23595, 14.96211,  -10.55439,
                 16.20007, 15.41797,  -12.41876,
                 17.54872, 16.52326,  -13.17264,
                 16.65030, 13.69364,  -11.87061,
                 17.99891, 14.77742,  -12.59559,]

    observed_data = []
    for line in open(data_filename, 'r'):
        for item in line.split():
            observed_data.append(float(item))

    # TODO: Determine a sensible tolerance on the final positions
    return all(abs(obs_pos - true_pos) < 1E-1
               for obs_pos, true_pos in zip(observed_data, true_data))


if __name__ == '__main__':

    print('Code          time / s     Validated')
    print('------------------------------------')

    for name in impl_dir_names():

        runtime = calculate_runtime(name)
        validated = validate(name, data_filename='final_positions.txt')
        
        try:
            os.remove('final_positions.txt')
        except IOError:
            print(f"{name} failed!")

        print(f'{name:<15s}{runtime:<15.5f}{"✓" if validated else "✗":<15s}')
