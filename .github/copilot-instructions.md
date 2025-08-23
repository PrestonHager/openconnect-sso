# openconnect-sso Development Instructions

OpenConnect-SSO is a Python-based wrapper script for OpenConnect supporting Azure AD (SAMLv2) authentication to Cisco SSL-VPNs. It uses PyQt6 for the GUI browser component and Poetry for dependency management.

**ALWAYS follow these instructions first** and only fall back to additional search or bash commands when the information here is incomplete or found to be in error.

## Working Effectively

### Development Environment Setup
The project supports two primary development approaches:

#### Option 1: Nix-based Development (Recommended)
- **KNOWN ISSUE**: Nix shell may fail with `pythonForBuild` errors due to poetry2nix compatibility issues with newer Nix versions
- If Nix works: `nix-shell` and then `make help` for available commands
- If Nix fails: Use Option 2 (Poetry-based)

#### Option 2: Poetry-based Development
Prerequisites:
- Install Python 3.8+ (`python3 --version`)
- Install Poetry: `pip install poetry` or `curl -sSL https://install.python-poetry.org | python3 -`
- Install pre-commit: `pip install pre-commit`
- Ensure `make` and `gawk` are available

Setup commands:
1. `export PATH=$HOME/.local/bin:$PATH` (ensure Poetry is in PATH)
2. `make dev PRECOMMIT=n` -- **CRITICAL: Takes 3-5 minutes. NEVER CANCEL. Set timeout to 10+ minutes.**
   - Creates `.venv` virtual environment
   - Installs all dependencies via Poetry
   - **WARNING**: May fail with network timeouts to PyPI - retry if needed
3. Optional: `make dev` (with pre-commit hooks, adds 2-3 minutes)

### Build and Test Commands
- **Build/Install in dev mode**: Handled automatically by `make dev`
- **Run tests**: `make test` -- **CRITICAL: Takes 2-3 minutes. NEVER CANCEL. Set timeout to 10+ minutes.**
  - Uses pytest with async support
  - Tests browser automation and authentication flows
  - **Note**: Some tests may be marked as xfail on non-Linux platforms
- **Code quality checks**: `make check` -- **Takes 1-2 minutes. NEVER CANCEL. Set timeout to 5+ minutes.**
  - Runs pre-commit hooks (flake8, black, trailing whitespace, etc.)
  - Runs full test suite
- **Pre-commit only**: `make pre-commit` -- **Takes 30-60 seconds**

### Running the Application
After successful `make dev`:
1. `source .venv/bin/activate` (activate virtual environment)
2. `openconnect-sso --help` (verify installation)
3. **Full run requires**: VPN server details and will launch PyQt6 browser window
4. **For testing**: Use `openconnect-sso --server example.com --user test@example.com`

## Validation Requirements

### Manual Testing Scenarios
**ALWAYS test these scenarios after making changes:**

1. **Installation validation**:
   - Run `make clean` (takes <1 second)
   - Run `make dev PRECOMMIT=n` -- **NEVER CANCEL: 3-5 minutes minimum**
   - Verify `source .venv/bin/activate && openconnect-sso --help` works
   - Check that help text displays correctly

2. **Code quality validation**:
   - Run `make pre-commit` before any commit -- **NEVER CANCEL: 1-2 minutes**
   - Fix any flake8 or black formatting issues
   - Ensure all pre-commit hooks pass

3. **Test suite validation**:
   - Run `make test` -- **NEVER CANCEL: 2-3 minutes minimum**
   - Verify no new test failures (some tests may be xfail on macOS/Windows)
   - Check that browser tests can initialize PyQt6 environment

4. **Basic functionality test** (when network available):
   - Test command: `openconnect-sso --server test.example.com --user test@example.com --help`
   - Should display help and exit cleanly
   - GUI browser window may attempt to open (requires X11/Wayland)

### Dependencies and Network Issues
- **CRITICAL**: Network timeouts to PyPI are common in containerized/sandboxed environments
- **Workaround**: Retry `make dev` multiple times if pip install timeouts occur
- **Alternative**: Use system Poetry if pip-installed Poetry fails: `apt install python3-poetry` 
- **Qt Dependencies**: Requires PyQt6 and PyQt6-WebEngine (may need system Qt libraries)
- **Common Qt fix**: `sudo apt install libegl1` on Ubuntu systems
- **Import errors**: Package metadata requires full installation via `make dev`

## Common Development Tasks

### Adding New Features
1. Create new modules in `openconnect_sso/` directory
2. Update `pyproject.toml` if adding new dependencies  
3. Add tests in `tests/` directory following existing patterns:
   - Use `@pytest.mark.asyncio` for async tests
   - Use `@pytest.mark.parametrize` for multiple test cases
   - Use `@pytest.mark.xfail` for platform-specific issues
4. Run `make check` to ensure code quality
5. Test with actual VPN connection scenario if possible

### Testing Patterns
- **Unit tests**: Focus on `config.py`, `profile.py` logic
- **Integration tests**: Browser automation with `pytest-asyncio`
- **Mock external services**: Use `pytest-httpserver` for VPN endpoints
- **Platform considerations**: Tests may fail on macOS/Windows (browser display issues)

### CLI Structure Understanding
- **Main entry**: `openconnect_sso.cli:main` (defined in pyproject.toml)
- **Arguments**: Supports `--server`, `--user`, `--profile` and passes args to openconnect
- **Authentication**: Uses PyQt6 WebEngine for SAML browser flows
- **VPN integration**: Spawns openconnect subprocess with retrieved credentials

### Debugging Issues
1. **Import errors**: Check virtual environment activation (`source .venv/bin/activate`)
2. **Qt/PyQt issues**: May need system Qt libraries (`sudo apt install libegl1` on Ubuntu)
3. **Network timeouts**: Retry operations, check network connectivity
4. **Pre-commit failures**: Run `pre-commit run -a` to fix formatting issues

### Configuration Files
- **Main config**: `pyproject.toml` (dependencies, metadata, tool configs)
- **Pre-commit**: `.pre-commit-config.yaml` (code quality tools)
- **Makefile**: Build targets and development workflows
- **Nix files**: `shell.nix`, `default.nix`, `flake.nix` (alternative build system)

## Project Structure

### Key Directories
- `openconnect_sso/`: Main Python package
  - `cli.py`: Command-line interface and argument parsing
  - `app.py`: Main application logic and orchestration
  - `browser/`: PyQt6 WebEngine browser components
    - `browser.py`: Main browser automation class
    - `webengine_process.py`: WebEngine process management
    - `user.js`: JavaScript injection for automation
  - `authenticator.py`: Generic authentication interface
  - `saml_authenticator.py`: SAML-specific authentication logic
  - `config.py`: Configuration and profile management
  - `profile.py`: VPN profile handling
- `tests/`: Test suite (pytest-based)
  - `test_browser.py`: Browser automation tests (async)
  - `test_hostprofile.py`: Configuration tests (parametrized)
- `nix/`: Nix build configuration (alternative to Poetry)
- `.github/workflows/`: CI/CD pipelines (Ubuntu-based testing)

### Important Files
- `pyproject.toml`: Project metadata and dependencies
- `poetry.lock`: Locked dependency versions
- `Makefile`: Development workflow automation
- `README.md`: User documentation and installation instructions

## Timeout Warnings and Timing Expectations

**NEVER CANCEL these commands:**
- `make dev`: 3-5 minutes (dependency installation)
- `make test`: 2-3 minutes (test execution)
- `make check`: 3-4 minutes (tests + linting)
- `poetry install`: 2-4 minutes (when run manually)

**Set explicit timeouts:**
- Build commands: 10+ minutes minimum
- Test commands: 10+ minutes minimum
- Pre-commit setup: 5+ minutes minimum

## Known Issues and Workarounds

1. **Nix shell failures**: Use Poetry-based development instead
   - Error: `attribute 'pythonForBuild' missing` - poetry2nix compatibility issue
2. **PyPI timeouts**: Retry commands multiple times, ensure network connectivity
   - Error: `HTTPSConnectionPool(host='pypi.org', port=443): Read timed out`
3. **Pre-commit installation failures**: Use `PRECOMMIT=n` flag to skip during initial setup
4. **Qt/Display issues in headless environments**: Tests may be marked xfail, this is expected
5. **Poetry not found**: Ensure `$HOME/.local/bin` is in PATH: `export PATH=$HOME/.local/bin:$PATH`
6. **Package metadata errors**: 
   - Error: `No package metadata was found for openconnect-sso`
   - Solution: Complete `make dev` installation is required for imports to work
7. **Network-restricted environments**: 
   - Some functionality requires internet access for dependency installation
   - Consider using system package manager versions if available

## CI/CD Integration

The project uses GitHub Actions with:
- **Test workflow**: Tests on Ubuntu with Python 3.8, 3.9, 3.10
- **Coding style workflow**: Pre-commit hooks via GitHub Actions
- **Dependencies**: Uses `poetry` and `make` for consistent builds

Always run `make check` locally before pushing to ensure CI will pass.