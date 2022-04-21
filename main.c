#include <stdio.h>

int main(int argc, char * argv[]) {
  if(argc != 2) {
    printf("Erro! Forneca o nome de um arquivo.\n");
    printf("\tEx: ./io teste.txt\n");
    return 1;
  }

  extern int c_entrypoint(char *);
  c_entrypoint(argv[1]);

  return 0;
}
