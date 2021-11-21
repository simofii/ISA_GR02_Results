#include<stdio.h>
#include<stdlib.h>

#define N 1 /// order of the filter 
#define NB 14  /// number of bits
#define NB_int 5 /// number of bits, if NB_int=14 the implementation isn't reduced

const int b0 = 3447; /// coefficient b0
const int b[N]={ 3447 }; /// b array
const int a[N] = { -1298 }; /// a array

/// Perform fixed point filtering assuming direct form II
///\param x is the new input sample
///\return the new output sample
int myfilter(int x)
{
  static int sw[N]; /// w shift register
  static int first_run = 0; /// for cleaning the shift register
  int i; /// index
  int w; /// intermediate value (w)
  int y; /// output sample
  int fb, ff; /// feed-back and feed-forward results

  int mask = ~((1 << (NB - NB_int)) - 1);
  int mask_constants = mask + 256;

  /// clean the buffer
  if (first_run == 0)
  {
    first_run = 1;
    for (i=0; i<N; i++)
      sw[i] = 0;
  }

  /// compute feed-back and feed-forward
  fb = 0;
  ff = 0;
  for (i=0; i<N; i++)
  {
    fb -= (sw[i] * (a[i] & mask_constants)) >> (NB - 1);
    ff += (sw[i] * (b[i] & mask_constants)) >> (NB - 1);
  }

  /// compute intermediate value (w) and output sample
  w = x + fb;
  w &= mask;
  y = (w * (b0 & mask_constants)) >> (NB - 1);
  y += ff;

  /// update the shift register
  for (i=N-1; i>0; i--)
    sw[i] = sw[i-1];
  sw[0] = w;
 
  return y;
}

int main (int argc, char **argv)
{
  FILE *fp_in;
  FILE *fp_out;

  int x;
  int y;
  float y_f;

  /// check the command line
  if (argc != 3)
  {
    printf("Use: %s <input_file> <output_file>\n", argv[0]);
    exit(1);
  }

  /// open files
  fp_in = fopen(argv[1], "r");
  if (fp_in == NULL)
  {
    printf("Error: cannot open %s\n");
    exit(2);
  }
  fp_out = fopen(argv[2], "w");

  /// get samples and apply filter
  fscanf(fp_in, "%d", &x);
  do{
    y = myfilter(x);

    //convert from q0.13 fixed to floating
    y_f = (float)y / 8192;

    fprintf(fp_out,"%d\n", y);
    fscanf(fp_in, "%d", &x);
  } while (!feof(fp_in));

  fclose(fp_in);
  fclose(fp_out);

  return 0;

}
