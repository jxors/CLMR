FROM rocm/pytorch:rocm7.0.2_ubuntu22.04_py3.10_pytorch_release_2.5.1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv git build-essential \
        libsndfile1 ffmpeg libsox-dev vim && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip wheel

# We can't use requirements.txt since pip will install incompatible versions.

WORKDIR /workspace
RUN git clone --recursive https://github.com/pytorch/audio.git
WORKDIR /workspace/audio
RUN git checkout v2.5.1
RUN pip install numpy
RUN apt-get update && apt-get install -y cmake ninja-build
RUN USE_ROCM=1 ROCM_HOME=/opt/rocm PYTORCH_ROCM_ARCH="gfx1032;gfx1030;gfx908" pip install --no-build-isolation .
# TODO: Delete /workspace/audio

RUN pip3 install julius wavaugment torch-pitch-shift
# TODO: torchtext soundfile

WORKDIR /workspace
RUN git clone https://github.com/Spijkervet/torchaudio-augmentations
WORKDIR /workspace/torchaudio-augmentations
RUN pip install --no-deps .

WORKDIR /workspace
RUN git clone https://github.com/spijkervet/SimCLR
WORKDIR /workspace/SimCLR
RUN pip install --no-deps --no-build-isolation .

RUN pip install pytorch-lightning scikit-learn matplotlib

WORKDIR /workspace
RUN git clone --recursive https://github.com/pytorch/text.git
WORKDIR /workspace/text
RUN pip install --no-build-isolation .

WORKDIR /workspace
RUN git clone --recursive https://github.com/pytorch/vision.git
WORKDIR /workspace/vision

RUN git checkout v0.20.0
# Need FORCE_CUDA=1, otherwise we will get build errors
RUN FORCE_CUDA=1 pip install --no-build-isolation .

RUN pip install tensorboard tensorboardX

COPY . /workspace/CLMR
WORKDIR /workspace/CLMR

ENTRYPOINT [ "/bin/bash" ]