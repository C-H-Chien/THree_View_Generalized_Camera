#ifndef dev_eval_indxing_six_lines_6x6_cuh_
#define dev_eval_indxing_six_lines_6x6_cuh_
// ============================================================================
// Device function for evaluating the parallel indexing for the Jacobians Hx, Ht, 
// and the homotopy H of six_lines_6x6 problem
//
// Modifications
//    Chiang-Heng Chien  22-10-31:   Initially created
//    Chiang-Heng Chien  22-11-06:   Rename the problem
//
//> (c) LEMS, Brown University
//> Chiang-Heng Chien (chiang-heng_chien@brown.edu)
// ============================================================================
#include <cstdio>
#include <iostream>
#include <iomanip>
#include <cstring>

// -- cuda included --
#include <cuda_runtime.h>

// -- magma included --
#include "flops.h"
#include "magma_v2.h"
#include "magma_lapack.h"
#include "magma_internal.h"
#undef max
#undef min
#include "magma_templates.h"
#include "sync.cuh"
#undef max
#undef min
#include "shuffle.cuh"
#undef max
#undef min
#include "batched_kernel_param.h"

namespace magmaHCWrapperDP64 {

    //> compute the linear interpolations of parameters of phc
    template<int N, int N_3, int N_4>
    __device__ __inline__ void
    eval_parameter_homotopy(
        const int tx, double t, 
        magmaDoubleComplex *s_phc_coeffs_Hx,
        magmaDoubleComplex *s_phc_coeffs_Ht,
        const magmaDoubleComplex __restrict__ *d_phc_coeffs_Hx,
        const magmaDoubleComplex __restrict__ *d_phc_coeffs_Ht
    )
    {
        // =============================================================================
        //> parameter homotopy of Hx
        //> floor((564+1)/6) = 94
        #pragma unroll
        for (int i = 0; i < 94; i++) {
          s_phc_coeffs_Hx[ tx + i*N ] = d_phc_coeffs_Hx[ tx*4 + i*N_4 ] 
                                      + d_phc_coeffs_Hx[ tx*4 + 1 + i*N_4 ] * t
                                      + (d_phc_coeffs_Hx[ tx*4 + 2 + i*N_4 ] * t) * t
                                      + ((d_phc_coeffs_Hx[ tx*4 + 3 + i*N_4 ] * t) * t) * t;
        }

        // =============================================================================
        //> parameter homotopy of Ht
        //> floor((564+1)/6) = 94
        #pragma unroll
        for (int i = 0; i < 94; i++) {
          s_phc_coeffs_Ht[ tx + i*N ] = d_phc_coeffs_Ht[ tx*3 + i*N_3] 
                                      + d_phc_coeffs_Ht[ tx*3 + 1 + i*N_3 ] * t
                                      + (d_phc_coeffs_Ht[ tx*3 + 2 + i*N_3 ] * t) * t;
        }
    }

    // -- Hx parallel indexing --
    template<int N, int max_terms, int max_parts, int max_terms_parts, int N_max_terms_parts>
    __device__ __inline__ void
    eval_Jacobian_Hx(
        const int tx, magmaDoubleComplex *s_track, magmaDoubleComplex r_cgesvA[N],
        const int* __restrict__ d_Hx_idx, magmaDoubleComplex *s_phc_coeffs )
    {
      //#pragma unroll
      for(int i = 0; i < N; i++) {
        r_cgesvA[i] = MAGMA_Z_ZERO;

        //#pragma unroll
        for(int j = 0; j < max_terms; j++) {
          r_cgesvA[i] += d_Hx_idx[j*max_parts + i*max_terms_parts + tx*N_max_terms_parts] 
                       * s_phc_coeffs[ d_Hx_idx[j*max_parts + 1 + i*max_terms_parts + tx*N_max_terms_parts] ]
                       * s_track[ d_Hx_idx[j*max_parts + 2 + i*max_terms_parts + tx*N_max_terms_parts] ]
                       * s_track[ d_Hx_idx[j*max_parts + 3 + i*max_terms_parts + tx*N_max_terms_parts] ]
                       * s_track[ d_Hx_idx[j*max_parts + 4 + i*max_terms_parts + tx*N_max_terms_parts] ];
        }
      }
    }

    // -- Ht parallel indexing --
    template<int N, int max_terms, int max_parts, int max_terms_parts>
    __device__ __inline__ void
    eval_Jacobian_Ht(
        const int tx, magmaDoubleComplex *s_track, magmaDoubleComplex &r_cgesvB,
        const int* __restrict__ d_Ht_idx, magmaDoubleComplex *s_phc_coeffs)
    {
      r_cgesvB = MAGMA_Z_ZERO;
      //#pragma unroll
      for (int i = 0; i < max_terms; i++) {
        r_cgesvB -= d_Ht_idx[i*max_parts + tx*max_terms_parts] 
                  * s_phc_coeffs[ d_Ht_idx[i*max_parts + 1 + tx*max_terms_parts] ]
                  * s_track[ d_Ht_idx[i*max_parts + 2 + tx*max_terms_parts] ] 
                  * s_track[ d_Ht_idx[i*max_parts + 3 + tx*max_terms_parts] ]
                  * s_track[ d_Ht_idx[i*max_parts + 4 + tx*max_terms_parts] ]
                  * s_track[ d_Ht_idx[i*max_parts + 5 + tx*max_terms_parts] ];
      }
    }

    // -- H parallel indexing --
    template<int N, int max_terms, int max_parts, int max_terms_parts>
    __device__ __inline__ void
    eval_homotopy(
        const int tx, magmaDoubleComplex *s_track, magmaDoubleComplex &r_cgesvB,
        const int* __restrict__ d_Ht_idx, magmaDoubleComplex *s_phc_coeffs)
    {
      r_cgesvB = MAGMA_Z_ZERO;
      //#pragma unroll
      for (int i = 0; i < max_terms; i++) {
        r_cgesvB += d_Ht_idx[i*max_parts + tx*max_terms_parts] 
                  * s_phc_coeffs[ d_Ht_idx[i*max_parts + 1 + tx*max_terms_parts] ]
                  * s_track[ d_Ht_idx[i*max_parts + 2 + tx*max_terms_parts] ] 
                  * s_track[ d_Ht_idx[i*max_parts + 3 + tx*max_terms_parts] ]
                  * s_track[ d_Ht_idx[i*max_parts + 4 + tx*max_terms_parts] ]
                  * s_track[ d_Ht_idx[i*max_parts + 5 + tx*max_terms_parts] ];
      }
    }
}

#endif
