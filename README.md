## Image Processing Using CUDA Architecture

###Background
CUDA (Compute Unified Device Architecture) is a parallel computing platform and application programming interface (API) model created by Nvidia. CUDA-enabled graphics processing unit (GPU) can be used for general purpose processing – an approach termed GPGPU (General-Purpose computing on Graphics Processing Units). The CUDA platform is a software layer that gives direct access to the GPU's virtual instruction set and parallel computational elements, for the execution of compute kernels.

###About this project
This program performs image rotation, zooming and shrinking operations efficiently on both CPU (developed using C language) and GPU (using C language + CUDA architecture) on images of high resolution and do a comparative study of the time taken by these operations on both CPU and GPU. Operations were extremely faster in GPU when effectively utilized using CUDA.