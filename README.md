# md-comparison
A comparison of programming languages and styles for simulating the dynamics of 
a simple particle cluster.


## Introduction

The idea behind this project is similar to the [primes](https://github.com/PlummersSoftwareLLC/Primes)
project but with a focus on styles rather than just pure performance.

The task involves: (1) Reading particle positions and velocities, (2) Using a 
velocity verlet algorithm to update the positions and velocities (3) Repeating
(2) for 1000 steps and (4) Writing a file of the final particle positions.


## Requirements

* git
* make
* wget


## Install 

```bash
git clone https://github.com/t-young31/mc-comparison.git && cd mc-comparison
make
```

## Usage

```bash
./run.sh
```
