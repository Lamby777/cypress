// Subcommand stuff

use crate::bash;

pub fn init() {
	bash!(include_str!("init.sh"));
	println!("\nCyPatrina init script complete!");
	println!("Please ensure none of its changes caused you to lose points...");
}
