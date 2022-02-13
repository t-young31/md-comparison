all: clean
	mkdir -p build
	cp ../data/positions.txt build/
	cp ../data/velocities.txt build/
	cd build; gfortran ../md.f90 -o md -std=f2008 -Wextra -Wall

clean:
	rm -r build
