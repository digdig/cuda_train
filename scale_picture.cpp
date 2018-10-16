
#include <stdlib.h> //for malloc
#include <stdio.h> //for pf and sf

#define BLOCK_DIM 16
#define SCALE_FACTOR 2

__device__ float  *dPixelIn, *dPixelOut;

//const used for pixelIn just to avoid accidental change in kernel code
__global__ void scalePicture(int M, int N)
{
    int row = blockIdx.y* blockDim.y + threadIdx.y; //row is in y direction
    int col = blockIdx.x* blockDim.x + threadIdx.x; //column in x direction
    if( row < M && col < N)
        // each row contains N elements, so skip it for each row to get ith row , jth column element
        pixelOut[row *N + col]=SCALE_FACTOR *pixelIn[row *N + col];
}

int main(void)
{

  float *pixelIn, *pixelOut;

  //Variables to allocate in GPU memory
  
  int M, N, i,j;
  printf("Enter dimension of picture\n");
  scanf("%d%d", &M, &N);
  //allocate in CPU memory
  int size=sizeof(float)*M*N;
  pixelIn=(float *)malloc(size);
  pixelOut=(float*) malloc(size);
  
  //read image pixels from  image file
  // time being using some random values;
  for(i=0; i<M; i++){
   for(j=0; j<N; j++){
     pixelIn[i*N+j]= i*j+1;
     printf("%f ", pixelIn[i*N+j]);}
   printf("\n");
}
    
  cudaMalloc(&dPixelIn,size);
  cudaMalloc(&dPixelOut,size);

  //copy original pixels to GPU
  cudaMemcpy(dPixelIn,pixelIn,size, cudaMemcpyHostToDevice);
  
  //Launch Kernel along x direction as many (columns/ threads per block)
  //Along y direction as many as rows/threads per block
  dim3 gridSize(ceil(N/(float) BLOCK_DIM), ceil(M/(float)BLOCK_DIM )), blockSize(BLOCK_DIM,BLOCK_DIM);
  
  scalePicture<<<gridSize,blockSize >>>( M, N);
  cudaMemcpy(pixelOut,dPixelOut,size, cudaMemcpyDeviceToHost);
  
     
  printf("New scaled picture with scale factor %d  is \n", SCALE_FACTOR);

  for(i=0; i<M; i++){
   for(j=0; j<N; j++)
     printf("%f ", pixelOut[i*N+j]);
   printf("\n");
   }
   free(pixelIn);
   free(pixelOut);
   cudaFree(dPixelIn);
   cudaFree(dPixelOut);
   return 0;
}

