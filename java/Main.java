
class Particles{

    public Particles(String positions_filename){
        // Construct a set of particles from a positions file
        
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
