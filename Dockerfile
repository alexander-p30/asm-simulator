FROM i386/ubuntu:latest

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    zsh \
    nasm

CMD ["/bin/zsh"]
