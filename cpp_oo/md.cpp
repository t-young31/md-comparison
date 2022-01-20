//
// Created by Tom Young on 19/01/2022.
//
#include <string>
#include <utility>
#include <vector>
#include <array>
#include <sstream>
#include <fstream>
#include <iomanip>
#include <cassert>
#include <stdexcept>
#include <cmath>


using namespace std;


vector<string> split(const string &s, char delim) {
    // Split a string by a delimiter into a vector of strings

    stringstream stream(s);
    string item;
    vector<string> elems;
    while (getline(stream, item, delim)) {
        if (!item.empty()){
            elems.push_back(item);
        }
    }
    return elems;
}


template <class T>
class PositiveDouble{

    protected:
        double value = 0.0;

    public:

        PositiveDouble() = default;

        explicit PositiveDouble(double value){
            this->value = value;
            assert(value > 0.0);
        }

        T operator*(double x) const {return T(value*x);}
        T operator/(double x) const {return T(value/x);}

        friend double operator*(double x, T y){return x * y.value;}
        friend double operator/(double x, T y){return x / y.value;}
};


class TimeIncrement: public PositiveDouble<TimeIncrement>{
    // A positive time increment (∆t)

    public:
        TimeIncrement(): PositiveDouble(0.01){};
        explicit TimeIncrement(double value): PositiveDouble(value){};
};


class Mass: public PositiveDouble<Mass>{
    // Mass of a particle

    public:
        Mass() : PositiveDouble(1.0){};
        explicit Mass(double value): PositiveDouble(value){};
};


class PositiveInteger{

    protected:
        int value;

    public:
        explicit PositiveInteger(int value){
            assert(value > 0);
            this->value = value;
        }

        friend bool operator<(int i, PositiveInteger j) {
            return  i < j.value;
        }
};


class NumberOfTimeSteps: public PositiveInteger{
    public:
        NumberOfTimeSteps() : PositiveInteger(1){};
        explicit NumberOfTimeSteps(int value): PositiveInteger(value){};
};


template <class T>
class Vector3D: public array<double, 3>{
    // A vector in 3D space with x, y, z components

    public:

        double x() const {return at(0);}
        double y() const {return at(1);}
        double z() const {return at(2);}

        void zero(){
            this->at(0) = 0.0;
            this->at(1) = 0.0;
            this->at(2) = 0.0;
        }

        T clone(){return {x(), y(), z()};}

        friend ostream &operator<<(std::ostream &os, Vector3D const &vec) {
            // Overloaded << operator for printing a vector
            return os << '(' << vec.x() << ", " << vec.y() << ", " << vec.z() << ')';
        }

        T operator+=(const T& other){
            // Add another position to this one

            // TODO: Work out how to do this without a copy
            this->at(0) += other.x();
            this->at(1) += other.y();
            this->at(2) += other.z();

            return {this->at(0), this->at(1), this->at(2)};
        }

        T operator+(const T& other){
            // Add another position to this one
            return {x()+other.x(), y()+other.y(), z()+other.z()};
        }
};


class Position: public Vector3D<Position>{};


class Velocity: public Vector3D<Velocity>{

    public:
        Position operator*(TimeIncrement dt){
            // r ≈ dr/dt ∆t = v ∆t
            return {x() * dt, y() * dt, z() * dt};
        }
};


class Acceleration: public Vector3D<Acceleration>{

    public:
        Velocity operator*(TimeIncrement dt) const{
            // dr/dt ≈ d^2r/dt^2 ∆t = a ∆t
            return {x() * dt, y() * dt, z() * dt};
        }
};


class Force: public Vector3D<Force>{

    public:
        Acceleration operator/(Mass& m) const {
            return {x() / m, y() / m, z() / m};
        }
};


class Particle{
    // Particle with a defined positions, velocity and force

    public:
        Mass mass = Mass(1.0);
        Position position = {0.0, 0.0, 0.0};
        Velocity velocity = {0.0, 0.0, 0.0};
        Force force = {0.0, 0.0, 0.0};
        Force prev_force = {0.0, 0.0, 0.0};

        Particle(double x, double y, double z){
            // Initialise a particle in a defined position

            this->position = {x, y, z};
        }

        void update_position(TimeIncrement dt){
            // Update the position based on a velocity verlet
            position += (velocity * dt) + (a() * dt * dt);
        }

        void update_velocity(TimeIncrement dt){
            velocity += (a() + a_prev()) * (dt / 2.);
        }

        friend bool operator==(const Particle& lhs, const Particle& rhs){
            // Equality pf particles is defined by equality of references
            return &lhs == &rhs;
        }

    protected:

        Acceleration a(){
            // Acceleration due to the current force on the particle (F = ma)
            return force / mass;
        }

        Acceleration a_prev(){
            // Acceleration due to the previous force on the particle
            return prev_force / mass;
        }

};


class LJPotential{

    public:
        LJPotential() = default;

        LJPotential(double epsilon, double sigma){
            // Initialise a Lennard Jones potential from ε and σ

            f[0] = epsilon / 2.0;
            f[1] = 12 * pow(sigma, 12);
            f[2] = -6 * pow(sigma, 6);
        }

        void add_force(Particle &particle_i,
                       Particle &particle_j){
            // Add the force on particle i due to particle j

            if (particle_i == particle_j) return;  // No self interaction

            double dx = particle_i.position.x() - particle_j.position.x();
            double dy = particle_i.position.y() - particle_j.position.y();
            double dz = particle_i.position.z() - particle_j.position.z();
            double r = sqrt(dx * dx + dy * dy + dz * dz);

            double c = f[0] * (f[1] * pow(r, -14) + f[2] * pow(r, -8));

            particle_i.force[0] += c * dx;
            particle_i.force[1] += c * dy;
            particle_i.force[2] += c * dz;
        }

    protected:
        // Coefficients used to calculate the gradient
        array<double, 3> f = {0.0, 0.0, 0.0};

};


class Particles : public vector<Particle>{
    // List of particles

    public:
        Particles() = default;

        explicit Particles(const string& positions_filename){
            // Initialise particles from a file of x,y,z positions

            add_particles(positions_filename);
        }

        void set_velocities(const string& filename){
            // Set velocities from a file of x,y,z velocities
            int i = 0;

            for (auto &vec : matrix_from(filename)){

                if (i > this->size()){
                    throw runtime_error("Cannot set velocity for particle");
                }
                this->data()[i].velocity = {vec[0], vec[1], vec[2]};

                i++;
            }
        }

        void calculate_forces(LJPotential &potential){
            // Calculate the forces on all particles

            for (auto &particle_i : *this){

                particle_i.prev_force = particle_i.force.clone();
                particle_i.force.zero();

                for (auto &particle_j: *this){
                    potential.add_force(particle_i, particle_j);
                }
            }
        }

        void print_positions(const string& filename){
            // Print the positions to a file

            ofstream file;
            file.open(filename);

            for (auto &particle : *this){
                file << setprecision(8)
                     << particle.position.x() << " "
                     << particle.position.y() << " "
                     << particle.position.z() << "\n";
            }

            file.close();
        }

        void update_positions(const TimeIncrement& dt){
            // Update the positions of all the particles

            for (auto &particle : *this){
                particle.update_position(dt);
            }
        }

        void update_velocities(const TimeIncrement& dt){
            // Update the velocities of all the particles

            for (auto &particle : *this){
                particle.update_velocity(dt);
            }
        }

    protected:
        void add_particles(const string& filename){
            // Add particles at defined positions from a file

            for (auto &vec : matrix_from(filename)){
                emplace_back(vec[0], vec[1], vec[2]);
            }
        }

        static vector<array<double, 3>> matrix_from(const string& filename){
            // Extract a Nx3 matrix of strings from a file

            string line;
            ifstream _file(filename);
            vector<array<double, 3>> matrix;

            while (getline(_file, line, '\n')) {

                if (line.empty()) continue;

                vector<string> xyz_items = split(line, ' ');

                if (xyz_items.size() != 3){
                    throw runtime_error("xyz line was not of the correct "
                                        "format. Must be (x y z), had: "+line);
                }
                matrix.push_back({stod(xyz_items[0]),
                                  stod(xyz_items[1]),
                                  stod(xyz_items[2])});
            }
            _file.close();

            return matrix;
        }

};


class Simulation{

    protected:
        LJPotential potential;
        NumberOfTimeSteps n_steps;
        TimeIncrement dt;

    public:
        Particles particles;

        Simulation(Particles _particles,
                   LJPotential _potential,
                   NumberOfTimeSteps _n_steps,
                   TimeIncrement _dt){
            // Initialise a simulation

            this->particles = move(_particles);
            this->potential = _potential;
            this->n_steps = _n_steps;
            this->dt = _dt;
        }

        void run(){
            // Run the simulation using a velocity verlet update

            particles.calculate_forces(potential);

            for (int i = 0; i < n_steps; i++){
                particles.update_positions(dt);
                particles.calculate_forces(potential);
                particles.update_velocities(dt);
            }
        }

};


int main(){

    auto cluster = Particles("positions.txt");
    cluster.set_velocities("velocities.txt");

    auto simulation = Simulation(cluster,
                                 LJPotential(100.0, 1.7),
                                 NumberOfTimeSteps(10000),
                                 TimeIncrement(0.01));
    simulation.run();

    simulation.particles.print_positions("final_positions.txt");

    return 0;
}
