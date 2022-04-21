sh: 
		docker build -t ubuntu32 .
		docker run -it --rm -v $$PWD:/app -w /app/ ubuntu32 zsh
