#include <stdio.h>
_global_ void mykernel(void){
}
int main(void) {
{
	mykernel<<<1,>>>();
	printf("hello world!\n");
	return 0;
}
return 0;
}
