// Subcommand stuff

use crate::{all_users, bash, User, LINE_SEPARATOR};
use libdx::Result;
use std::borrow::Borrow;
use users::get_current_uid;

const LS_R_PATH: &str = "~/Desktop/homedir-recursive.txt";

pub fn init() -> Result<()> {
    bash!(include_str!("sh/init.sh"))?;

    println!("\nCyPatrina 1.1 init script complete!");
    println!("Please ensure none of its changes caused you to lose points...");
    Ok(())
}

pub fn audit() -> Result<()> {
    // Check for common security vulnerabilities

    println!("Unauthorized files:");
    bash!("sudo find /home -type f -iname \"*.mp3\"")?;
    bash!("sudo find /home -type f -iname \"*.mp4\"")?;
    bash!("sudo find /home -type f -iname \"*.wav\"")?;
    bash!("sudo find /home -type f -iname \"*.tar.gz\"")?;
    bash!("sudo find /home -type f -iname \"*.tgz\"")?;
    bash!("sudo find /home -type f -iname \"*.zip\"")?;
    bash!("sudo find /home -type f -iname \"*.deb\"")?;

    println!("TIP: {} may reveal more sussy amogus files", LS_R_PATH);
    // if rm fail, ignore error
    let _ = bash!(format!("rm {}", LS_R_PATH));

    // use find instead of ls -R to get actual paths
    bash!(format!(
        "sudo find /home -path '*/.*' -prune -o -print > {}",
        LS_R_PATH
    ))?;

    println!("\nWorld-writable files:");
    bash!(r"sudo find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print")?;

    println!("\nNo-user files:");
    bash!(r"sudo find / -xdev \( -nouser -o -nogroup \) -print")?;

    Ok(())
}

pub fn passwd(args: &[String]) {
    let em = args.len() == 2 && args[0] == "em";

    let new_pass = args.last().unwrap();

    let errors = for_each_user(
        |user| {
            let name = user.name().to_string_lossy();

            let cmd = format!(
                "sudo passwd {} <<< \"{}\"$'\n'\"{}\"",
                name, new_pass, new_pass
            );

            bash!(cmd).is_ok()
        },
        if em { Some(get_current_uid()) } else { None },
    );

    if errors > 0 {
        println!("{} passwords had issues being updated...", errors);
    } else {
        println!("Passwords updated successfully!");
    }
}

pub fn list_users() {
    for_each_user(
        |user| {
            println!("({}) {:?}", user.uid(), user.name());

            true
        },
        None,
    );
}

pub fn list_sudo_users() {
    println!(
        "The following users are in the 'wheel' or 'sudo' groups:\n{}",
        LINE_SEPARATOR
    );

    for_each_user(
        |user| {
            let groups = user.groups().unwrap();

            let is_admin = groups.iter().any(|g| {
                let group_name = g.name().to_string_lossy();

                // Debian uses "sudo" and Fedora uses "wheel"
                matches!(group_name.borrow(), "sudo" | "wheel")
            });

            if is_admin {
                println!("({}) {:?}", user.uid(), user.name());
            }

            true // no errors
        },
        None,
    );
}

// returns number of fails
fn for_each_user<C>(action: C, except: Option<u32>) -> u16
where
    C: Fn(User) -> bool,
{
    let users = all_account_users();
    let excepting = except.is_some();

    // don't make this call if there isn't a point anyway
    let current_uid = if excepting { get_current_uid() } else { 0 };

    let mut errors = 0;

    for user in users {
        if excepting && (user.uid() == current_uid) {
            continue;
        };

        if !action(user) {
            errors += 1;
        }
    }

    errors
}

fn all_account_users() -> impl Iterator<Item = User> {
    (unsafe { all_users() }).filter(|user| {
        user.uid() >= 1000 &&	// system users
		user.uid() != 65534 // nobody
    })
}
