# md-comparison
A comparison of programming languages and styles for simulating the dynamics of 
a simple particle cluster.

<p align="center">
  <img src="_common/simulation.gif" alt="Particle cluster" width="400">
</p>

## Introduction

The idea behind this project is similar to the [primes](https://github.com/PlummersSoftwareLLC/Primes)
project but with a focus on styles rather than just pure performance.

The task involves: (1) Reading particle positions and velocities, (2) Using a 
velocity verlet algorithm to update the positions and velocities (3) Repeating
(2) for 10,000 steps and (4) Writing a file of the final particle positions.


## Requirements
Only linux is supported

* git
* make
* wget


## Install 

```bash
git clone https://github.com/t-young31/md-comparison.git && cd md-comparison && make
```

## Usage

```bash
python run.py
```

## Results
<!---
Intel i9-7900X @ 3.30GHz
-->
Intel(R) Xeon(R) Silver 4112 CPU @ 2.60GHz

```
Code          time / s     Validated
------------------------------------
cpp_oo         0.25113        ✓              
rust           0.00981        ✓              
java           0.28338        ✓              
fortran_oo     0.03388        ✓              
python_oo      4.62274        ✓              
python_f       3.15416        ✓        
```
