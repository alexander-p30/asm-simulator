FROM i386/ubuntu:bionic

RUN apt-get update && apt-get install -y \
    make \
    gcc \
    nasm

CMD ["/bin/bash"]
