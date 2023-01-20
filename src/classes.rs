// Permission stuff for files

use std::{path::{PathBuf, Path}, fmt};
use bit_iter::BitIter;

use crate::fs;
use std::os::unix::fs::PermissionsExt;

pub type RWXOctal = u32;
pub type AnyError = Box<dyn std::error::Error>;

pub struct RWX {
	read:		bool,
	write:		bool,
	execute:	bool,
}

pub struct LinuxFile {
	path: PathBuf,
}

impl LinuxFile {
	pub fn new(path: impl AsRef<Path>) -> Self {
		let path_owned = path.as_ref().to_owned();

		Self {
			path:	path_owned,
		}
	}

	pub fn get_owner(&self) {
		todo!()
	}

	fn least_privilege() {
		/*
		Logic gate for Principle of Least Privilege
		(allow less but not more than required)
		
		Perms are:	1100
		Should be:	1010
		Result:		0100
		*/
	}

	pub fn get_perms_octals(&self) -> Result<RWXOctal, AnyError> {
		let file = fs::File::open(&self.path)?;

		let metadata = file.metadata()?;
		Ok(metadata.permissions().mode())
	}

	pub fn get_perms_bits(&self) -> Result<BitIter<u32>, AnyError> {
		let rwxo = self.get_perms_octals();
		let rwxo = rwxo.expect("Error reading permissions");

		let bits = BitIter::from(rwxo);

		Ok(bits)
	}

	pub fn get_user_perms() -> RWX {
		todo!()
	}

	pub fn get_group_perms() -> RWX {
		todo!()
	}

	pub fn get_world_perms() -> RWX {
		todo!()
	}
}

#[derive(Debug, Clone, Copy)]
pub enum Removable {
	Samba
}

impl fmt::Display for Removable {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Removable::Samba => write!(f, "Samba"),
        }
    }
}
