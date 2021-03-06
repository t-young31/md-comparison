import java.lang.Math;
import java.io.File; 
import java.io.FileWriter; 
import java.util.Scanner;
import java.util.ArrayList;
import java.io.*;
import java.lang.*;


class _3DVector {
    // Vector of 3 components: x, y, z

    public double x;
    public double y;
    public double z;


    public _3DVector(double x, double y, double z){
    
        this.x = x;
        this.y = y;
        this.z = z;
    }

}


class Position extends _3DVector{

    public Position(double x, double y, double z){
         super(x, y, z);
    }

}


class Velocity extends _3DVector{

    public Velocity(double x, double y, double z){
         super(x, y, z);
    }
}


class Force extends _3DVector{

    public Force(double x, double y, double z){
         super(x, y, z);
    }
   
    public Force copy(){
        return new Force(this.x, this.y, this.z);
    }

    public void zero(){
        // Zero the elements of the force
        this.x = 0.0;
        this.y = 0.0;
        this.z = 0.0;
    }
}


class Acceleration extends _3DVector{

   public Acceleration(double x, double y, double z){
        super(x, y, z);
    }
}

class Mass {
    
    double value;

    public Mass(double m){
        this.value = 1.0;
    }
}


class Particle {

    public Mass mass;
    public Position position;        
    public Velocity velocity;
    public Force force;
    public Force prev_force;

    public Particle(){
        // Construct a particle
       
        this.mass = new Mass(1.0);
        this.position = new Position(0.0, 0.0, 0.0);
        this.velocity = new Velocity(0.0, 0.0, 0.0);
        this.force = new Force(0.0, 0.0, 0.0);
        this.prev_force = this.force.copy();

  }

    public Acceleration acceleration(){
        // Acceleration due to the current force
        return this.an_acceleration(this.force);
    }


    public Acceleration prev_acceleration(){
        // Acceleration due to previonsly evaluated force
        return this.an_acceleration(this.prev_force);
    }


    private Acceleration an_acceleration(Force force){
        // Calculate an acceleration given a force
        return new Acceleration(force.x / this.mass.value,
                                force.y / this.mass.value, 
                                force.z / this.mass.value);
    }

}


class LJPotential{

    private double[] f = {0.0, 0.0, 0.0};

    public LJPotential(double epsilon, double sigma){

        this.f[0] = epsilon / 2.0;
        this.f[1] = 12 * Math.pow(sigma, 12);
        this.f[2] = -6 * Math.pow(sigma, 6);

    }    

    public void add_force(Particle particle_i,
                          Particle particle_j){

        // Add the force on particle i due to particle j
        
        if (System.identityHashCode(particle_i) 
            == System.identityHashCode(particle_j)){
            // Particles do not interact with themselves 
            return;
        }

        var pos_i = particle_i.position;
        var pos_j = particle_j.position;

        double dx = pos_i.x - pos_j.x;
        double dy = pos_i.y - pos_j.y;
        double dz = pos_i.z - pos_j.z;

        double r = Math.sqrt(dx*dx + dy*dy + dz*dz);

        double c = this.f[0] * (this.f[1]*Math.pow(r, -14) + this.f[2]*Math.pow(r, -8));
        
        particle_i.force.x += c*dx;
        particle_i.force.y += c*dy;
        particle_i.force.z += c*dz; 
    }

}


class Particles extends ArrayList<Particle> {

    public Particles(String positions_filename){
        // Construct a set of particles from a positions file
        super();
        this.add_particles(positions_filename); 
    }

    private void add_particles(String position_filename){
        // Determine the number and position of particles
        // from a file with a format:
        // 
        //   x0 y0 z0
        //   x1 y1 z1
        //   .  .  .
        
        try{
            File file = new File(position_filename);
            Scanner reader = new Scanner(file);
        
            while (reader.hasNextLine()){
                String[] items = reader.nextLine().split("\\s+");

                Particle particle = new Particle();

                particle.position.x = Double.parseDouble(items[0]);
                particle.position.y = Double.parseDouble(items[1]);
                particle.position.z = Double.parseDouble(items[2]);

                this.add(particle);        
            }
            reader.close();

        } catch (FileNotFoundException e){
                System.out.println("Failed to load the position file");
        }
   } 

    public void set_velocities(String velocities_filename){
        // Set the velocities of the particles from a file

        int i = 0;
    
        try{
            File file = new File(velocities_filename);
            Scanner reader = new Scanner(file);
        
            while (reader.hasNextLine()){
                String[] items = reader.nextLine().split("\\s+");

                Particle particle = this.get(i);

                particle.velocity.x = Double.parseDouble(items[0]);
                particle.velocity.y = Double.parseDouble(items[1]);
                particle.velocity.z = Double.parseDouble(items[2]);

                i += 1;
            }
            reader.close();

        } catch (FileNotFoundException e){
                System.out.println("Failed to load the velocity file");
        }
    }


    public void print_positions(){
        // Print a .txt file of the positions of each particle, in the
        // same format as the files read to initialise the particles
        
        try{        
            var file = new FileWriter("positions.txt");
            
            for (var particle : this){
                var pos = particle.position;

                file.write(String.format("%.6f  %.6f  %.6f\n", pos.x, pos.y, pos.z));
            }
    
            file.close();

        } catch (IOException e) {
            System.out.println("An error occurred saving the positions file");
            e.printStackTrace();
        }

    }


    public void calculate_forces(LJPotential potential){
        // Calculate the force on each particle due to a potential
        
        for (var particle_i : this){
          
            particle_i.prev_force = particle_i.force.copy();
            particle_i.force.zero();

            for (var particle_j : this){
                potential.add_force(particle_i, particle_j);
            }
        }
    }

   
    public void update_positions(double dt){
        // Use a velocity verlet update on the position of each particle
        
        for (var particle : this){

            var v = particle.velocity;        
            var a = particle.acceleration();

            particle.position.x += v.x * dt + a.x * dt * dt; 
            particle.position.y += v.y * dt + a.y * dt * dt;
            particle.position.z += v.z * dt + a.z * dt * dt;
        }
    
    }

    
    public void update_velocities(double dt){
        // Use a velocity verlet update on the velocities of each particle

        for (var particle : this){

            var a_prev = particle.prev_acceleration();
            var a = particle.acceleration();

            particle.velocity.x += (a.x + a_prev.x) * dt / 2.0; 
            particle.velocity.y += (a.y + a_prev.y) * dt / 2.0;
            particle.velocity.z += (a.z + a_prev.z) * dt / 2.0;

        } 
    }

}


class NumberOfTimeSteps {

    public int value;

    public NumberOfTimeSteps(int value) {
        if (value <= 0){
            throw new IllegalArgumentException("Number of timesteps must be positive");
        }
 
        this.value = value;
    }
}


class TimeStep {

    public double value;

    public TimeStep(double value) {
        if (value <= 0){
            throw new IllegalArgumentException("Timestep must be a postive float");
        }
        this.value = value; 
   }
} 




class Simulation{


    public Particles particles;
    LJPotential potential;
    int n_steps;
    double dt;


    public Simulation(Particles particles,
                      LJPotential potential,
                      NumberOfTimeSteps n_steps,
                      TimeStep timestep){
        // Constructor for a simulation

        this.particles = particles;
        this.potential = potential;
        this.n_steps = n_steps.value;
        this.dt = timestep.value;
 
    }                    

    public void run(){
        // Run the molecular dynamics simulation using
        // a velocity verlet update on positions and velocities
        // of each particle due the to the intermolecular force

        this.particles.calculate_forces(this.potential); 

        for (int step = 0; step < this.n_steps; step++){
            
            this.particles.update_positions(this.dt);
            this.particles.calculate_forces(this.potential);
            this.particles.update_velocities(this.dt);
        }
    }

}




public class Main {
    
    public static void main(String... args) {
        
        var particles = new Particles("../data/positions.txt");
        particles.set_velocities("../data/velocities.txt");
 
        var n_steps = new NumberOfTimeSteps(10000);
        var timestep = new TimeStep(0.01);              

        var potential = new LJPotential(100.0, 1.7); 

        var simulation = new Simulation(particles,
                                        potential,
                                        n_steps,
                                        timestep);
        
        simulation.run();
        simulation.particles.print_positions();  
    }
}
