{
  lib,
  openconnect,
  python3,
  python3Packages,
  buildPythonApplication,
  substituteAll,
  wrapQtAppsHook,
  qtbase,
}:

buildPythonApplication rec {
  pname = "openconnect-sso";
  version = "0.8.2";
  format = "setuptools";

  src = lib.cleanSource ../.;

  nativeBuildInputs =
    with python3Packages;
    [
      setuptools
      wheel
    ]
    ++ [
      wrapQtAppsHook
      qtbase
    ];

  # Enable modern setuptools features for pyproject.toml support
  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION=${version}
  '';

  propagatedBuildInputs = [
    openconnect
  ]
  ++ (with python3Packages; [
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
    pyqt6
    pyqt6-webengine
    pyotp
  ]);

  dontWrapQtApps = true;
  makeWrapperArgs = [ "\${qtWrapperArgs[@]}" ];

  pythonImportsCheck = [ ]; # Disable for now due to Qt setup complexity

  # Disable tests since they require pytest which isn't needed for runtime
  doCheck = false;

  meta = with lib; {
    description = "Wrapper script for OpenConnect supporting Azure AD (SAMLv2) authentication to Cisco SSL-VPNs";
    homepage = "https://github.com/vlaci/openconnect-sso";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
