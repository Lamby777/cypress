// Subcommand stuff

use crate::bash;

pub fn init() {
	let res = bash!(include_str!("sh/init.sh"));
	println!("\nCyPatrina init script complete!");

	if res.is_err() {
		println!("Failed to complete CyPatrina init script...");
	} else {
		println!("Please ensure none of its changes caused you to lose points...");
	}
}
