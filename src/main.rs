// Pass args stuff into lib.rs

fn main() -> Result<(), Box<dyn std::error::Error>> {
	pz::main(std::env::args().collect::<Vec<String>>())
}
