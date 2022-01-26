use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use std::io::Write;


fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
    // Read a set of file lines into an iterator
    where P: AsRef<Path>, {
        let file = File::open(filename)?;
        Ok(io::BufReader::new(file).lines())
}


fn str_to_doubles(string: &str) -> Vec<f64>{
    // Convert a string seperated by whitespace to doubles

    let mut vec = Vec::new();

    for item in string.split_whitespace(){
        vec.push(item.parse::<f64>().unwrap());
    }

    vec
}


#[derive(Default)]
struct Particle{

    position:   [f64; 3],
    velocity:   [f64; 3],
    force:      [f64; 3],
    prev_force: [f64; 3],

}


impl Particle{

    fn from_position(x: f64, 
                         y: f64, 
                         z: f64) -> Particle{
        // Create a particle from a defined position

        let mut particle : Particle = Default::default();
        particle.position = [x, y, z];

        particle
    }

    fn from_position_vec(vec: Vec<f64>) -> Particle{
        // Create a particle from a vector of positions

        if vec.len() != 3{
            panic!("Particles constructed from positions 
                   must be formed of a 3-tuple");
        }

        Particle::from_position(vec[0], vec[1], vec[2])
    }

    fn position_str(&self) -> String{
        // String representation of the position
        format!("{:.5}  {:.5}  {:.5}", 
                self.position[0],
                self.position[1],
                self.position[2])
    }    

    fn zero_force(&mut self){
        // Zero the force vector
        for i in 0..=2{
            self.force[i] = 0.0;
        }
    }

}


#[derive(Default)]
struct Particles{

    vec: Vec<Particle>

}


impl Particles{

    fn push(&mut self, particle: Particle){
        // Add a particle to this set
        self.vec.push(particle)
    }

    fn from_file(filename: &str) -> Particles{
        // Populate the set of particles from a .txt file
        // containing particle positions, with format:
        // x0  y0  z0
        // x1  y1  z1
        // .   .   .

        let mut particles : Particles = Default::default();
    

        if let Ok(lines) = read_lines(filename) {
            for line in lines {
                if let Ok(ip) = line {

                    let pos = str_to_doubles(&ip);
                    particles.push(Particle::from_position_vec(pos));
                }
            }
        }

        particles
    }

    fn set_velocities(&mut self, filename: &str){
        // Set the velocities of all the particles from 
        // a .txt file containing x, y, z velocity components

         if let Ok(lines) = read_lines(filename) {
            for (i, line) in lines.enumerate() {
                if let Ok(ip) = line {

                    let vel = str_to_doubles(&ip);
                    self.vec[i].velocity = vel.try_into().unwrap();
                }
            }
        }
    }

    fn print_positions(&self, filename: &str){
        // Print the particle positions to a file
        
        let path = Path::new(filename);

        let mut file = match File::create(&path) {
            Err(why) => panic!("couldn't create the file: {}", why),
            Ok(file) => file,
        };

        for particle in &self.vec{
            file.write(particle.position_str().as_bytes());
        }
    }

    fn calculate_forces(&mut self, potential: &LJPotential){
        // Calculate the forces between all the particles

        for particle_i in self.vec.iter_mut() {

            particle_i.prev_force = particle_i.force.clone();
            particle_i.zero_force();

            for particle_j in self.vec.iter() {
                potential.add_force(particle_i, particle_j);
            }
        }
    }

    fn update_positions(&mut self){
        // Update the positions of all particles under the current forces

    }

    fn update_velocities(&mut self){
        // Update these velocities due to the current and previous positions

    }

} // Particles


#[derive(Default)]
struct LJPotential{

    f: [f64; 3]
}


impl LJPotential{

    fn from_epsilon_sigma(epsilon: f64, sigma: f64) -> LJPotential{
        // Create a potential from ε and σ 
        let mut lj : LJPotential = Default::default();        

        lj.f[0] = epsilon/2.0;
        lj.f[1] = 12_f64 * sigma.powi(12);
        lj.f[2] = -6_f64 * sigma.powi(6);
        
        lj
    }

    fn add_force(&self,
                 particle_i: &mut Particle,
                 particle_j: &Particle){
        // Add the force on particle i due to particle j

        if particle_i as *const _ == particle_j as *const _ {return;}

        let dx = particle_i.position[0] - particle_j.position[0];
        let dy = particle_i.position[1] - particle_j.position[1];
        let dz = particle_i.position[2] - particle_j.position[2];
        let r = (dx * dx + dy * dy + dz * dz).sqrt();

        let c = self.f[0] * (self.f[1] * r.powi(-14) + self.f[2] * r.powi(-8));

        particle_i.force[0] += c * dx;
        particle_i.force[1] += c * dy;
        particle_i.force[2] += c * dz;
    }

}


struct Simulation{

    particles: Particles,
    potential: LJPotential,
    n_steps:   u32,
    timestep:  f64
} 


impl Simulation{

    fn run(&mut self){
        // Run the simulation

        self.particles.calculate_forces(&self.potential);

        for _ in 0..self.n_steps {

            self.particles.update_positions();
            self.particles.calculate_forces(&self.potential);
            self.particles.update_velocities();
        }
    }
} // Simulation


fn main() {
    
    let mut cluster = Particles::from_file("positions.txt");
    cluster.set_velocities("velocities.txt");

    let mut simulation = Simulation{
                            particles: cluster,
                            potential: LJPotential::from_epsilon_sigma(100_f64, 1.7_f64),
                            n_steps:   10000_u32,
                            timestep:  0.01_f64
                         };

    simulation.run();
    simulation.particles.print_positions("positions.txt");
}

