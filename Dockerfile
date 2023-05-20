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
    pip3 install ampy rshell
