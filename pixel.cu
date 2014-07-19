#include <stdio.h>
#include <cuda.h>
//be careful the block_size*block_size should not exceed 1024
#define BLOCK_SIZE 32 
__global__ void pictureKernel(float* d_pix,int X, int Y);
int main() {
	float *h_pixin, *h_pixout, *d_pix;
	int x=76,y=62,i;	//2D data size
	int grid_x=x/BLOCK_SIZE,grid_y=y/BLOCK_SIZE;
	int size=x*y*sizeof(float);

	dim3 dim_block(BLOCK_SIZE,BLOCK_SIZE,1);
 	if(x%BLOCK_SIZE) grid_x++;
 	if(y%BLOCK_SIZE) grid_y++;
	dim3 dim_grid(grid_x,grid_y,1);
	printf("grid size is:grid_x=%d,grid_y=%d\n",grid_x,grid_y);

	h_pixin=(float*)malloc(size);
	h_pixout=(float*)malloc(size);
	cudaMalloc((void**) &d_pix,size);

	if(h_pixin==NULL||h_pixout==NULL||d_pix==NULL)	{
		printf("malloc failed!\n");
	}

	for(i=0;i<x*y;i++)	{
		h_pixin[i]=i*1.5;
	}

	cudaMemcpy(d_pix,h_pixin,size,cudaMemcpyHostToDevice);
	pictureKernel<<<dim_grid,dim_block>>>(d_pix,x,y); //after this d_pix changed

  cudaError_t error = cudaGetLastError();
  if(error != cudaSuccess)
  {
    printf("CUDA Error: %s\n", cudaGetErrorString(error));
    return 1;
	}

	cudaMemcpy(h_pixout,d_pix,size,cudaMemcpyDeviceToHost);

	for(i=0;i<x*y;i++)	{
		printf("h_pixin[i]=%f,h_pixout=%f\n",h_pixin[i],h_pixout[i]);
	}
	return 0;
}

__global__ void pictureKernel(float* d_pix,int X, int Y) {
	int thread_x=blockDim.x*blockIdx.x+threadIdx.x;
	int thread_y=blockDim.y*blockIdx.y+threadIdx.y;
//	printf("thread_x=%d,blockDim.x=%d,blockIdx.x=%d,threadIdx=%d\n",thread_x,blockDim.x,blockIdx.x,threadIdx.x);
//	printf("thread_y=%d,blockDim.y=%d,blockIdx.y=%d,threadIdy=%d\n",thread_y,blockDim.y,blockIdx.y,threadIdx.y);
//	use this printf nvcc -arch compute_20 pixel.cu
	if(thread_x<X&&thread_y<Y)	{
		d_pix[thread_y*X+thread_x]*=2;
	}
}
