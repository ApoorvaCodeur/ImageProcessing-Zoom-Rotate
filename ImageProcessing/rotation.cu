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

__global__ void rotation( int *a, int *b, float si, float co, int col, int row )
{
	int idx = __umul24(blockIdx.x,blockDim.x) + threadIdx.x;
	int idy = __umul24(blockIdx.y,blockDim.y) + threadIdx.y;
	float i_r=0.0f,j_r=0.0f;
	int i_temp=0,j_temp=0;

	if(idx<col && idy<row)
	{
		i_r = co*(idy-((row-1)/2))-si*(idx-((col-1)/2))+((row-1)/2);
                j_r = si*(idy-((row-1)/2))+co*(idx-((col-1)/2))+((col-1)/2);
                i_temp = i_r;
                j_temp = j_r;
                if( (i_r-i_temp) > 0.5)
        	        i_temp++;
                if( (j_r-j_temp) > 0.5)
                        j_temp++;
				
		if(i_temp < row && i_temp >= 0 && j_temp < col && j_temp >=0)
		{
                        
 b[__umul24(i_temp,__umul24(col,3)) + __umul24(j_temp,3)]       = a[(__umul24(idy,__umul24(col,3))) + __umul24(idx,3)];
 b[__umul24(i_temp,__umul24(col,3)) + (__umul24(j_temp,3) + 1)] = a[__umul24(idy,__umul24(col,3)) + (__umul24(idx,3) + 1)];
 b[__umul24(i_temp,__umul24(col,3)) + (__umul24(j_temp,3) + 2)] = a[__umul24(idy,__umul24(col,3)) + (__umul24(idx,3) + 2)];
		}
	}
}

int main()
{
    FILE *fp,*fp1;
    fp = fopen("blackbuck.ppm","r");
    fp1 = fopen("rotated_image.ppm","w");
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
        fprintf(fp1,"%d",row);
        fprintf(fp1,"%c",'\n');
        fprintf(fp1,"%d",max);
        fprintf(fp1,"%c",'\n');

	size_t size_ab = sizeof(int)*row*col*3;
	a = (int*)malloc(size_ab);
        cudaMalloc( (void**) &a_d, size_ab);
        b = (int*)malloc(size_ab);
        cudaMalloc( (void**) &b_d, size_ab);
	cudaMemset(b_d,0,size_ab);

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
	rotation<<<dimGrid,dimBlock>>>(a_d,b_d,si,co,col,row);
	cudaThreadSynchronize();
	}
        printf("\nKernel error : %s", cudaGetErrorString(cudaGetLastError())); 
        cudaEventRecord(stop,0);
        cudaEventSynchronize(stop);
        cudaEventElapsedTime(&time,start,stop);
	
	cudaMemcpy(b,b_d,size_ab,cudaMemcpyDeviceToHost);
	printf("\nMemcpy error : %s", cudaGetErrorString(cudaGetLastError()));	

    //averaging filter
    
		for(i=0;i<row;i++)
	{
		for(j=0;j<col;j++)
		{
			x1=i-1;
			y1=j-1;
			x2=i+1;
			y2=j+1;
						
			if(i>0 &&i<row-1 && j>0 && j<col-1)
			{
				b[(i*col*3) + (j*3)] = (b[(i*col*3) + (y1*3)]+b[(x2*col*3) + (j*3)]+b[(i*col*3) + (y2*3)]+b[(x1*col*3) + (j*3)])/4;
                b[(i*col*3) + (j*3 + 1)] = (b[(i*col*3) + (y1*3+1)]+b[(x2*col*3) + (j*3+1)]+b[(i*col*3) + (y2*3+1)]+b[(x1*col*3) + (j*3+1)])/4;
                b[(i*col*3) + (j*3 + 2)] =  (b[(i*col*3) + (y1*3+2)]+b[(x2*col*3) + (j*3+2)]+b[(i*col*3) + (y2*3+2)]+b[(x1*col*3) + (j*3+2)])/4;

			}

		}
	}


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
