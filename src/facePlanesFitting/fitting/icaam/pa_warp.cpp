//
// Mex-file.
//
// warped_app = pa_warp(AAM, src_shape, image_data, [dst_shape])
//
// Warps the portion of image_data delimited by src_shape to
// dst_shape (which by default is is the mean shape) using a piecewise affine warp.
//
//                         PARAMETERS
//
// AAM Active Appearance Models structure returned by build_model_2d
//
// src_shape A Nx2 matrix containing N landmarks over image_data,
//            in image coordinates: [i j]. Can be single or double
//            precision float.
//
// image_data A HxWxC image matrix, with pixels arranged such
//            that app_data(i,j,c) actually returns the pixel value
//            associated with position (i,j). Must be in the same floating point
//            format as src_shape.
//
// dst_shape (Optional) A Nx2 matrix containing N landmarks over image_data,
//            in image coordinates: [i j]. If omitted, it
//						is assumed to be the base shape (AAM.s0), and an optimized method
//            will be used. Must be in the same floating point
//            format as src_shape.
//
//
//                        RETURN VALUE
//
// warped_app The warped appearance, may be nonzero only over the region
//            delimited by the destination shape. It is stored in the same format
//            as src_shape.
//
//                          THROWS
//
// Attempts to throw a MATLAB exception if the warp is not possible because of incorrect data types
// or shapes lying outside the image (even if partially).
//
//                        LIMITATIONS
//
// For efficiency purposes, not all possible errors are checked, and failure in using the correct datatypes or using
// incompatible training data will most likely cause a MATLAB crash.
// Efficiency could still be improved I guess. Using SIMD instructions, for example (is that even possible in a MEX-file?).
//
// Author: Luca Vezzaro (elvezzaro@gmail.com)

#if defined(DONT_HAVE_MWSIZE)
	typedef int mwSize;
#endif

#if defined(_MSC_VER)
		typedef unsigned __int32 uint32;
#else
		// TODO: Couldn't find a recent platform where sizeof(unsigned int) != 4
		typedef unsigned int uint32;
#endif

#include "mex.h"

// Recent, pretty much standard-compliant compiler
#if defined(__cplusplus) && (defined(__GNUC__) || (defined(_MSC_VER) && _MSC_VER >= 1400))
	#include <cmath>
	#include <cstring>
	using namespace std;

		// Check size of unsigned int
		template <int sof>
		struct __check_uint32_size
		{
				__check_uint32_size(); // generate link error
		};

		template <>
		struct __check_uint32_size<4>
		{
		};

		__check_uint32_size<sizeof(uint32)> __check_uint32_size_instance;

// Old, unknown, or C compiler
#else
	#include <math.h>
	#include <string.h>
#endif

// Allow use of a C compiler (eg. LCC) as a last-resort measure
#if !defined(__cplusplus)
		// Work-around, as there's no way to replace a C++ style cast with a C-style castusing a macro,
		// and this is as closest as we can get in terms of syntax
		#define STATIC_CAST(type) (type)
		#define REINTERPRET_CAST(type) (type)
		#define CONST_CAST(type) (type)
#else
		#define STATIC_CAST(type) static_cast<type>
		#define REINTERPRET_CAST(type) reinterpret_cast<type>
		#define CONST_CAST(type) const_cast<type>
#endif

// Static information used to manage the persistent data
static mxArray* warped_app = NULL;
static size_t warped_app_size = 0;

void at_exit(void)
{
	// This important function is responsible for handling the persistent
	// data
	if(warped_app != NULL)
			mxDestroyArray(warped_app);

	warped_app = NULL;
	warped_app_size = 0;
}

// INTERP is true if the warp uses bilinear interpolation, false otherwise

#if defined(__cplusplus)
	// All is good and well
	template <typename T, bool INTERP>
#else
	// Allow use of a C compiler (eg. LCC) as a last-resort measure
	// Since we can't use templates in C, let's hope MATLAB will keep using double as a default type
	typedef double T;
	const unsigned int INTERP = 0;
#endif
mxArray* pa_warp(const mxArray* src_shape, const mxArray* image_data, const mxArray* shape_mesh, const mxArray* warp_map, const mxArray* alpha_coords, const mxArray* beta_coords, const mxArray* dst_shape)
{
	// Number of landmarks in shapes
	const uint32 np = mxGetM(src_shape);

	// Number of triangles in shape mesh
	const uint32 nt = mxGetM(shape_mesh);

	// Size of image data
	const mwSize* image_size = mxGetDimensions(image_data);
	const mwSize image_dims = mxGetNumberOfDimensions(image_data);

	// Width, height and number of colors of image
	const uint32 imageh = image_size[0];
	const uint32 imagew = image_size[1];

	const uint32 nc = (image_dims > 2) ? image_size[2] : 1;

	// 'Corners' of destination shape, used to allocate
	// images and to improve performance.
	// NOTE: matrices indices in C do not start at 1,
	// but these values actually follow the Matlab convention
	// (so mini and minj cannot be 0).
	uint32 mini;
	uint32 minj;

	uint32 maxi;
	uint32 maxj;

	// Pointer to triangle mesh
	const uint32 *raw_shape_mesh = REINTERPRET_CAST(uint32*)(mxGetData(shape_mesh));

#if !defined(DONT_HAVE_MEXCEPTION)
	unsigned int warning_issued = 0;
#endif

	// If destination shape is not the mean shape, compute the necessary information
	// for warping
	if(dst_shape != NULL)
	{
		// Pointer to destination shape
		const T* raw_dst_shape = REINTERPRET_CAST(const T*)(mxGetData(dst_shape));

		// Initialize temporary min and max variables to the
		// value of the first landmark in the shape
		T fmini = raw_dst_shape[0];
		T fmaxi = raw_dst_shape[0];

		// Column-major storage. The second column
		// in a npx2 matrix is simply offseted by np
		T fminj = raw_dst_shape[np];
		T fmaxj = raw_dst_shape[np];

		// Ouch, up-front declarations!
		// These are a necessary evil if we want to be able to use an old-fashioned C
		// compiler like LCC

		mwSize dims[2];

		mxArray* wmap = 0;
		mxArray* alphas = 0;
		mxArray* betas = 0;
		uint32* raw_wmap = 0;
		T* raw_alphas = 0;
		T* raw_betas = 0;

		// Don't litter the scope with useless variables, and keep the for
		// syntax similar to the C++ one
		{
			uint32 k = 1;
			// Find floating point value of the 'corners'
			for(; k < np; ++k)
			{
				const uint32 kj = k + np;

				if(raw_dst_shape[k] > fmaxi)
					fmaxi = raw_dst_shape[k];

				if(raw_dst_shape[k] < fmini)
					fmini = raw_dst_shape[k];

				if(raw_dst_shape[kj] > fmaxj)
					fmaxj = raw_dst_shape[kj];

				if(raw_dst_shape[kj] < fminj)
					fminj = raw_dst_shape[kj];
			}
		}

		// Store the integer bounds of the floating point
		// corners
		mini = STATIC_CAST(uint32)(floor(fmini));
		minj = STATIC_CAST(uint32)(floor(fminj));

		maxi = STATIC_CAST(uint32)(ceil(fmaxi));
		maxj = STATIC_CAST(uint32)(ceil(fmaxj));

		// Dimensions for the various bitmaps
		dims[0] = maxi;
		dims[1] = maxj;

		// Bitmap mapping pixels to the triangle they belong to (the triangle used
		// for warping). Indices again follow the Matlab, so they start at 1.
		wmap = mxCreateNumericArray(2, dims, mxUINT32_CLASS, mxREAL);

		// Bitmap containing the first barycentric coordinate of each pixel wrt to the
		// triangle specified by wmap
		alphas = mxCreateNumericArray(2, dims, mxGetClassID(src_shape), mxREAL);

		// Bitmap containing the second barycentric coordinate of each pixel wrt to the
		// triangle specified by wmap
		betas = mxCreateNumericArray(2, dims, mxGetClassID(src_shape), mxREAL);

		// Raw pointers to bitmaps
		raw_wmap = REINTERPRET_CAST(uint32*)(mxGetData(wmap));
		raw_alphas = REINTERPRET_CAST(T*)(mxGetData(alphas));
		raw_betas = REINTERPRET_CAST(T*)(mxGetData(betas));

		// We need to be able to unanbigously determine when we are outside
		// the shape in a bitmap, and this is the easiest way to do it.
		memset(raw_wmap, 0, sizeof(uint32) * maxi * maxj);

		// Don't litter the scope with useless variables, and keep the for
		// syntax similar to the C++ one
		{
			uint32 j = minj;
			// For each pixel, find the triangle it belongs to.
			for(; j <= maxj; ++j)
			{
				uint32 i = mini;
				for(; i <= maxi; ++i)
				{
					uint32 k = 0;
					for(; k < nt; ++k)
					{
						// Index to first vertex in triangle 'k', converted to C
						// convention
						uint32 v = raw_shape_mesh[k] - 1;

						// Coordinates of first vertex of the destination shape
						const T i1 = raw_dst_shape[v];
						const T j1 = raw_dst_shape[v + np];

						// Up-front declarations again, yay!
						T i2;
						T j2;

						T i3;
						T j3;

						// Index to second vertex in triangle 'k', converted to C
						// convention
						v = raw_shape_mesh[k + nt] - 1;

						// Coordinates of second vertex of the destination shape
						i2 = raw_dst_shape[v];
						j2 = raw_dst_shape[v + np];

						// Index to third vertex in triangle 'k', converted to C
						// convention
						v = raw_shape_mesh[k + 2 * nt] - 1;

						// Coordinates of third vertex of the destination shape
						i3 = raw_dst_shape[v];
						j3 = raw_dst_shape[v + np];

						{
							// Compute the barycentric coordinates
							const T inv_den = 1 / ((i2 - i1) * (j3 - j1) - (j2 - j1) * (i3 - i1));
							const T alpha = ((i - i1) * (j3 - j1) - (j - j1) * (i3 - i1)) * inv_den;
							const T beta = ((j - j1) * (i2 - i1) - (i - i1) * (j2 - j1)) * inv_den;

							if(alpha >= 0.0 && beta >= 0.0 && (alpha + beta) <= 1.0)
							{
								// The point (i,j) is inside the triangle. Update the
								// bitmaps and proceed to the next point.
								// Note the index is converted to C convention, and
								// the i coordinate is along rows on the bitmaps, while
								// the j coordinate is along columns.
								const uint32 index = (i - 1) + (j - 1) * maxi;
								raw_wmap[index] = k + 1;
								raw_alphas[index] = alpha;
								raw_betas[index] = beta;

								break;
							}
						}
					}
				}
			}
		}

		// Now the warp can be performed efficiently, using the same kind of information that is
		// determined for the mean shape in the training phase
		warp_map = wmap;
		alpha_coords = alphas;
		beta_coords = betas;
	}
	else
	{
		// Only set the corners to be the corners of the model.
		mini = 1;
		minj = 1;
		maxi = mxGetM(warp_map);
		maxj = mxGetN(warp_map);
	}

	// New declarations needed here, thank god that C allows new declaration at
	// the beginning of a new block!
	{
		// Manage the allocation of the persistent array for the
		// return value

		// Size of the appearance to be returned
		const size_t result_size = maxi * maxj * nc * sizeof(T);

		// The size of the current appearance is not compatible, allocate a new one
		// NOTE: Unlike what it may seems, avoiding to allocate an array at each call
		// is not a performance boost. So either MATLAB has a memory pool for handling
		// mxCreateNumericArray, or a new array is created anyways after the MEX file
		// has returned.
		if(warped_app_size != result_size)
		{
			T* raw_warped_app = 0;

			mwSize dims[3];

			dims[0] = maxi;
			dims[1] = maxj;
			dims[2] = nc;

			if(warped_app != NULL)
				mxDestroyArray(warped_app);

			warped_app_size = result_size;

			// Create the result image, size will be at most the same as the destination shape

			warped_app = mxCreateNumericArray(3, dims, mxGetClassID(image_data), mxREAL);
			mexMakeArrayPersistent(warped_app);

			raw_warped_app = REINTERPRET_CAST(T*)(mxGetData(warped_app));

			// Black background for the destination image
			memset(raw_warped_app, 0, result_size);
		}

		// Another new block as we'll need a lot of declarations
		{
			// Raw pointers to all matrices we'll be using later
			const uint32* raw_warp_map = REINTERPRET_CAST(const uint32*)(mxGetData(warp_map));
			const T* raw_src_shape = REINTERPRET_CAST(const T*)(mxGetData(src_shape));
			const T* raw_alpha_coords = REINTERPRET_CAST(const T*)(mxGetData(alpha_coords));
			const T* raw_beta_coords = REINTERPRET_CAST(const T*)(mxGetData(beta_coords));
			const T* raw_image_data = REINTERPRET_CAST(const T*)(mxGetData(image_data));
			T* raw_warped_app = REINTERPRET_CAST(T*)(mxGetData(warped_app));

			// Iterate over the destination pixels and
			// compute the inverse warp from the source shape
			// to avoid gaps and seams in the warped image
			uint32 j = minj;
			for(; j <= maxj; ++j)
			{
				uint32 i = mini;
				for(; i <= maxi; ++i)
				{
					// Index for the bitmaps, note again the conversion from
					// matlab indices to C convention
					const uint32 index = (i - 1) + (j - 1) * maxi;

					// Get triangle to use for warping. Indices in warp_map again
					// follow the matlab convention, so there is a -1
					const int t = STATIC_CAST(int)(raw_warp_map[index]) - 1;

					// Triangle exist, if it doesn't the pixel isn't inside the
					// destination shape
					if(t >= 0)
					{
						// Index of first vertex of the triangle,
						// in matlab convention
						uint32 v = raw_shape_mesh[t] - 1;

						// Coordinates of first vertex of the source shape
						const T i1 = raw_src_shape[v];
						const T j1 = raw_src_shape[v + np];

						// Up-front declarations, don't touch or the God of C90
						// will smite us all.
						T i2;
						T j2;

						T i3;
						T j3;

						T wi;
						T wj;

						// Index of second vertex of the triangle,
						// in matlab convention
						v = raw_shape_mesh[t + nt] - 1;

						// Coordinates of second vertex of the source shape
						i2 = raw_src_shape[v];
						j2 = raw_src_shape[v + np];

						// Index of third vertex of the triangle,
						// in matlab convention
						v = raw_shape_mesh[t + 2 * nt] - 1;

						// Coordinates of third vertex of the source shape
						i3 = raw_src_shape[v];
						j3 = raw_src_shape[v + np];

						// Warp: use the barycentric coordinates computed over the destination shape to
						// find the corresponding pixel on the source shape
						wi = i1 + raw_alpha_coords[index] * (i2 - i1) + raw_beta_coords[index] * (i3 - i1);
						wj = j1 + raw_alpha_coords[index] * (j2 - j1) + raw_beta_coords[index] * (j3 - j1);

						// Check if outside the spape and throw an exception if we are.
						// This is kinda of a hack, but it's the only fast way to know if there
						// is something wrong with the shapes.
						if(wi < STATIC_CAST(T)(1) ||
							 wj < STATIC_CAST(T)(1) ||
							 wi > STATIC_CAST(T)(imageh) ||
							 wj > STATIC_CAST(T)(imagew))
						{
#if !defined(DONT_HAVE_MEXCEPTION)
							int success = -1;
														
							if(dst_shape != NULL)
							{
								// Before throwing exception, deallocate arrays that were created previously
								mxDestroyArray(CONST_CAST(mxArray*)(warp_map));
								mxDestroyArray(CONST_CAST(mxArray*)(alpha_coords));
								mxDestroyArray(CONST_CAST(mxArray*)(beta_coords));
							}

							success = mexEvalString("throw (MException('AAM:WARPERR', 'pa_warp: access to out-of-image pixel. Warp aborted.'))");
							
							if(success != 0)
							{
								mexErrMsgTxt("pa_warp: access to out-of-image pixel. Warp aborted.");
								return warped_app;
							}
#else
							// Iterate over each color
							uint32 c = 0;
							for(; c < nc; ++c)
							{
								raw_warped_app[i - 1 + maxi * (j - 1) + maxi * maxj * c] = 0;
							}

							if(!warning_issued)
							{
								mexWarnMsgTxt("pa_warp: access to out-of-image pixel. Warped value set to zero.");
								warning_issued = 1;
							}
							continue;
#endif
						}

						wi = wi - 1;
						wj = wj - 1;

						// New block, new declarations! I think by now I made it clear, no more idiotic comments...
						{
							// Find the pixels to interpolate
							// o ------- > j
							// | ll |    |
							// |----|----|
							// |    | ur |
							// v --------
							// i
							const uint32 lli = STATIC_CAST(uint32)(floor(wi));
							const uint32 llj = STATIC_CAST(uint32)(floor(wj));
							const uint32 uri = lli + 1;
							const uint32 urj = llj + 1;

							const T f0 = (uri - wi) * (urj - wj);
							const T f1 = (wi - lli) * (urj - wj);
							const T f2 = (uri - wi) * (wj - llj);
							const T f3 = (wi - lli) * (wj - llj);

							// Iterate over each color
							uint32 c = 0;
							for(; c < nc; ++c)
							{
								// Offset in the image data given by color. As it can be seen,
								// each color channel is stored in colum-wise order so it's very easy
								// to access.
								const uint32 offset = imagew * imageh * c;

								if(INTERP)
								{
									// Again, as before all indices here need to be decremented before using them
									// on the C arrays
									T interpolated = raw_image_data[lli + imageh * (llj) + offset] * f0 +
																	 raw_image_data[uri + imageh * (llj) + offset] * f1 +
																	 raw_image_data[lli + imageh * (urj) + offset] * f2 +
																	 raw_image_data[uri + imageh * (urj) + offset] * f3;


									raw_warped_app[i - 1 + maxi * (j - 1) + maxi * maxj * c] = interpolated;
								}
								else
								{
									// Nearest-neighbor interpolation, use this instead of the bilinear interpolation if you're really craving for performance,
									// in case of reversed warp (from mean shape to arbitrary shape), this is necessary to avoid creating a black border around
									// the warped data
									raw_warped_app[i - 1 + maxi * (j - 1) + maxi * maxj * c] = raw_image_data[STATIC_CAST(uint32)(wi) + imageh * (STATIC_CAST(uint32)(wj)) + offset];

								}
							}
						}
					}
				}
			}
		}

		// If we allocated ourselves these support arrays, free their memory
		if(dst_shape != NULL)
		{
			mxDestroyArray(CONST_CAST(mxArray*)(warp_map));
			mxDestroyArray(CONST_CAST(mxArray*)(alpha_coords));
			mxDestroyArray(CONST_CAST(mxArray*)(beta_coords));
		}
	}

	return warped_app;
}

#if defined(__cplusplus)
extern "C" {
#endif

	void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
	{
		// Prototype: warped_app = pa_warp(AAM, src_shape, image_data, <dst_shape>)

		// NOTE: error checking kept to a minimum to avoide excessive overhead.
		// There's no point making a mex-file if it's not fast, after all.

		// Keep these here, else we'll make C compilers sad
		const mxArray* shape_mesh = 0;
		mxClassID class_id;

		mexAtExit(&at_exit);

		if(nlhs == 0)
			mexErrMsgTxt("pa_warp: you need to specify an output parameter.");

		shape_mesh = mxGetField(prhs[0], 0, "shape_mesh");

		if(shape_mesh == NULL || mxGetClassID(shape_mesh) != mxUINT32_CLASS)
			mexErrMsgTxt("pa_warp: AAM.warp_map must be present and must be of class 'uint32'.");

		class_id = mxGetClassID(prhs[1]);

		if(mxGetClassID(prhs[2]) != class_id)
			mexErrMsgTxt("pa_warp: image_data must be in the same floating point format as the other data.");

		// No destination shape: warp from source shape to base shape
		if(nrhs == 3)
		{
			// Again, don't you dare move these up-front declarations
			const mxArray* warp_map = mxGetField(prhs[0], 0, "warp_map");
			const mxArray* alpha_coords = 0;
			const mxArray* beta_coords = 0;

			if(warp_map == NULL || mxGetClassID(warp_map) != mxUINT32_CLASS)
				mexErrMsgTxt("pa_warp: AAM.warp_map must be present and must be of class 'uint32'.");

			alpha_coords = mxGetField(prhs[0], 0, "alpha_coords");
			beta_coords = mxGetField(prhs[0], 0, "beta_coords");

#if defined(__cplusplus)
			// This is all the customization about data types available: either float or double for both the shape and image data
			// Any other combination of data types will probably cause a segmentation fault.
			// Bilinear interpolation is enabled by default
			if(class_id == mxDOUBLE_CLASS)
				plhs[0] = pa_warp<double,true>(prhs[1], prhs[2], shape_mesh, warp_map, alpha_coords, beta_coords, NULL);
			else if(class_id == mxSINGLE_CLASS)
				plhs[0] = pa_warp<float,true>(prhs[1], prhs[2], shape_mesh, warp_map, alpha_coords, beta_coords, NULL);
			else
				mexErrMsgTxt("pa_warp: unsupported numberic format used for floating point data.");
#else
			if(class_id == mxDOUBLE_CLASS)
				plhs[0] = pa_warp(prhs[1], prhs[2], shape_mesh, warp_map, alpha_coords, beta_coords, NULL);
			else
				mexErrMsgTxt("pa_warp: unsupported numberic format used for floating point data.");
#endif
		}
		else
		{
#if defined(__cplusplus)
			// This is all the customization about data types available: either float or double for both the shape and image data
			// Any other combination of data types will probably cause a segmentation fault.
			// Bilinear interpolation is disabled by default, as it creates an annoying "border" on the warped data,
			// making it difficult to synthesize nice images with the AAM.
			if(class_id == mxDOUBLE_CLASS)
				plhs[0] = pa_warp<double,false>(prhs[1], prhs[2], shape_mesh, NULL, NULL, NULL, prhs[3]);
			else if(class_id == mxSINGLE_CLASS)
				plhs[0] = pa_warp<float,false>(prhs[1], prhs[2], shape_mesh, NULL, NULL, NULL, prhs[3]);
			else
				mexErrMsgTxt("pa_warp: unsupported numberic format used for floating point data.");
#else
			if(class_id == mxDOUBLE_CLASS)
				plhs[0] = pa_warp(prhs[1], prhs[2], shape_mesh, NULL, NULL, NULL, prhs[3]);
			else
				mexErrMsgTxt("pa_warp: unsupported numberic format used for floating point data.");
#endif
		}
	}

#if defined(__cplusplus)
}
#endif

