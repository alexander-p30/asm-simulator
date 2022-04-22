#include <stdio.h>

extern int c_entrypoint(char *);

int fsize_in_bytes(char * argv[]) {
  return c_entrypoint(argv[1]);
}

int main(int argc, char * argv[]) {
  if(argc != 2) {
    printf("Erro! Forneca o nome de um arquivo.\n");
    printf("\tEx: ./io teste.txt\n");
    return 1;
  }

  int fsize = fsize_in_bytes(argv);

  printf("=====================\n");
  printf("O arquivo de saida (%s.diss) ocupa %d B.\n", argv[1], fsize);

  return 0;
}
