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
[velocity verlet](https://en.wikipedia.org/wiki/Verlet_integration) algorithm
to update the positions and velocities (3) Repeating(2) for 10,000 steps and
(4) Writing a file of the final particle positions.

## Requirements
Only Linux/macOS is supported

* git
* make
* wget

## Install 

```bash
git clone https://github.com/t-young31/md-comparison.git
cd md-comparison
make
```

## Usage

```bash
python run.py
```

## Results
M1 Pro Macbook Pro

```
Code          time / s     Validated
------------------------------------
rust           0.01082        ✓              
fortran_oo     0.01306        ✓              
cpp_oo         0.01516        ✓              
go             0.05455        ✓              
java           0.26696        ✓     
python_f       1.85113        ✓             
python_oo      2.79232        ✓              
```
