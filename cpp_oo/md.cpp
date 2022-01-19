//
// Created by Tom Young on 19/01/2022.
//
#include <string>
#include <vector>
#include <array>

using namespace std;


class Vector3D : public array<double, 3>{
    // A vector in 3D space with x, y, z components

    public:
        double x(){return this->data()[0];}
        double y(){return this->data()[1];}
        double z(){return this->data()[2];}
};

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

        Particle() = default;
};



class Particles : public vector<Particle>{
    // List of particles

    public:
        explicit Particles(const string& positions_filename){
            // Initialise particles from a file of x,y,z positions

            // TODO

        }

        void set_velocities(const string& filename){
            // Set velocities from a file of x,y,z velocities

            // TODO
        }

};



int main(){

    auto cluster = Particles("../data/positions.txt");
    cluster.set_velocities("../data/velocities.txt");


    return 0;
}