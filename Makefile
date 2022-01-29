.SILENT: cpp_oo cmake cmake_install conda_install conda_env create_conda_env java java_compiler jdk_install rust rust_compiler cargo_install

.PHONY: all cpp_oo   # Always rebuild


all: python_oo python_f java cpp_oo rust
	@echo "Built successfully!"


# --------------------------- Python targets ----------------------------------
python_oo: conda_env

python_func: conda_env

CONDA_ENV_DIR := $(shell conda info --base)/envs/md_comparison

ifeq (,$(wildcard $(CONDA_ENV_DIR)))   # Does the environment not exist?
conda_env: conda_install create_conda_env
	echo "conda env       ... created"
else
conda_env:
	echo "conda env       ... present"
endif

create_conda_env:
	conda create --name md_comparison python=3.9 --yes &> /dev/null

ifeq (,$(shell which conda 2> /dev/null))  # Does the conda command not exist?
conda_install: install_conda
	echo "conda           ... installed"
else
conda_install:
	echo "conda           ... present"
endif

install_conda:
	echo "Installing conda... "
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh -q
	echo "Getting installer... done"
	mkdir -p "${HOME}/.local/"
	bash miniconda.sh -b -p "$HOME/.local/miniconda"
	rm miniconda.sh
	echo "Installing miniconda to $HOME/.local"
	eval "$("${HOME}"/miniconda/bin/conda shell.bash hook)"
	conda init bash
	echo "                 ... done"

# --------------------------- java targets ----------------------------------

JAVA_HOME := ${HOME}/.local/jdk17

java: java_compiler
	cd java; $(JAVA_HOME)/bin/javac Main.java; cp ../data/positions.txt ../data/velocities.txt .


ifeq (, $(wildcard $(JAVA_HOME)))   # If the java install directory does not exist
java_compiler: jdk_install
	echo "java compiler   ... installed"
else
java_compiler:
	echo "java compiler   ... present"
endif

jdk_install:
	echo "Installing JDK  ..."
	wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz -O jdk.tar.gz -q
	mkdir -p "${HOME}/.local/jdk17"
	tar zxf jdk.tar.gz --directory "${HOME}/.local/jdk17/"
	echo "extracting tar  ... done"
	rm jdk.tar.gz
	mv ${HOME}/.local/jdk17/jdk*/* ${HOME}/.local/jdk17/ 

# -------------------------- C++ targets ---------------------------------

cpp_oo: cmake
	mkdir -p cpp_oo/build
	cd cpp_oo/build; cmake ..; make
	cp data/*.txt cpp_oo/build/

ifeq (, $(shell which cmake 2> /dev/null))
cmake: cmake_install
	echo "cmake           ... installed"
else
cmake:
	echo "cmake           ... present "
endif


cmake_install: conda_install
	conda install cmake --yes &> /dev/null

# --------------------------- rust targets ----------------------------------

rust: rust_compiler
	cd rust; cargo build --release; cp ../data/positions.txt ../data/velocities.txt target/release/

ifeq (, $(shell which cargo 2> /dev/null))  # If the cargo command doesn't exist
rust_compiler: cargo_install
	echo "cargo           ... installed"
else
rust_compiler:
	echo "cargo           ... present "
endif

cargo_install:
	mkdir -p "${HOME}/.local"
	cd "${HOME}/.local/"
	wget https://static.rust-lang.org/dist/rust-1.58.1-x86_64-unknown-linux-gnu.tar.gz
	tar xf rust-1.58.1-x86_64-unknown-linux-gnu.tar.gz -C rust/
	rm rust-1.58.1-x86_64-unknown-linux-gnu.tar.gz
	echo "installed cargo to \$HOME/.local/rust/cargo/bin. Please add to \$PATH"
	exit
