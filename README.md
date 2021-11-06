# zsh-spack
This plugin includes some useful aliases and functions for loading/unloading
Spack-generated modules. As it makes use of the `module` command it is much more
efficient than `spack load`.

## Installation

See [INSTALL.md](INSTALL.md).

## Usage

The `SPACK_MOD_ENV` environment variable should point to the file you want to
append your module load scripts to. Its default value is `"$HOME/.zshenv"`.

- Use `spma PKG` to add the module of a spack package
- Use `spmd PKG` to remove the module of a spack package
- Use `spml` to crudely print out the spack module load scripts in
  `$SPACK_MOD_ENV`
- `spmf` is aliased to `spack find`
- `spml` is aliased to `spack list`
