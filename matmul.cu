#include <stdio.h>
#include <cuda.h>
#define BLOCK_SIZE 16
__global__ void matmulKernel(float* mat_in1,float* mat_in2, float* mat_out,int mat_dim);

int main()	{
	float *h_M, *h_N, *h_P, *d_M, *d_N, *d_P;
	int i,width=10;
	int size=width*width*sizeof(float);

	dim3 block_dim(BLOCK_SIZE,BLOCK_SIZE,1);
	int grid_size=width/BLOCK_SIZE;
	if(width%BLOCK_SIZE) grid_size++;
	dim3 grid_dim(grid_size,grid_size,1);

	h_M=(float*)malloc(size);
	h_N=(float*)malloc(size);
	h_P=(float*)malloc(size);
	cudaMalloc((void**)&d_M,size);
	cudaMalloc((void**)&d_N,size);
	cudaMalloc((void**)&d_P,size);

	if(h_M==0||h_N==0||h_P==0||d_M==0||d_N==0||d_P==0)	{
		printf("memory locate fail!\n");
	}

	for(i=0;i<width*width;i++)	{
		h_M[i]=1.2*i;
		h_N[i]=1.4*i;
	}

	cudaMemcpy(d_M,h_M,size,cudaMemcpyHostToDevice);
	cudaMemcpy(d_N,h_N,size,cudaMemcpyHostToDevice);
	
	matmulKernel<<<grid_dim,block_dim>>>(d_M,d_N,d_P,width);
	
	cudaMemcpy(h_P,d_P,size,cudaMemcpyDeviceToHost);

	printf("firt row of the results matrix P:\n");
	for(i=0;i<width;i++)	{
		printf("%f,  ",h_P[i]);
	}
	printf("\n");
	printf("the right answer should be:\n");

	for(i=0;i<width;i++)	{
		float sum=0;
		for(int k=0;k<width;k++)	{
			sum+=h_M[k]*h_N[k*width+i];
		}
		printf("%f,  ",sum);
	}
	printf("\n");

	free(h_M);free(h_N);free(h_P);
	cudaFree(d_M);cudaFree(d_N);cudaFree(d_P);
	return 0;
}

__global__ void matmulKernel(float* mat1,float* mat2, float* matP,int dim)	{
	int thread_x,thread_y,i;
	thread_x=blockIdx.x*blockDim.x+threadIdx.x;
	thread_y=blockIdx.y*blockDim.y+threadIdx.y;
	if(thread_x<dim&&thread_y<dim)	{
		float P_value=0.;
		for(i=0;i<dim;i++)	{
			P_value+=mat1[thread_y*dim+i]*mat2[i*dim+thread_x];
		}
		matP[thread_y*dim+thread_x]=P_value;
	}
}
