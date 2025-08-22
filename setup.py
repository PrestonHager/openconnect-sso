#!/usr/bin/env python3

from setuptools import setup, find_packages

setup(
    name="openconnect-sso",
    version="0.8.1",
    description="Wrapper script for OpenConnect supporting Azure AD (SAMLv2) authentication to Cisco SSL-VPNs",
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    author="László Vaskó",
    author_email="laszlo.vasko@outlook.com",
    url="https://github.com/vlaci/openconnect-sso",
    license="GPL-3.0-only",
    packages=find_packages(),
    entry_points={
        'console_scripts': [
            'openconnect-sso=openconnect_sso.cli:main',
        ],
    },
    install_requires=[
        "attrs>=18.2",
        "colorama>=0.4",
        "lxml>=4.3",
        "keyring>=21.1,<24.0.0",
        "prompt-toolkit>=3.0.3",
        "pyxdg>=0.26,<0.29",
        "requests>=2.22",
        "structlog>=20.1",
        "toml>=0.10",
        "setuptools>40.0",
        "PySocks>=1.7.1",
        "PyQt6>=6.3.0",
        "PyQt6-WebEngine>=6.3.0",
        "pyotp>=2.7.0",
    ],
    python_requires=">=3.8",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Environment :: X11 Applications :: Qt",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Operating System :: POSIX :: Linux",
        "Topic :: System :: Networking",
    ],
)