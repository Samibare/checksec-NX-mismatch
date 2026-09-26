#include <stdio.h>
#include <setjmp.h>
#include <string.h>
#include <signal.h>


static sigjmp_buf env;

static void handler(int sig){
  siglongjmp(env, 1);
}

int checkStack(){
  //Move 0xbd to eax if the stack is excutable
  unsigned char stack_code[] = {
    0xb8, 0x32, 0x00, 0x00, 0x00, //mov eax, 0xbd
    0xc3                          //ret
  };

  unsigned char stack_code_location[sizeof(stack_code)];
  
  memcpy(stack_code_location, stack_code, sizeof(stack_code));


  int (*run_stack_code)(void) = (int (*)(void))stack_code;

  return run_stack_code();
}

int main(){
  signal(SIGSEGV, handler);
  signal(SIGILL, handler);

  
  if (sigsetjmp(env, 1) == 0){
    if (checkStack() == 50){
      printf("Stack is executable\n");
      return 0;
    }
  }
  
  printf("Stack is not executable\n");
  return 1;
}



