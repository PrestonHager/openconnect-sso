{ lib
, openconnect
, python3
, python3Packages
, substituteAll
, wrapQtAppsHook
, pkgs
}:

let
  sources = import ./sources.nix;
  uv2nix = import sources.uv2nix { inherit pkgs; };
  
  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = lib.cleanSource ../.;
  };
  
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };
  
  python = pkgs.python3.override {
    packageOverrides = lib.composeManyExtensions [
      overlay
    ];
  };
  
in python.pkgs.buildPythonApplication {
  pname = "openconnect-sso";
  version = "0.8.1";
  
  src = lib.cleanSource ../.;
  format = "pyproject";
  
  nativeBuildInputs = [ wrapQtAppsHook ];
  propagatedBuildInputs = [ openconnect ];

  dontWrapQtApps = true;
  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  # Override specific packages that need system versions
  postPatch = ''
    # Ensure we use system Qt packages
  '';

  pythonImportsCheck = [ "openconnect_sso" ];

  meta = with lib; {
    description = "Wrapper script for OpenConnect supporting Azure AD (SAMLv2) authentication to Cisco SSL-VPNs";
    homepage = "https://github.com/vlaci/openconnect-sso";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
