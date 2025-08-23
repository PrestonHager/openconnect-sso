{ lib
, openconnect
, python3
, python3Packages
, poetry2nix
, substituteAll
, qt5
}:

poetry2nix.mkPoetryApplication {
  src = lib.cleanSource ../.;
  pyproject = ../pyproject.toml;
  poetrylock = ../poetry.lock;
  python = python3;
  # Ensure poetry-core is available for the build along with Qt wrapper
  nativeBuildInputs = [ qt5.wrapQtAppsHook python3Packages.poetry-core ];
  propagatedBuildInputs = [ openconnect ];

  dontWrapQtApps = true;
  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  preferWheels = false;  # Don't try to fetch wheels from internet

  # Skip dev dependencies to avoid problematic packages like coverage_enable_subprocess
  groups = [ ];  # This excludes dev dependencies

  overrides = [
    poetry2nix.defaultPoetryOverrides
    (
      self: super: {
        # Use nixpkgs versions for all dependencies to avoid fetching issues
        inherit (python3Packages) 
          cryptography pyqt6 pyqt6-sip pyqt6-webengine six more-itertools
          requests urllib3 certifi idna charset-normalizer
          pysocks setuptools wheel;
        
        # Skip problematic dev-only packages
        coverage-enable-subprocess = null;
      }
    )
  ];
}
