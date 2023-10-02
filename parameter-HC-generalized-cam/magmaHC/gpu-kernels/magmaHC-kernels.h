#ifndef magmaHC_kernels_h
#define magmaHC_kernels_h
// ============================================================================
// Header file declaring all kernels
//
// Modifications
//    Chiang-Heng Chien  22-10-31:   Initially Created (Copied from other repos)
//
//> (c) LEMS, Brown University
//> Chiang-Heng Chien (chiang-heng_chien@brown.edu)
// ============================================================================
#include <stdio.h>
#include <stdlib.h>
#include <cstdio>
#include <iostream>
#include <iomanip>
#include <cstring>
#include <chrono>

extern "C" {
namespace magmaHCWrapper {

  real_Double_t kernel_HC_Solver_six_lines_6x6(
    magma_int_t N, magma_int_t batchCount, magma_int_t ldda,
    magma_queue_t my_queue,
    magmaFloatComplex** d_startSols_array, magmaFloatComplex** d_Track_array,
    magmaFloatComplex** d_cgesvA_array, magmaFloatComplex** d_cgesvB_array,
    magma_int_t* d_Hx_idx_array, magma_int_t* d_Ht_idx_array,
    magmaFloatComplex_ptr d_phc_coeffs_Hx, magmaFloatComplex_ptr d_phc_coeffs_Ht,
    magma_int_t numOf_phc_coeffs
  );

  real_Double_t kernel_HC_Solver_six_lines_16(
    magma_int_t N, magma_int_t batchCount, magma_int_t ldda,
    magma_queue_t my_queue,
    magmaFloatComplex** d_startSols_array, magmaFloatComplex** d_Track_array,
    magmaFloatComplex** d_cgesvA_array, magmaFloatComplex** d_cgesvB_array,
    magma_int_t* d_Hx_idx_array, magma_int_t* d_Ht_idx_array,
    magmaFloatComplex_ptr d_phc_coeffs_Hx, magmaFloatComplex_ptr d_phc_coeffs_Ht,
    magma_int_t numOf_phc_coeffs
  );

  real_Double_t kernel_HC_Solver_3views_4pts(
    magma_int_t N, magma_int_t batchCount, magma_int_t ldda,
    magma_queue_t my_queue,
    magmaFloatComplex** d_startSols_array, magmaFloatComplex** d_Track_array,
    magmaFloatComplex** d_cgesvA_array, magmaFloatComplex** d_cgesvB_array,
    magma_int_t* d_Hx_idx_array, magma_int_t* d_Ht_idx_array,
    magmaFloatComplex_ptr d_phc_coeffs_Hx, magmaFloatComplex_ptr d_phc_coeffs_Ht,
    magma_int_t numOf_phc_coeffs
  );

}
}

#endif
