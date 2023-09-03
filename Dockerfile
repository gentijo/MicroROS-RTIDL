FROM ubuntu:22.04

RUN apt -y update && \
    apt -y upgrade && \
    apt -y install \
        build-essential \
        antlr \
        python3 pip \
        bison flex \
        emacs nano \
        cmake git \
        gdb gdbserver && \
        python3-antlr4 \
    pip3 install adafruit-ampy rshell \
    pip3 install antlr4-python3-runtime \
    pip3 install TextIO PyGithub
    