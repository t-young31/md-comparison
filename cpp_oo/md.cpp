//
// Created by Tom Young on 19/01/2022.
//
#include <string>
#include <vector>
#include <array>
#include <sstream>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <math.h>


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
class Vector3D : public array<double, 3>{
    // A vector in 3D space with x, y, z components

    public:

        double x() const {return at(0);}
        double y() const {return at(1);}
        double z() const {return at(2);}

        T operator/(double scalar) const {
            // Overloaded divide operator
            return {at(0)/scalar, at(1)/scalar, at(2)/scalar};
        }

        T operator*(double scalar) const {
            // Overloaded divide operator
            return {at(0)*scalar, at(1)*scalar, at(2)*scalar};
        }


    friend ostream &operator<<(std::ostream &os, Vector3D const &vec) {
        // Overloaded << operator for printing a vector
        return os << '(' << vec.x() << ", " << vec.y() << ", " << vec.z() << ')';
    }
};


class Position: public Vector3D<Position>{};
class Velocity: public Vector3D<Velocity>{};
class Acceleration: public Vector3D<Acceleration>{};


class Force: public Vector3D<Force>{

    public:
        void zero(){
            // Zero the force vector
            this->at(0) = 0.0;
            this->at(1) = 0.0;
            this->at(2) = 0.0;
        }
};


double checked_positive(double x){
    assert(x > 0);
    return x;
}


class Particle{
    // Particle with a defined positions, velocity and force

    public:
        double mass = 1.0;
        Position position = {0.0, 0.0, 0.0};
        Velocity velocity = {0.0, 0.0, 0.0};
        Force force = {0.0, 0.0, 0.0};
        Force prev_force = {0.0, 0.0, 0.0};

        Particle(double x, double y, double z){
            // Initialise a particle in a defined position

            this->position = {x, y, z};
        }

        void update_position(double dt){
            // Update the position based on a velocity verlet
            position += (static_cast<Position>(velocity * dt)
                        + static_cast<Position>(a() * dt*dt));
        }

        friend bool operator==(const Particle& lhs, const Particle& rhs){
            // Equality pf particles is defined by equality of references
            return &lhs == &rhs;
        }

    protected:

        Vector3D<Force> a(){
            // Acceleration due to the current force on the particle (F = ma)
            return force / mass;
        }

        Vector3D<Force> a_prev(){
            // Acceleration due to the previous force on the particle
            return prev_force / mass;
        }

};


class LJPotential{

public:
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

        particle_j.force[0] += c * dx;
        particle_j.force[1] += c * dy;
        particle_j.force[2] += c * dz;
    }

protected:
    // Coefficients used to calculate the gradient
    array<double, 3> f = {0.0, 0.0, 0.0};

};


class Particles : public vector<Particle>{
    // List of particles

    public:
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

                particle_i.prev_force = particle_i.force;
                particle_i.force.zero();

                for (auto &particle_j: *this){
                    potential.add_force(particle_i, particle_j);
                }
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



int main(){

    // TODO: remove hard coded paths
    auto cluster = Particles("/Users/tom/repos/md-comparison/data/positions.txt");
    cluster.set_velocities("/Users/tom/repos/md-comparison/data/velocities.txt");

    auto potential = LJPotential(100.0, 1.7);

    return 0;
}