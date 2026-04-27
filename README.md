# openconnect-sso

Wrapper script for OpenConnect supporting Azure AD (SAMLv2) authentication
to Cisco SSL-VPNs

[![Release](https://github.com/PrestonHager/openconnect-sso/actions/workflows/release.yml/badge.svg)](https://github.com/PrestonHager/openconnect-sso/actions/workflows/release.yml)
[![Tests](https://github.com/PrestonHager/openconnect-sso/actions/workflows/test.yml/badge.svg)](https://github.com/PrestonHager/openconnect-sso/actions/workflows/test.yml)
[![Nix Tests](https://github.com/PrestonHager/openconnect-sso/actions/workflows/nix-tests.yml/badge.svg)](https://github.com/PrestonHager/openconnect-sso/actions/workflows/nix-tests.yml)

## Installation

> **Note**: This repository (`PrestonHager/openconnect-sso`) is a fork and does not publish to any package indexes like PyPI. Use one of the installation methods below specific to this repository.

### Using nix flakes *(Recommended)*

If you have [Nix](https://nixos.org/nix/) with flakes enabled, you can run `openconnect-sso` directly without installing:

```shell
$ nix run github:PrestonHager/openconnect-sso -- --help
```

To install permanently:

```shell
$ nix profile install github:PrestonHager/openconnect-sso
$ openconnect-sso --help
```

### Using nix (traditional)

The easiest method to try is by installing directly:

```shell
$ nix-env -i -f https://github.com/PrestonHager/openconnect-sso/archive/main.tar.gz
unpacking 'https://github.com/PrestonHager/openconnect-sso/archive/main.tar.gz'...
[...]
installing 'openconnect-sso-0.8.2'
[...]
$ openconnect-sso
```

An overlay is also available to use in nix expressions:

``` nix
let
  openconnectOverlay = import "${builtins.fetchTarball https://github.com/PrestonHager/openconnect-sso/archive/main.tar.gz}/overlay.nix";
  pkgs = import <nixpkgs> { overlays = [ openconnectOverlay ]; };
in
  #  pkgs.openconnect-sso is available in this context
```

... or to use in `configuration.nix`:

``` nix
{ config, ... }:

{
  nixpkgs.overlays = [
    (import "${builtins.fetchTarball https://github.com/PrestonHager/openconnect-sso/archive/main.tar.gz}/overlay.nix")
  ];
}
```

### From GitHub Releases

Download the latest release from [GitHub Releases](https://github.com/PrestonHager/openconnect-sso/releases) and install with pip:

```shell
# Download the wheel file from the latest release
$ pip install openconnect_sso-*.whl

# Or install directly from GitHub release URL
$ pip install https://github.com/PrestonHager/openconnect-sso/releases/latest/download/openconnect_sso-0.8.2-py3-none-any.whl
```

### Building from Source

Clone this repository and build from source using [UV](https://docs.astral.sh/uv/):

```shell
$ git clone https://github.com/PrestonHager/openconnect-sso.git
$ cd openconnect-sso
$ uv build
$ pip install dist/openconnect_sso-*.whl
```

Or use the included Makefile:

```shell
$ git clone https://github.com/PrestonHager/openconnect-sso.git
$ cd openconnect-sso
$ make dist
$ pip install dist/openconnect_sso-*.whl
```

### Using pip/pipx *(Original Repository)*

> **Note**: This installs the original `vlaci/openconnect-sso` package, not this fork.

A generic way that works on most 'standard' Linux distributions out of the box.
The following example shows how to install `openconect-sso` along with its
dependencies including Qt:

```shell
$ pip install --user pipx
Successfully installed pipx
$ pipx install "openconnect-sso[full]"
⣾ installing openconnect-sso
  installed package openconnect-sso 0.4.0, Python 3.7.5
  These apps are now globally available
    - openconnect-sso
⚠️  Note: '/home/vlaci/.local/bin' is not on your PATH environment variable.
These apps will not be globally accessible until your PATH is updated. Run
`pipx ensurepath` to automatically add it, or manually modify your PATH in your
shell's config file (i.e. ~/.bashrc).
done! ✨ 🌟 ✨
Successfully installed openconnect-sso
$ pipx ensurepath
Success! Added /home/vlaci/.local/bin to the PATH environment variable.
Consider adding shell completions for pipx. Run 'pipx completions' for
instructions.

You likely need to open a new terminal or re-login for the changes to take
effect. ✨ 🌟 ✨
```

Of course you can also install via `pip` instead of `pipx` if you'd like to
install system-wide or a virtualenv of your choice.

### On Arch Linux *(Original Repository)*

There is an unofficial package available for Arch Linux on
[AUR](https://aur.archlinux.org/packages/openconnect-sso/). You can use your
favorite AUR helper to install it:

``` shell
yay -S openconnect-sso
```

### Windows *(EXPERIMENTAL)*

Building from source should work on Windows. Install with the building from source method above and be sure that you have `sudo` and `openconnect`
executable commands in your PATH.

## Usage

If you want to save credentials and get them automatically
injected in the web browser:

```shell
$ openconnect-sso --server vpn.server.com/group --user user@domain.com
Password (user@domain.com):
[info     ] Authenticating to VPN endpoint ...
```

User credentials are automatically saved to the users login keyring (if
available).

If you already have Cisco AnyConnect set-up, then `--server` argument is
optional. Also, the last used `--server` address is saved between sessions so
there is no need to always type in the same arguments:

```shell
$ openconnect-sso
[info     ] Authenticating to VPN endpoint ...
```

Configuration is saved in `$XDG_CONFIG_HOME/openconnect-sso/config.toml`. On
typical Linux installations it is located under
`$HOME/.config/openconnect-sso/config.toml`

For CISCO-VPN and TOTP the following seems to work by tuning the config.toml
and removing the default "submit"-action to the following:

```
[[auto_fill_rules."https://*"]]
selector = "input[data-report-event=Signin_Submit]"
action = "click"

[[auto_fill_rules."https://*"]]
selector = "input[type=tel]"
fill = "totp"
```

### Adding custom `openconnect` arguments

Sometimes you need to add custom `openconnect` arguments. One situation can be if you get similar error messages:

```shell
Failed to read from SSL socket: The transmitted packet is too large (EMSGSIZE).
Failed to recv DPD request (-5)
```

or:

```shell
Detected MTU of 1370 bytes (was 1406)
```

Generally, you can add `openconnect` arguments after the `--` separator. This is called _"positional arguments"_. The
solution of the previous errors is setting `--base-mtu` e.g.:

```shell
openconnect-sso --server vpn.server.com/group --user user@domain.com -- --base-mtu=1370
#                                                          separator ^^|^^^^^^^^^^^^^^^ openconnect args
```

## Development

`openconnect-sso` is developed using [Nix](https://nixos.org/nix/) and [UV](https://docs.astral.sh/uv/) for Python package management. Refer to the
[Quick Start section of the Nix
manual](https://nixos.org/nix/manual/#chap-quick-start) to see how to get it
installed on your machine.

To get dropped into a development environment, just type `nix-shell`:

```shell
$ nix-shell
Sourcing python-catch-conflicts-hook.sh
Sourcing python-remove-bin-bytecode-hook.sh
Sourcing pip-build-hook
Using pipBuildPhase
Sourcing pip-install-hook
Using pipInstallPhase
Sourcing python-imports-check-hook.sh
Using pythonImportsCheckPhase
Run 'make help' for available commands

[nix-shell]$
```

To try an installed version of the package, issue `nix build`:

```shell
$ nix build github:PrestonHager/openconnect-sso
[1 built, 0.0 MiB DL]

$ result/bin/openconnect-sso --help
```

Alternatively you may just [get UV](https://docs.astral.sh/uv/#installation) and
start developing by using the included `Makefile`. Type `make help` to see the
possible make targets.

### Contributing using Fedora

Install these packages for development:

```shell
sudo dnf install python-pip libatomic libxkbfile uv poetry nix
```

### Lock Files

Don't forget to update the lock files when contributing:

```shell
uv lock
poetry lock
nix flake update
```
