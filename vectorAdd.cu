#include <stdio.h>
#include <cuda.h>
void vectorAdd(double* A, double* B,double* C,int n);
__global__ void vecAddKernel(double* A, double* B, double* C, int n);
int main()	{
 double *h_A, *h_B, *h_C;
 int i;
 long N=10000;
 int size=N*sizeof(double);
 h_A=(double*)malloc(size);
 h_B=(double*)malloc(size);
 h_C=(double*)malloc(size);
 if(h_A==NULL||h_B==NULL||h_C==NULL) 	{
	 printf("malloc failed!");
	 exit(1);
 }
 for(i=0;i<N;i++)	{
 	h_A[i]=i*2;
 	h_B[i]=i*3;
 }
 vectorAdd(h_A,h_B,h_C,N);
 for(i=0;i<10;i++) {
 	printf("h_C[%d] is %f,should be %f\n",i,h_C[i],h_A[i]+h_B[i]);
 }
 return 0;
}

void vectorAdd(double* A, double* B,double* C,int n)	{
	double *d_A=NULL, *d_B=NULL, *d_C=NULL;
	int size=sizeof(double)*n;
	cudaMalloc((void**)&d_A,size);
	cudaMemcpy(d_A,A,size,cudaMemcpyHostToDevice);
	cudaMalloc((void**)&d_B,size);
	cudaMemcpy(d_B,B,size,cudaMemcpyHostToDevice);
	cudaMalloc((void**)&d_C,size);
	if(d_A==NULL||d_B==NULL||d_C==NULL){	
		printf("device allocate memory failed!\n");
	}
//	dim3 dimGrid(65537,65537,65537);//test grid,block size
//	dim3 dimBlock(1026,1024,64);
	vecAddKernel<<<ceil(n/1024.0),1024>>>(d_A,d_B,d_C,n);

	cudaMemcpy(C,d_C,size,cudaMemcpyDeviceToHost);
	cudaFree(d_A);cudaFree(d_B);cudaFree(d_C);
}

__global__ void vecAddKernel(double* A, double* B, double* C, int n)	{
	int i=blockDim.x*blockIdx.x+threadIdx.x;
	if(i<n) {
		C[i]=A[i]+B[i];
	}
}

//add nvcc -arch compute_13 to enable double
/*
Device 0: "Quadro K600"
  CUDA Driver Version / Runtime Version          5.5 / 5.5
  CUDA Capability Major/Minor version number:    3.0
  Total amount of global memory:                 1024 MBytes (1073414144 bytes)
  ( 1) Multiprocessors, (192) CUDA Cores/MP:     192 CUDA Cores
  GPU Clock rate:                                876 MHz (0.88 GHz)
  Memory Clock rate:                             891 Mhz
  Memory Bus Width:                              128-bit
  L2 Cache Size:                                 262144 bytes
  Maximum Texture Dimension Size (x,y,z)         1D=(65536), 2D=(65536, 65536), 3D=(4096, 4096, 4096)
  Maximum Layered 1D Texture Size, (num) layers  1D=(16384), 2048 layers
  Maximum Layered 2D Texture Size, (num) layers  2D=(16384, 16384), 2048 layers
  Total amount of constant memory:               65536 bytes
  Total amount of shared memory per block:       49152 bytes
  Total number of registers available per block: 65536
  Warp size:                                     32
  Maximum number of threads per multiprocessor:  2048
  Maximum number of threads per block:           1024
  Max dimension size of a thread block (x,y,z): (1024, 1024, 64)
  Max dimension size of a grid size    (x,y,z): (2147483647, 65535, 65535)
  Maximum memory pitch:                          2147483647 bytes
  Texture alignment:                             512 bytes
  Concurrent copy and kernel execution:          Yes with 1 copy engine(s)
  Run time limit on kernels:                     Yes
  Integrated GPU sharing Host Memory:            No
  Support host page-locked memory mapping:       Yes
  Alignment requirement for Surfaces:            Yes
  Device has ECC support:                        Disabled
  Device supports Unified Addressing (UVA):      Yes
  Device PCI Bus ID / PCI location ID:           5 / 0
  Compute Mode:
     < Default (multiple host threads can use ::cudaSetDevice() with device simultaneously) >

deviceQuery, CUDA Driver = CUDART, CUDA Driver Version = 5.5, CUDA Runtime Version = 5.5, NumDevs = 1, Device0 = Quadro K600
Result = PASS
*/
