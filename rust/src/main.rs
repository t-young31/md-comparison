use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;


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
pub struct Particle{

    position:   [f64; 3],
    velocity:   [f64; 3],
    force:      [f64; 3],
    prev_force: [f64; 3],

}


impl Particle{

    pub fn from_position(x: f64, 
                         y: f64, 
                         z: f64) -> Particle{
        // Create a particle from a defined position

        let mut particle : Particle = Default::default();
        particle.position = [x, y, z];

        particle
    }

    pub fn from_position_vec(vec: Vec<f64>) -> Particle{
        // Create a particle from a vector of positions

        if vec.len() != 3{
            panic!("Particles constructed from positions 
                   must be formed of a 3-tuple");
        }


        Particle::from_position(vec[0], vec[1], vec[2])
    }

}


#[derive(Default)]
pub struct Particles{

    vec: Vec<Particle>

}

impl Particles{

    pub fn push(&mut self, particle: Particle){
        // Add a particle to this set
        self.vec.push(particle)
    }


    pub fn from_file(filename: &str){
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
                    let p = Particle::from_position_vec(pos); 
                    particles.push(p);
                }
            }
        }
    }


}


fn main() {
    
    let particles = Particles::from_file("positions.txt");

}

