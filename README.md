# md-comparison
A comparison of programming languages and styles for simulating the dynamics of 
a simple particle cluster.

<img
  src="_common/simulation.gif"
  alt="Particle cluster"
  width="80%"
  align="center"
/>


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
Intel i9-7900X @ 3.30GHz

```
Code          time / s     Validated
------------------------------------
python_f       2.22477        ✓              
python_oo      3.31303        ✓              
java           0.16130        ✓              
cpp_oo         0.16509        ✓              
rust           0.04426        ✓    
```
