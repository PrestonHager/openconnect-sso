# Nix Build Configuration

This directory contains the Nix build configuration for openconnect-sso.

## Build Approaches

### Current: Standard Python Derivation (`openconnect-sso-standard.nix`)

The current implementation uses `buildPythonApplication` from nixpkgs instead of poetry2nix. This approach:

- ✅ **Reliable**: Works consistently across different nixpkgs versions
- ✅ **Compatible**: No dependency on specific poetry2nix versions  
- ✅ **Simple**: Uses standard Python packaging tools
- ✅ **Maintainable**: Easier to debug and maintain

### Alternative: Poetry2nix Integration (`openconnect-sso.nix`)

The repository also includes a poetry2nix-based configuration for users who prefer the Poetry ecosystem:

- ⚠️ **Version Sensitive**: Requires compatible poetry2nix and nixpkgs versions
- ⚠️ **Complex Dependencies**: Poetry backend requires full Poetry installation
- ⚠️ **Build Issues**: Current poetry2nix v1.41.0 has compatibility issues with newer nixpkgs

## Why Standard Python Derivation?

After extensive testing and user feedback, the standard Python derivation approach was chosen because:

1. **Stability**: Poetry2nix versions often lag behind nixpkgs updates, causing build failures
2. **Compatibility**: The `pythonForBuild` attribute required by poetry2nix v1.41.0 is missing in current nixpkgs
3. **Reliability**: Users reported dependency resolution issues with poetry2nix
4. **Simplicity**: Standard Python packaging works out of the box

## Files

- `default.nix` - Main entry point, exports package and development shell
- `openconnect-sso-standard.nix` - Standard Python derivation (currently used)
- `openconnect-sso.nix` - Poetry2nix derivation (available but not used)
- `sources.json` - Pinned dependencies managed by niv
- `sources.nix` - Niv-generated source fetching functions

## Usage

```bash
# Build the package
nix-build

# Enter development shell
nix-shell

# Using flakes
nix build
nix develop
```

## Future Improvements

When poetry2nix compatibility improves, the build could be switched back to the Poetry-based approach by:

1. Updating `sources.json` to use a compatible poetry2nix version
2. Modifying `default.nix` to use `./openconnect-sso.nix` instead
3. Testing with current dependencies

The overlay.nix already provides the infrastructure for poetry2nix integration when needed.