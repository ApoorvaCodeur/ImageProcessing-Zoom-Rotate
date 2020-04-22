//This program made by Apoorva Chauhan

//This program is working for PPM (P3) format images
//PPM has RGB values as input data

/* The demo file is as follows..
P3
# The P3 means colors are in ASCII, then 3 columns and 2 rows, then 255 for max color, then RGB triplets-----  THIS COMMENT IS OPTIONAL
3 2
255
255   0   0     0 255   0     0   0 255
255 255   0   255 255 255     0   0   0
*/

#include<cuda.h>
#include<stdio.h>
#include<math.h>
#include<stdlib.h>

	
__global__ void copy( int *a, int *b, int col1, int row1, int col, int row, int factor )
{
        int tx = __umul24(blockIdx.x,blockDim.x) + threadIdx.x;
        int ty = __umul24(blockIdx.y,blockDim.y) + threadIdx.y;
	if(tx<row && ty<col1)
	{
		i1=ty*factor;
		j1=tx*factor;
		b[(i1*col1*3) + (j1*3)] = a[(ty*col*3) + (tx*3)];
		b[(i1*col1*3) + (j1*3 + 1)] = a[(ty*col*3) + (tx*3 + 1)];
		b[(i1*col1*3) + (j1*3 + 2)] = a[(ty*col*3) + (tx*3 + 2)];
	}
}

__global__ void hori_inter( int *a, int *b, float si, float co, int col, int row )
{
	int idx = __umul24(blockIdx.x,blockDim.x) + threadIdx.x;
        int idy = __umul24(blockIdx.y,blockDim.y) + threadIdx.y;
	i1=0;
	while(i1<row1)
	{
		j1=0;
		while(j1<(col1-factor))
		{
			x1 = j1;
			x2 = j1+factor;
			for(j=1;j<factor;j++)
			{
				x = j1+j;
				b[(i1*col1*3) + (x*3)] = ((x2-x)*b[(i1*col1*3) + (x1*3)]/(x2-x1)) + ((x-x1)*b[(i1*col1*3) + (x2*3)]/(x2-x1));
                		b[(i1*col1*3) + (x*3 + 1)] = ((x2-x)*b[(i1*col1*3) + ((x1*3) + 1)]/(x2-x1)) + ((x-x1)*b[(i1*col1*3) + ((x2*3) + 1)]/(x2-x1));
                		b[(i1*col1*3) + (x*3 + 2)] = ((x2-x)*b[(i1*col1*3) + ((x1*3) + 2)]/(x2-x1)) + ((x-x1)*b[(i1*col1*3) + ((x2*3) + 2)]/(x2-x1));
			}
			j1+=factor;
		}
		i1+=factor;
	}
}

__global__ void ver_inter( int *a, int *b, float si, float co, int col, int row )
{
        int idx = __umul24(blockIdx.x,blockDim.x) + threadIdx.x;
        int idy = __umul24(blockIdx.y,blockDim.y) + threadIdx.y;
	i1=0;
        while(i1<(row1-factor))
        {
                x1=i1;
		x2=i1 + factor;       
                for(j=1;j<factor;j++)
                {
                	x = i1+j;
			j1=0;
			while(j1<col1)
			{
                        b[(x*col1*3) + (j1*3)] = ((x1-x)*b[(x2*col1*3) + (j1*3)]/(x1-x2)) + ((x-x2)*b[(x1*col1*3) + (j1*3)]/(x1-x2));
                        b[(x*col1*3) + (j1*3 + 1)] = ((x1-x)*b[(x2*col1*3) + ((j1*3) + 1)]/(x1-x2)) + ((x-x2)*b[(x1*col1*3) + ((j1*3) + 1)]/(x1-x2));
                        b[(x*col1*3) + (j1*3 + 2)] = ((x1-x)*b[(x2*col1*3) + ((j1*3) + 2)]/(x1-x2)) + ((x-x2)*b[(x1*col1*3) + ((j1*3) + 2)]/(x1-x2));
                       	j1++;
			}
		}
                i1+=factor;
        }
}

int main()
{
    FILE *fp,*fp1;
    fp = fopen("blackbuck.ppm","r");
    fp1 = fopen("zoomed_image.ppm","w");
    char c;
    int col=0,row=0,max=0,i=0,j=0;
    float degree=0.0f,co=0.0f,si=0.0f;
    int *a,*b,*a_d,*b_d;
	cudaEvent_t start,stop;
        float time;
    
    //The degree of rotation is entered in radians
	printf("\n\nEnter the degree of rotation\t");
	scanf("%f",&degree);
	    
    if(fp == NULL)
    {
          printf("\nSource File does not exist...");
          exit(1);
    }
    else
    {
        //This step is to skip the image type specified, like P3
        
        c=fgetc(fp);
        fputc(c,fp1);
        c=fgetc(fp);
        fputc(c,fp1);
        c=fgetc(fp);
        fputc(c,fp1);
        
        fscanf(fp,"%d",&col);
        c = fgetc(fp);
        
        //This step is done to skip the statements, if present in comment '#'
        
        while( c == '#')
        {
                fputc(c,fp1);
                c=fgetc(fp);
                fputc(c,fp1);
                while(c != '\n')
                {
                        c=fgetc(fp);
                        fputc(c,fp1);
                }
                fscanf(fp,"%d",&col);
                c=fgetc(fp);
        }
        
        fscanf(fp,"%d",&row);
        fscanf(fp,"%d",&max);        
        fprintf(fp1,"%d",col);
        fprintf(fp1,"%c",' ');
	
	printf("\nEnter the scaling factor :\t");
        scanf("%d",&factor);
        row1 = (factor*row) - (factor-1);
        col1 = (factor*col) - (factor-1);

        fprintf(fp1,"%d",col1);
        fprintf(fp1,"%c",' ');
	fprintf(fp1,"%d",row1);
        fprintf(fp1,"%c",'\n');
        fprintf(fp1,"%d",max);
        fprintf(fp1,"%c",'\n');

	size_t size_a = sizeof(int)*row*col*3;
	size_t size_b = sizeof(int)*row1*col1*3;
	a = (int*)malloc(size_a);
        cudaMalloc( (void**) &a_d, size_a);
        b = (int*)malloc(size_ab);
        cudaMalloc( (void**) &b_d, size_b);
	cudaMemset(b_d,0,size_b);

	printf("\nDegree %f",degree);
	co=cos(degree);
	si=sin(degree);
	printf("\n\n%f  %f\n\n",si,co);
	        
        for(i=0;i<row;i++)
        {
            for(j=0;j< col*3;j++)
            {
                fscanf(fp,"%d",&a[(i*col*3)+j]);
	    }
        }
                
	cudaMemcpy(a_d,a,size_ab,cudaMemcpyHostToDevice);
	
	cudaEventCreate(&start);
 	cudaEventCreate(&stop);
	cudaEventRecord(start,0);
		
	dim3 dimBlock(16,16);
	dim3 dimGrid( ((col-1)/dimBlock.x)+1,((row-1)/dimBlock.y)+1  );
	
	for(i=0;i<10;i++)
	{
	copy<<<dimGrid,dimBlock>>>(a_d,b_d,col1,row1,col,row,factor);
	cudaThreadSynchronize();
	hori_inter<<<dimGrid,dimBlock>>>(a_d,b_d,col1,row1,col,row);
	cudaThreadSynchronize();
	ver_inter<<<dimGrid,dimBlock>>>(a_d,b_d,col1,row1,col,row);
	cudaThreadSynchronize();
	}
	
        printf("\nKernel error : %s", cudaGetErrorString(cudaGetLastError())); 
        cudaEventRecord(stop,0);
        cudaEventSynchronize(stop);
        cudaEventElapsedTime(&time,start,stop);
	
	cudaMemcpy(b,b_d,size_ab,cudaMemcpyDeviceToHost);
	printf("\nMemcpy error : %s", cudaGetErrorString(cudaGetLastError()));	
	for(i=0;i<row;i++)
        {
            for(j=0;j< col*3;j++)
            {         
                fprintf(fp1,"%d",b[(i*col*3)+j]);
                fprintf(fp1,"%c",' ');
            }
            fprintf(fp1,"%c",'\n');
        }
    }

    	printf("\n\nProcessing time is:\t%f (ms)\n\n",time/10);
        cudaEventDestroy(start);
        cudaEventDestroy(stop);
	
	fclose(fp);
    	fclose(fp1);
    	free(a);
    	free(b);
    	cudaFree(a_d);
	cudaFree(b_d);
	return 0;
}		
