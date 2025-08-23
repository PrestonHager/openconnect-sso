{ lib
, openconnect
, python3
, python3Packages
, buildPythonApplication
, substituteAll
, wrapQtAppsHook
}:

buildPythonApplication rec {
  pname = "openconnect-sso";
  version = "0.8.1";
  pyproject = true;
  
  src = lib.cleanSource ../.; 

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  nativeBuildInputs = [ wrapQtAppsHook ];
  propagatedBuildInputs = [ openconnect ] ++ (with python3Packages; [
    attrs
    colorama
    lxml
    keyring
    prompt_toolkit
    pyxdg
    requests
    structlog
    toml
    setuptools
    pysocks
    pyqt5
    pyqtwebengine
    pyotp
  ]);

  dontWrapQtApps = true;
  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  pythonImportsCheck = [ ]; # Disable for now due to Qt setup complexity

  meta = with lib; {
    description = "Wrapper script for OpenConnect supporting Azure AD (SAMLv2) authentication to Cisco SSL-VPNs";
    homepage = "https://github.com/vlaci/openconnect-sso";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
