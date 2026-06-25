#!/usr/bin/env python3
"""
WHITE-HAT-STOAT Setup Script
"""

from setuptools import setup, find_packages
import os
import sys

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

version = "1.0.0"

setup(
    name="white-hat-stoat",
    version=version,
    author="Advanced Security Framework",
    author_email="security@white-hat-stoat.local",
    description="Advanced Cybersecurity Command & Control Platform",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/white-hat-stoat/white-hat-stoat",
    packages=find_packages(exclude=["tests", "tests.*", "docs", "examples"]),
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Information Technology",
        "Intended Audience :: System Administrators",
        "Topic :: Security",
        "Topic :: System :: Networking :: Monitoring",
        "License :: Other/Proprietary License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.7",
    install_requires=[
        "requests>=2.28.0",
        "psutil>=5.9.0",
        "colorama>=0.4.6",
        "cryptography>=39.0.0",
        "paramiko>=3.0.0",
    ],
    extras_require={
        "dev": [
            "pytest>=7.2.0",
            "pytest-cov>=4.0.0",
            "black>=22.0.0",
            "flake8>=6.0.0",
            "pylint>=2.15.0",
            "mypy>=1.0.0",
            "isort>=5.11.0",
        ],
        "web": [
            "flask>=2.2.0",
            "flask-socketio>=5.3.0",
            "flask-cors>=3.0.10",
            "python-socketio>=5.7.0",
            "eventlet>=0.33.0",
        ],
        "network": [
            "scapy>=2.4.5",
            "python-whois>=0.7.3",
            "nmap-python>=1.0.0",
        ],
        "platforms": [
            "discord.py>=2.0.0",
            "slack-sdk>=3.19.0",
            "python-telegram-bot>=20.0",
            "telethon>=1.28.0",
            "matrix-client>=0.4.0",
            "selenium>=4.8.0",
            "webdriver-manager>=3.9.0",
        ],
        "doc": [
            "reportlab>=3.6.0",
            "python-docx>=0.8.11",
            "pdfkit>=1.0.0",
        ],
        "ml": [
            "scikit-learn>=1.2.0",
            "tensorflow>=2.12.0",
            "torch>=2.0.0",
        ],
        "all": [
            "flask>=2.2.0",
            "flask-socketio>=5.3.0",
            "flask-cors>=3.0.10",
            "scapy>=2.4.5",
            "python-whois>=0.7.3",
            "discord.py>=2.0.0",
            "slack-sdk>=3.19.0",
            "python-telegram-bot>=20.0",
            "telethon>=1.28.0",
            "matrix-client>=0.4.0",
            "selenium>=4.8.0",
            "reportlab>=3.6.0",
            "python-docx>=0.8.11",
            "scikit-learn>=1.2.0",
        ],
    },
    entry_points={
        "console_scripts": [
            "white-hat-stoat=white_hat_stoat:main",
            "stoat-cli=white_hat_stoat:main",
        ],
    },
    include_package_data=True,
    zip_safe=False,
)