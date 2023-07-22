package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

func assert_not_nil(e error) {
    if e != nil {
        panic(e)
    }
}

type Vector3D struct {
    x float64
    y float64
    z float64
}

type Particle struct {
    position Vector3D
    velocity Vector3D
    force Vector3D
    prev_force Vector3D
    mass float64
}

func (p *Particle) acceleration() Vector3D {
    m := p.mass
    return Vector3D{p.force.x / m, p.force.y / m, p.force.z / m}
}

func (p *Particle) prev_acceleration() Vector3D {
    m := p.mass
    return Vector3D{p.prev_force.x / m, p.prev_force.y / m, p.prev_force.z / m}
}

type LennardJonesPotential struct {
    sigma float64
    epsilon float64
}

type SimulationArguments struct {
    particles []Particle
    potential LennardJonesPotential
    n_steps uint64
    timestep float64
}

func is_blank(str string) bool{
    return len(strings.Fields(str)) == 0
}

func positive(number float64) float64{
    if number <= 0 {
        panic("Number must be positive")
    }
    return number
}

func xyz_line_to_floats(line string) []float64{
    var floats []float64

    for _, item := range strings.Fields(line){
        if number, err := strconv.ParseFloat(item, 64); err == nil{
            floats = append(floats, number)
        }
    }

    return floats
}

func particles_from_positions_file(filepath string) []Particle{
    var particles []Particle

    file_bytes, err := os.ReadFile(filepath)
    assert_not_nil(err)

    lines := strings.Split(string(file_bytes), "\n")
    for _, line := range lines {
        if is_blank(line){
            continue
        }
        items := xyz_line_to_floats(line)
        particle := Particle{
            position: Vector3D{items[0], items[1], items[2]},
            velocity: Vector3D{0.0, 0.0, 0.0},
            force: Vector3D{0.0, 0.0, 0.0},
            prev_force: Vector3D{0.0, 0.0, 0.0},
            mass: 1.0,
        }
        particles = append(particles, particle)
    }
    
    return particles
}

func set_velocities_from_file(particles []Particle, filepath string) {
    file_bytes, err := os.ReadFile(filepath)
    assert_not_nil(err)

    lines := strings.Split(string(file_bytes), "\n")
    for i, _ := range particles {  // go uses values not references in range
        items := xyz_line_to_floats(lines[i])
        particles[i].velocity.x = items[0]
        particles[i].velocity.y = items[1]
        particles[i].velocity.z = items[2]
    }
}

func update_positions(particles []Particle, timestep float64){
    square_timestep := timestep * timestep

    for i, _ := range particles{
        a := particles[i].acceleration()
        particles[i].position.x += particles[i].velocity.x * timestep + a.x * square_timestep
        particles[i].position.y += particles[i].velocity.y * timestep + a.y * square_timestep
        particles[i].position.z += particles[i].velocity.z * timestep + a.z * square_timestep
    }
}

func update_velocities(particles []Particle, timestep float64){
    half_timestep := timestep / 2.0

    for i, _ := range particles{
        a := particles[i].acceleration()
        a_prev := particles[i].prev_acceleration()
        particles[i].velocity.x += (a.x + a_prev.x) * half_timestep
        particles[i].velocity.y += (a.y + a_prev.y) * half_timestep
        particles[i].velocity.z += (a.z + a_prev.z) * half_timestep
    }
}

func update_forces(particles []Particle, potential *LennardJonesPotential){
    c0 := potential.epsilon / 2.0
    c1 := 12 * math.Pow(potential.sigma, 12)
    c2 := -6 * math.Pow(potential.sigma, 6)

    for i := 0; i < len(particles); i++{
        particles[i].prev_force.x = particles[i].force.x
        particles[i].prev_force.y = particles[i].force.y
        particles[i].prev_force.z = particles[i].force.z

        particles[i].force.x = 0.0
        particles[i].force.y = 0.0
        particles[i].force.z = 0.0

        for j := 0; j < len(particles); j++{
            if i == j{
                continue
            }

            dx := particles[i].position.x - particles[j].position.x
            dy := particles[i].position.y - particles[j].position.y
            dz := particles[i].position.z - particles[j].position.z

            r := math.Sqrt(dx * dx + dy * dy + dz * dz)
            c := c0 * (c1 / math.Pow(r, 14) + c2 / math.Pow(r, 8))
            particles[i].force.x += c * dx
            particles[i].force.y += c * dy
            particles[i].force.z += c * dz
        }
    }
}

func simulate(args SimulationArguments) {
    update_forces(args.particles, &args.potential)

    for i := uint64(0); i < args.n_steps; i++{
        update_positions(args.particles, args.timestep)
        update_forces(args.particles, &args.potential)
        update_velocities(args.particles, args.timestep)
    }
}

func print_positions(particles []Particle, filename string) {

    file, err := os.Create(filename)
    assert_not_nil(err)
    defer file.Close()

    for i, _ := range particles{

        position := particles[i].position
        str := fmt.Sprintf("%g %g %g\n", position.x, position.y, position.z)
        _, err := file.Write([]byte(str))
        assert_not_nil(err)
    }
}

func main() {
    
    particles := particles_from_positions_file("data/positions.txt")
    set_velocities_from_file(particles, "data/velocities.txt")
    simulate(SimulationArguments{
        particles: particles,
        potential: LennardJonesPotential{epsilon: 100, sigma: 1.7},
        n_steps: 10000,
        timestep: positive(0.01),
    })
    print_positions(particles, "final_positions.txt")
}
