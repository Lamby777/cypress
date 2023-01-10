// Pass args stuff into lib.rs
fn main() {
	pizza::main(std::env::args().collect::<Vec<String>>());
}
