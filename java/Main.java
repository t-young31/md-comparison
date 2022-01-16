import java.lang.Math;
import java.io.File; 
import java.util.Scanner;
import java.util.ArrayList;
import java.io.FileNotFoundException;


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


class LJPotential{

    private double[] f;

    public LJPotential(double epsilon, double sigma){

        this.f[0] = epsilon / 2.0;
        this.f[1] = 12 * Math.pow(sigma, 12);
        this.f[2] = -6 * Math.pow(sigma, 6);

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
