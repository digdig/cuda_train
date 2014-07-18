#include <stdio.h>
#include <cuda.h>

__global__ void pictureKernel(float* d_pix,int X, int Y);
int main() {
	float *h_pixin, *h_pixout, *d_pix;
	int x=76,y=62,i;
	int size=x*y*sizeof(float);
	dim3 dim_block(16,16,1);
	dim3 dim_grid(ceil(x/16.),ceil(y/16.),1);

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
	pictureKernel<<<dim_grid,dim_block>>>(d_pix,x,y);//after this d_pix changed
	cudaMemcpy(h_pixout,d_pix,size,cudaMemcpyDeviceToHost);
//	printf("gridDim.x=%d,gridDim.y=%d,blockDim.x=%d,blockDim.y=%d\n",gridDim.x,gridDim.y,blockDim.x,blockDim.y);
//these varibles need to access in kernel function
	for(i=0;i<x*y;i++)	{
		printf("h_pixin[i]=%f,h_pixout=%f\n",h_pixin[i],h_pixout[i]);
	}
	return 0;
}

__global__ void pictureKernel(float* d_pix,int X, int Y) {
	int thread_x=blockDim.x*blockIdx.x+threadIdx.x;
	int thread_y=blockDim.y*blockIdx.y+threadIdx.y;
	if(thread_x<X&&thread_y<Y)	{
		d_pix[thread_y*X+thread_x]*=2;
	}
}
