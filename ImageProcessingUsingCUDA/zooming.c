//This program made by Apoorva Chauhan
//
//This program is working for PPM (P3) format images
//PPM has RGB values as input data

/* The sample file is as follows..
P3
# The P3 means colors are in ASCII, then 3 columns and 2 rows, then 255 for max color, then RGB triplets-----  THIS COMMENT IS OPTIONAL
3 2
255
255   0   0     0 255   0     0   0 255
255 255   0   255 255 255     0   0   0
*/

#include<stdio.h>
#include<malloc.h>
#include<math.h>
#include<time.h>
#include<stdlib.h>


int main()
{
    FILE *fp,*fp1;
    fp = fopen("blackbuck.ppm","r");
    fp1 = fopen("zoomed_image.ppm","w");
    char c;
    int n=0,col=0,row=0,max=0,i=0,j=0,factor=0,i1=0,j1=0,row1=0,col1=0;
    int *a,*b;
    clock_t beg,end;
   int x,x1,y1,x2,y2; 
	    
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

	a = (int*)malloc(sizeof(int)*row*col*3);
        b = (int*)malloc(sizeof(int)*row1*col1*3);
        
        for(i=0;i<row;i++)
        {
            for(j=0;j< col*3;j++)
            {
                fscanf(fp,"%d",&a[(i*col*3)+j]);
            }
        }

        beg = clock();

//copy pixel values in the zoomed image
	i=0;
	i1=0;
	while(i<row && i1<row1)
	{
		j=0;
		j1=0;
		while(j<col && j1<col1)
		{
			b[(i1*col1*3) + (j1*3)] = a[(i*col*3) + (j*3)];
			b[(i1*col1*3) + (j1*3 + 1)] = a[(i*col*3) + (j*3 + 1)];
			b[(i1*col1*3) + (j1*3 + 2)] = a[(i*col*3) + (j*3 + 2)];

			j++;
			j1+=factor;

		}
		i++;
		i1+=factor;
	}

//horizotal interpolation

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
//end

//vertical interpolation

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
//end
	
	     
        end = clock();
	
	//writing back the results to the target file

	for(i=0;i<row1;i++)
        {
            for(j=0;j< col1*3;j++)
            {         
                fprintf(fp1,"%d",b[(i*col1*3)+j]);
                fprintf(fp1,"%c",' ');
            }
            fprintf(fp1,"%c",'\n');
        }
    }

    fclose(fp);
    fclose(fp1);
    free(a);
    free(b);
    printf("\nProcessing Time : \t%f msec\n",(((float)(end-beg))/CLOCKS_PER_SEC)*1000);
    printf("\nProgram executed successfully...\nPress any key to exit...");
    return 0;
}
