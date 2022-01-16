.SILENT: conda_install  conda_env

all: python_oo
	@echo "Built successfully!"

# --------------------------- Python targets ----------------------------------
python_oo: conda_env
python_func: conda_env

CONDA_ENV_DIR := $(shell conda info --base)/envs/md_comparison

ifeq (,$(wildcard $(CONDA_ENV_DIR)))   # Does the environment not exist?
conda_env: conda_install create_conda_env
	echo "conda env        ...created"
else
conda_env:
	echo "conda env        ...present"
endif

create_conda_env:
	conda create --name md_comparison python=3.9 cmake --yes &> /dev/null
	echo "Created environment"

ifeq (,$(shell which conda))  # Does the conda command not exist?
conda_install: install_conda
	echo "conda           ...installed"
else
conda_install:
	echo "conda           ...found"
endif

install_conda:
	echo "Installing conda..."
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh -q
	bash miniconda.sh -b -p "$HOME/miniconda"
	rm miniconda.sh
	eval "$("$HOME"/miniconda/bin/conda shell.bash hook)"
	conda init bash
	echo "                ...done"

# --------------------------- X targets ----------------------------------

