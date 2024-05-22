# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set environment variables to avoid interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install dependencies
RUN apt-get update -y

# Install git and bash
RUN apt-get install -y git bash curl

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash

# Source the bashrc and run foundryup in the same command using bash
RUN bash -c "source /root/.bashrc"

RUN export PATH="$PATH:/root/.foundry/bin"

RUN /root/.foundry/bin/foundryup

# Set up the command line interface for interaction
CMD ["/bin/bash"]
