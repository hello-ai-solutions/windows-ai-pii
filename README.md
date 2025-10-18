# PII Windows CLI

A comprehensive PII (Personally Identifiable Information) detection and protection system with CLI tools, cloud infrastructure, and browser integration.

## Components

- **CLI Tools** - Command-line utilities for PII detection and safe processing
- **AWS Lambda** - Cloud-based PII processing service
- **Browser Extension** - Real-time PII detection in web browsers
- **Terraform Infrastructure** - AWS infrastructure deployment

## Quick Start

### CLI Usage
```bash
./cli/pii-safe <input>
./cli/q-safe.sh
```

### Browser Extension
Load the `browser-extension` directory in your browser's developer mode.

### AWS Deployment
```bash
cd terraform
terraform init
terraform apply
```

## Architecture

- **Proxy Service** - Local proxy for secure PII handling
- **Lambda Function** - Serverless PII processing
- **API Gateway** - RESTful API endpoints
- **Browser Integration** - Client-side PII detection

## Requirements

- Node.js
- AWS CLI configured
- Terraform
- Python 3 (for PTY functionality)

## License

See LICENSE file for details.
