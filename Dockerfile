FROM ubuntu:22.04

RUN export DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386
RUN apt update
RUN apt install -y cargo:i386 git
