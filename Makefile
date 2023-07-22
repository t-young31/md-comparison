.PHONY: all cpp_oo   # Always rebuild

.ONESHELL:  #Use a single shell for all commands

SHELL := /bin/bash

all: python_oo python_f cpp_oo rust fortran java go
	@echo "Built successfully!"

clean:
	rm -rf fortran_oo/build
	rm -rf cpp_oo/build
	rm -rf rust/target

# --------------------------- Python targets ----------------------------------
python_oo: conda_env

python_func: conda_env

CONDA_ENV_DIR := $(shell conda info --base)/envs/md_comparison

conda_env: conda_install
	echo -n "conda env       ..."
	if [ -d "${CONDA_ENV_DIR}" ]; then \
		echo "present"; \
	else \
		$(MAKE) install_conda; \
		conda create --name md_comparison python=3.9 --yes &> /dev/null; \
		echo "created"; \
	fi

conda_install:
	echo -n "conda           ..."
	if command -v conda &> /dev/null; then \
		echo "present"; \
	else \
		wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh -q; \
		mkdir -p "${HOME}/.local/"; \
		bash miniconda.sh -b -p "${HOME}/.local/miniconda"; \
		rm miniconda.sh; \
		echo "Installing miniconda to ${HOME}/.local"; \
		eval "$("${HOME}"/miniconda/bin/conda shell.bash hook)"; \
		conda init bash; \
		echo "done"; \
	fi

# --------------------------- java targets ----------------------------------

java: java_compiler
	cd java; $(JAVA_HOME)/bin/javac Main.java; cp ../data/positions.txt ../data/velocities.txt .

java_compiler:
	echo -n "java compiler   ..."
	if [ -d "$(JAVA_HOME)" ]; then \
		echo "present"; \
	else \
		wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz -O jdk.tar.gz -q; \
		mkdir -p "${HOME}/.local/jdk17"; \
		tar zxf jdk.tar.gz --directory "${HOME}/.local/jdk17/"; \
		rm jdk.tar.gz; \
		mv ${HOME}/.local/jdk17/jdk*/* ${HOME}/.local/jdk17/; \
		echo "installed"; \
	fi

# -------------------------- C++ targets ---------------------------------

cpp_oo: cmake_install
	mkdir -p cpp_oo/build
	cp data/vel*.txt data/pos*.txt cpp_oo/build
	cd cpp_oo/build; cmake ..; make

cmake_install:
	echo -n "cmake           ..."
	if command -v cmake &> /dev/null; then \
		echo "present"; \
	else \
		$(MAKE) conda_install; \
		conda install cmake --yes &> /dev/null; \
		echo "installed"; \
	fi

# --------------------------- rust targets ----------------------------------

rust: cargo_install
	rm -rf rust/target/release/
	mkdir -p rust/target/release/
	cp data/positions.txt rust/target/release/
	cp data/velocities.txt rust/target/release/
	cd rust; cargo build --release

cargo_install:
	echo -n "cargo           ..."
	if command -v cargo &> /dev/null; then \
		echo "present"; \
	else \
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh; \
		source ${HOME}/.cargo/env; \
		export PATH=${HOME}/.cargo/bin:${PATH}; \
		echo "installed"; \
	fi

# --------------------------- Fortran targets ------------------------------
fortran: gfortran_install
	rm -rf fortran_oo/build
	mkdir -p fortran_oo/build
	cp data/positions.txt fortran_oo/build/
	cp data/velocities.txt fortran_oo/build/
	cd fortran_oo/build; gfortran -O3 ../md.f90 -o md -std=f2008 -Wextra -Wall
	echo "Fortran target made!"

gfortran_install:
	echo -n "gfortran           ..."
	if command -v gfortran &> /dev/null; then \
		echo "present"; \
	else \
		$(MAKE) conda_install gfortran --yes; \
		echo "installed"; \
	fi

# --------------------------- OCaml targets ------------------------------

ocaml: ocaml_compiler
	mkdir -p ocaml/build
	cp data/positions.txt ocaml/build/
	cp data/velocities.txt ocaml/build/
	cp ocaml/md.ml ocaml/build/md.ml
	cd ocaml/build/ && ocamlopt -o md md.ml

ocaml_compiler:
	which ocamlopt && echo "ocamlopt        ... present" \
	|| echo "Please install ocamlopt. See: https://ocaml.org/docs/up-and-running" \


# --------------------------- Go targets ------------------------------
go: go_install
	mkdir -p go/build; cd go/build; go build ../main.go
	echo "go target built!"

go_install:
	echo -n "go           ..."
	if command -v go &> /dev/null; then \
		echo "present"; \
	else \
		echo "Install from: https://go.dev/doc/install": \
		exit 1; \
	fi


.SILENT: # Make all targets silent
