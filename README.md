# md-comparison
A comparison of programming languages and styles for simulating the dynamics of 
a simple particle cluster.


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
git clone https://github.com/t-young31/mc-comparison.git && cd mc-comparison && make
```

## Usage

```bash
python run.py
```

## Results

```
Code          time / s     Validated
------------------------------------
python_f       2.17905        ✓              
python_oo      3.30715        ✓              
java           0.16135        ✓              
cpp_oo         0.15845        ✓    
rust           0.00239        ✓      
```

