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


class Vector3D : public array<double, 3>{
    // A vector in 3D space with x, y, z components

    public:
        double x() const {return at(0);}
        double y() const {return at(1);}
        double z() const {return at(2);}


};

ostream &operator<<(std::ostream &os, Vector3D const &vec) {
    // Overloaded << operator for printing vector
    return os << '(' << vec.x() << ", " << vec.y() << ", " << vec.z() << ')';
}

class Position: public Vector3D{};
class Velocity: public Vector3D{};

class Force: public Vector3D{};


class Particle{
    // Particle with a defined positions, velocity and force

    public:
        Position position = {0.0, 0.0, 0.0};
        Velocity velocity = {0.0, 0.0, 0.0};
        Force force = {0.0, 0.0, 0.0};
        Force prev_force = {0.0, 0.0, 0.0};

        Particle(double x, double y, double z){
            // Initialise a particle in a defined position

            this->position = {x, y, z};
        }
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

            for (auto &vec : matrix_from_filename(filename)){

                if (i > this->size()){
                    throw runtime_error("Cannot set velocity for particle");
                }
                this->data()[i].velocity = {vec[0], vec[1], vec[2]};

                i++;
            }
        }

    protected:
        void add_particles(const string& filename){
            // Add particles at defined positions from a file

            for (auto &vec : matrix_from_filename(filename)){
                emplace_back(vec[0], vec[1], vec[2]);
            }
        }

        static vector<array<double, 3>> matrix_from_filename(const string& filename){
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

    return 0;
}