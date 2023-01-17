/*
* You're probably gonna recognize a lot of this code from
* https://github.com/Lamby777/yx
*/

use sh_inline::*;
use users::*;

const LINE_SEPARATOR: &str	= "--------------------------------------------------";

mod sub;

pub fn main(args: Vec<String>) {
    if args.len() < 2 { return show_help(); }

    // --stolen-- BORROWED from yx code :D
	let cmd = &args[1].to_lowercase();
	let args = &args[2..];

	let cmd = cmd_replace_aliases(cmd);

	match cmd {
		"init"		=> {
			assert_argc(args, &[0]);
			sub::init()
		},

		"passwd"	=> {
			assert_argc(args, &[1, 2]);
			sub::passwd(args)
		},

		"list"		=> {
			assert_argc(args, &[0, 1]);
			
			// unwrap_or requires an unnecessary String, at least the way I tried :/
			let mode: &str = match args.first() {
				Some(i) => i,
				None => "list"
			};

			match mode {
				"sudo"		=> {
					sub::list_sudo_users();
				},

				"users"	| _	=> {
					sub::list_users();
				}
			}
		}

        _ => todo!()
    }
}

pub fn show_help() {
	println!("{}\n{}{}\n", LINE_SEPARATOR, include_str!("help.txt"), LINE_SEPARATOR);
}

pub fn assert_argc(args: &[String], lens: &[usize]) {
	let len = args.len();

	let mapped: Vec<String> = lens.iter().map(|&id| id.to_string()).collect();
	let joined = mapped.join("|");

	if !lens.contains(&len) {
		panic!("This subcommand requires {} arguments, but you only gave {}!", joined, len);
	}
}

fn cmd_replace_aliases<'a>(cmd: &'a String) -> &'a str {
	match cmd.as_str() {
		_		=> &cmd
	}
}
