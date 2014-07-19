#include <stdio.h>
#include <cuda.h>
int main()	{
	int dev_count;
	cudaDeviceProp dev_prop;
	cudaGetDeviceCount(&dev_count);
	printf("the number of cuda device is %d\n",dev_count);
	cudaGetDeviceProperties(&dev_prop,0);
	printf("the number of max threads per block is:%d\n",dev_prop.maxThreadsPerBlock);
	printf("the number of streaming multiprocessors(SM) is:%d\n",dev_prop.multiProcessorCount);
	return 0;
}
