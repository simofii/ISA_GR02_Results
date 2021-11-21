#include<stdio.h>
#include<stdlib.h>

#define N 2 /// depth of the delay chain of the IIR filter
#define NB 14  /// number of bits

//COEFFICIENTS IN Q0.13
const int b0 = 3447; /// coefficient b0
const int b1 = 3447; /// coefficient b1
const int a1 = -1298; /// coefficient a1
const int a1_squared = 206; /// coefficient A1 squared

/// Perform fixed point filtering assuming direct form II
///\param x is the new input sample
///\returns the new output sample
int myfilter(int x)
{
  static int sw[N]; /// w shift register
  static int first_run = 0; /// for cleaning the shift register
  static int old_input;

  int i; /// index
  int w; /// intermediate value (w)
  int y; /// output sample
  int fb, ff, ff_temp, wb0, add_v_sx_in1, add_v_sx_in2;

  /// clean the buffer
  if (first_run == 0)
  {
    first_run = 1;
    old_input = 0;
    for (i=0; i<N; i++)
      sw[i] = 0;
  }
  
  add_v_sx_in1 = ((sw[1] * a1_squared) >> (NB - 1));
  add_v_sx_in2 = ((old_input * a1) >> (NB - 1));
  fb = add_v_sx_in1 - add_v_sx_in2;
  ff_temp = old_input - ((sw[1] * a1) >> (NB - 1));
  ff = ((ff_temp * b1) >> (NB - 1));
  w = x + fb;
  wb0 = ((w * b0) >> (NB - 1));
  y = ff + wb0;


  /// update the shift register
  for (i=N-1; i>0; i--)
    sw[i] = sw[i-1];
  sw[0] = w;

  old_input = x;
 
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
