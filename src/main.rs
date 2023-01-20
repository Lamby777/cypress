// Pass args stuff into lib.rs

fn main() -> Result<(), Box<dyn std::error::Error>> {
	pizza::main(std::env::args().collect::<Vec<String>>())
}
