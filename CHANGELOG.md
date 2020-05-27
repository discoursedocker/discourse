# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- This changelog
- docker-compose-kubernetes.yml file to deploy discourse to a Kubernetes cluster
- PGDATA env var to config/default/postgres.env

### Changed
- BREAKING CHANGE: Moved postgresql data to a subdirectory to avoid issues with root volumes. Move data from root path to the "discourse" subdirectory in the postgresql directory

## [2.4.3] - 2020-05-23
### Added
- First Version
