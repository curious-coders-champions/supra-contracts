# Supra Development Environment Setup Guide

This guide will walk you through setting up your Supra development environment using Docker.

## Prerequisites

- Docker installed and running on your machine
- Windows, macOS, or Linux operating system
- Command line terminal
- At least 2GB of free disk space

## Directory Setup

1. Create a directory for your Supra contracts:

```bash
mkdir supra-contracts
cd supra-contracts
```

## Docker Container Setup

1. Stop and remove any existing Supra container (if it exists):

```bash
docker stop supra_cli
docker rm supra_cli
```

2. Create and run the Supra container with volume mounting:

```bash
docker run --name supra_cli \
  -v /C/Users/your-username/path/to/supra-contracts:/supra/configs/supra-contracts \
  -e SUPRA_HOME=/supra/configs \
  --net=host \
  -itd asia-docker.pkg.dev/supra-devnet-misc/supra-testnet/validator-node:v6.3.0
```

Note: Replace `/C/Users/your-username/path/to/supra-contracts` with your actual path. On Windows, use forward slashes (/) instead of backslashes (\).

## Accessing the Container

1. Enter the container's shell:

```bash
docker exec -it supra_cli bash
```

2. Navigate to your contracts directory inside the container:

```bash
cd /supra/configs/supra-contracts
```

## Setting up Supra CLI

The Supra binary is located at `/supra/supra` in the container. You have three options to use it:

1. Use the full path:

```bash
/supra/supra move tool init --name your-project-name
```

2. Add to PATH (temporary, needs to be done each time you enter the container):

```bash
export PATH=$PATH:/supra
supra move tool init --name your-project-name
```

3. Create a symbolic link (permanent, only needs to be done once):

```bash
ln -s /supra/supra /usr/local/bin/supra
supra move tool init --name your-project-name
```

## Project Initialization

1. Initialize a new Supra Move project:

```bash
/supra/supra move tool init --name your-project-name
```

This will create a `Move.toml` file with the following content:

```toml
[package]
name = "exampleContract"
version = "1.0.0"
authors = []

[addresses]

[dev-addresses]

[dependencies.SupraFramework]
git = "https://github.com/Entropy-Foundation/aptos-core.git"
rev = "dev"
subdir = "aptos-move/framework/supra-framework"

[dev-dependencies]
```

## Volume Mounting Verification

To verify that your volume mounting is working correctly:

1. Create a test file from inside the container:

```bash
touch /supra/configs/supra-contracts/test.txt
```

2. Check if the file appears in your local directory outside the container.

## Common Issues and Solutions

1. **Volume Mounting Issues**

   - Ensure paths use forward slashes (/)
   - Use absolute paths instead of relative paths
   - Check directory permissions

2. **Container Name Conflict**

   - If you see "container name already in use", run the stop and remove commands mentioned above

3. **Command Not Found**
   - Use the full path to the Supra binary (/supra/supra)
   - Or set up the PATH as described in the "Setting up Supra CLI" section

## Next Steps

After setup, you can:

1. Create your Move smart contracts in the mounted directory
2. Use the Supra CLI to compile and deploy your contracts
3. Test your contracts using the provided testing framework

## Additional Resources

- [Supra Documentation](https://docs.supra.com)
- [Move Language Documentation](https://move-book.com)
- [Docker Documentation](https://docs.docker.com)
