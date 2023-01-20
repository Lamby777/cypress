/*
* You're probably gonna recognize a lot of this code from
* https://github.com/Lamby777/yx
*/

use sh_inline::*;
use users::*;
use std::fs;

const LINE_SEPARATOR: &str	= "--------------------------------------------------";

mod sub;

mod classes;
use classes::*;

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

		"audit"		=> {
			assert_argc(args, &[0]);
			sub::audit()
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
				"sudo"	=> {
					sub::list_sudo_users();
				},

				_		=> {
					sub::list_users();
				}
			}
		},

		"refs"		=> {
			assert_argc(args, &[0, 1]);

			if let Some(page) = args.first() {
				// resolve aliases
				let page = &page.to_lowercase();

				let page = match page.as_str() {
					"checklist" |
					"guide"		=> "clist",

					_			=> page
				};

				println!("Page: `{}`\n{}", page, LINE_SEPARATOR);

				let out = match page {
					"clist"	=> include_str!("refs/checklist.txt"),

					"apt"	=> include_str!("refs/apt.txt"),
					"dnf"	=> include_str!("refs/dnf.txt"),

					_		=> panic!("Not found!")
				};

				println!("{}", out);
			} else {
				println!(include_str!("refs/pages.txt"));
			}
		},

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
