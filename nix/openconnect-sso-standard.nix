{ lib
, buildPythonApplication
, openconnect
, python3Packages
, wrapQtAppsHook
}:

buildPythonApplication rec {
  pname = "openconnect-sso";
  version = "0.8.1";

  src = lib.cleanSource ../.;

  nativeBuildInputs = [ wrapQtAppsHook ];
  
  propagatedBuildInputs = with python3Packages; [
    openconnect
    attrs
    colorama
    lxml
    keyring
    prompt-toolkit
    pyxdg
    requests
    structlog
    toml
    setuptools
    pysocks
    pyqt6
    pyqt6-webengine
    pyotp
  ];

  dontWrapQtApps = true;
  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  # Skip tests as they would require additional setup
  doCheck = false;

  meta = with lib; {
    description = "Wrapper script for OpenConnect supporting Azure AD (SAMLv2) authentication to Cisco SSL-VPNs";
    homepage = "https://github.com/vlaci/openconnect-sso";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}