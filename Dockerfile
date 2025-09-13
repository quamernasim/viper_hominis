# Start with the NVIDIA CUDA base image
FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04

# Create an app directory inside the container
WORKDIR /app

# Copy the local application code to the container
COPY . /app

# Set environment variables for CUDA
ENV PATH=/usr/local/cuda/bin:$PATH

# Install necessary system dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    tini \
    git \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN curl -o Miniconda3-latest-Linux-x86_64.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x Miniconda3-latest-Linux-x86_64.sh && \
    ./Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    /opt/conda/bin/conda init bash

# Set conda path
ENV PATH=/opt/conda/bin:$PATH

# Create conda environment
RUN conda create -n viperhominis python=3.10 -y

# Install PyTorch with CUDA support
RUN /opt/conda/bin/conda run -n viperhominis \
    pip install torch==1.13.1 torchvision==0.14.1 torchaudio==0.13.1 --index-url https://download.pytorch.org/whl/cu116

# Install project dependencies with verbose output
RUN /opt/conda/bin/conda run -n viperhominis \
    pip install -r requirements.txt || (cat requirements.txt && exit 1)

# Expose the port for the application
EXPOSE 8000

# Copy and configure the custom initialization script
COPY glip.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
