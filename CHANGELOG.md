# Changelog

All notable changes to this project will be documented in this file.

## 1.0.0 (2026-03-26)

### ⚠ BREAKING CHANGES

* Initial Release
* test/helpers_test.go no longer exports AWS S3 helpers; replaced with GCS bucket helpers
* module inputs, provider, examples, and tests  for Google Cloud Storage

- Created package.json for project metadata and semantic release setup.
- Added basic test for GCS bucket creation using Terratest.
- Introduced Go module for test dependencies.
- Implemented helper functions for S3 bucket operations.
- Defined variables for GCS bucket configuration with validation rules.
- Specified Terraform and provider version requirements in versions.tf.

### Features

* add initial Terraform module for GCS bucket management ([d8d2582](https://github.com/subhamay-bhattacharyya-tf/terraform-google-module-template/commit/d8d258215db8bba6e11e597d6955eccfac59ca4c))
* complete GCS module scaffold with GCS-native test helpers and full example outputs ([ae1ddb2](https://github.com/subhamay-bhattacharyya-tf/terraform-google-module-template/commit/ae1ddb204b93a0edbd59eb23d3048b99cc7fa128))
* implement initial GCS bucket module with configuration and example usage ([cfe1839](https://github.com/subhamay-bhattacharyya-tf/terraform-google-module-template/commit/cfe18390020cf34da0174295e6bc6514a0b11391))

## [unreleased]

### 🚀 Features

- [**breaking**] Add initial Terraform module for GCS bucket management
- [**breaking**] Complete GCS module scaffold with GCS-native test helpers and full example outputs
- Implement initial GCS bucket module with configuration and example usage

### 🚜 Refactor

- Simplify GCS bucket test configuration by removing unnecessary nested structure
- Restructure GCS bucket module by removing unnecessary module wrapper and updating output references

### 📚 Documentation

- Update CHANGELOG.md [skip ci]
- Update CHANGELOG.md [skip ci]
- Update CHANGELOG.md [skip ci]

### 🎨 Styling

- Format spacing in GCS bucket example configuration

### ⚙️ Miscellaneous Tasks

- Upgrade Terraform setup action to v4 and format output variable definitions
