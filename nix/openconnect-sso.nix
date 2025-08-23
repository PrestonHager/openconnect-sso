{ lib
, openconnect
, python3
, python3Packages
, poetry2nix
, substituteAll
, wrapQtAppsHook
}:

poetry2nix.mkPoetryApplication {
  src = lib.cleanSource ../.;
  pyproject = ../pyproject.toml;
  poetrylock = ../poetry.lock;
  python = python3;
  nativeBuildInputs = [ wrapQtAppsHook ];
  propagatedBuildInputs = [ openconnect ];

  dontWrapQtApps = true;
  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  preferWheels = false;  # Don't try to fetch wheels from internet

  overrides = [
    poetry2nix.defaultPoetryOverrides
    (
      self: super: {
        # Use nixpkgs versions for all dependencies to avoid fetching issues
        inherit (python3Packages) 
          cryptography pyqt6 pyqt6-sip pyqt6-webengine six more-itertools
          requests urllib3 certifi idna charset-normalizer
          pysocks setuptools wheel;
      }
    )
  ];
}
