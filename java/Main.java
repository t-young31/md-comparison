import java.io.File; 
import java.util.Scanner;
import java.util.ArrayList;
import java.io.FileNotFoundException;


class Position{

    public double x;
    public double y;
    public double z;


    public Position(double x, double y, double z){
    
        this.x = x;
        this.y = y;
        this.z = z;
    }

}



class Particle {

    public Position position;

    public Particle(){
        // Construct a particle
   }

}



class Particles extends ArrayList<Particle> {

    public Particles(String positions_filename){
        // Construct a set of particles from a positions file
       super();
 
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

                double x = Double.parseDouble(items[0]);
                double y = Double.parseDouble(items[1]);
                double z = Double.parseDouble(items[2]);
                particle.position = new Position(x, y, z);

                this.add(particle);        
            }
            reader.close();

        } catch (FileNotFoundException e){
                System.out.println("Failed to load the file");
        }
        
        

   } 
    

    public void set_velocities(String velocities_filename){}

}



public class Main {
    
    public static void main(String... args) {
        
        Particles particles = new Particles("data/positions.txt");
        particles.set_velocities("data/velocities.txt");
        
        // System.out.println("Hello, World!");
    }
}
