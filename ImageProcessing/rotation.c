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
    fp1 = fopen("rotated_image.ppm","w");
    char c;
    int n=0,col=0,row=0,max=0,i=0,j=0,i_temp=0,j_temp=0,xc=0,yc=0;
    double degree=0.0,i_r=0.0,j_r=0.0,co=0.0,si=0.0,factor[9];
    int *a,*b;
    int x1=0,y1=0,x2=0,y2=0;
	clock_t beg,end;
    
    //The degree of rotation is entered in radians
	printf("\n\nEnter the degree of rotation\t");
	scanf("%lf",&degree);
	    
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

	printf("\nDegree %lf",degree);
	co=cos(degree);
	si=sin(degree);
	xc=(row-1)/2;
	yc=(col-1)/2;
	
        a = (int*)malloc(sizeof(int)*row*col*3);
        b = (int*)malloc(sizeof(int)*row*col*3);
        
        for(i=0;i<row;i++)
        {
            for(j=0;j< col*3;j++)
            {
                fscanf(fp,"%d",&a[(i*col*3)+j]);
            }
        }
                
                //this step is done so as to experiment with the RGB values as they have values only 0 or 255
        beg = clock();
	
	//This is the application of transformation matrix to the co-ordinate positions

	for(i=0;i<row;i++)
        {
            for(j=0;j< col;j++)
            {        
           		i_r = co*(i-xc)-si*(j-yc)+xc;
                	j_r = si*(i-xc)+co*(j-yc)+yc;
			i_temp = i_r;
           		j_temp = j_r;
           		if( (i_r-i_temp) > 0.5)
           		    i_temp++;
       		    	if( (j_r-j_temp) > 0.5)
           		    j_temp++;
           		
           		if(i_temp>=0 && i_temp<row && j_temp>=0 && j_temp<col)
			{
			b[(i_temp*col*3) + (j_temp*3)] = a[(i*col*3) + (j*3)];
           		b[(i_temp*col*3) + (j_temp*3 + 1)] = a[(i*col*3) + (j*3 + 1) ];
           		b[(i_temp*col*3) + (j_temp*3 + 2)] = a[(i*col*3) + (j*3 + 2)];
			}
             }
        }
       
        end = clock();
	
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

	
	//writing back the results to the target file

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

    fclose(fp);
    fclose(fp1);
    free(a);
    free(b);
	printf("\nProcessing Time : \t%f\n",((float)(end-beg))/CLOCKS_PER_SEC);
    printf("\nProgram executed successfully...\nPress any key to exit...");
    return 0;
}
