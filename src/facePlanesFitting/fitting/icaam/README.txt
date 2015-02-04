INTRODUCTION

This is an implementation of inverse compositional Active Appearance Models (AAMs),
as described in the "Active Appearance Models Revisited" paper by Iain Matthews 
and Simon Baker (available in ./doc).

Experimental support is provided for the 3D extensions to inverse compositional AAMs,
also developed by Matthews and Baker in their "2D vs. 3D Deformable Face Models" and
"Real-Time Combined 2D+3D Active Appearance Models" papers (also available in ./doc). 

As an aid to ease the task of building the 3D shape model needed by the 3D extensions, 
an implementation of the closed-form shape-from-motion algorithm by Jing Xiao and 
Takeo Kanade is provided. And while I can't guarantee the quality of the results given 
by this latter implementation, it shouldn't be far from correct as it's heavily based 
on Xiao's implementation.

As the code is heavily documented, this readme will only focus on the more important 
issues and simply provide an overview of the implemenation. 
Typing 'help <function_name>' at the MATLAB prompt should provide enough informations 
to use a given function.



FREQUENTLY ASKED QUESTIONS

There are still some open issues with the implementation. Before contacting me about
these issues please check if the following FAQs answer to your questions.

Q: The 2D fitting algorithm doesn't seem to produce consistently good results for some
datasets such as IMM, even when initialized with the ground-truth. Why is that happening?

A: The short answer is: I don't know.

But to elaborate a bit more, it shouldn't be a bug, as the very same issues were observed
by Emmanuel Goossaert (emmanuel.goossaert@gmail.com) in his implementation of inverse
compositional AAMs.
Since it's very unlikely that we both made the same mistakes during the implementation,
the only logical explanation is that either the paper is wrong or that it's omitting some
crucial implementation details. Or maybe the paper is indeed correct, and it's just a
problem with the algorithm.

What I observed during my thesis work is that fitting results become less stable as
the number of shape modes increase; this may suggest that the algorithm is sensitive
to noise in the annotation data.
In the case of human faces, and if we exclude pose, a perfect shape model shouldn't
have more than 6-7 shape modes (1 per eybrow, 1 per eye, 2-3 for the mouth).
So seeing as the number of shape modes can go well over 20 in some datasets (even
with low pose variation), there is indeed too much noise in the annotation data.

To mitigate this problem, you can either reduce the training set size, reduce noise in the
annotation data by projecting a 3D shape model to generate 2D annotations, or use
the 'backprojection' feature of annotate() to generate shape modes only when strictly necessary.
Whathever approach you'll end up using, it's going to be time-consuming, unfortunately.

Mr. Qiang (flealq@gmail.com) reported how using grayscale images seemed to provide a
significant improvement on the fitting performance, so that may help too.


Q: Where is the initialization algorithm?

A: No intialization function is included, as there are a lot of ways to initialize an AAM
search, and I encourage you to find the initialization strategy that best suits your needs.

In theory you could use the rigid alignment part in fit_2d() (lines 111~118) to find the
position of a face inside the image, starting from multiple configurations, and picking the
search that gives the lowest error (whathever your error metric is). Note that this approach will
most likely generate false positives (ie. find faces where there aren't any) if you use
simple error metrics.


Q: Why aren't you using multi-resolution AAMs?

A: It's not that I needed to implement that. Just train different AAMs using imresize() to
resize the image data and scaling the annotation data by the same factor.
Fitting is a bit more tricky, and you can use different heuristics, but the simplest approach is to
start from the lowest resolution and running a few iterations of the fitting algorithm, using its result
to fit with the next higher resolution AAM.


Q: Why isn't the fitting algorithm using some kind of error metric to see if it has converged?

A: I used to have that, but I felt like I was "cheating" because the fitting procedure was sometimes
returning correct solutions while other times they were wrong, depending on the threshold used to
terminate the iteration. This was happening of course because the algorithm isn't always stable
(see first FAQ).
The only way to have a good measure of convergence would be to measure the image error, but
that is costly to estimate.


Q: The shape from motion algorithm is producing very poor results. What am I doing wrong?

A: Most likely, nothing. The algorithm is randomized and you need to run it several times
to get "good" results. "Good" in this case is an euphemism, as I never managed to get a usable 3D
model from that algorithm. But since I tested it against Jing Xiao's implementation, there are
only two possibilities: his implementation is wrong or it's a problem with the algorithm itself.

I assume the poor performance is again caused by noise in the 2D input data, but I have no proof
to back up such claims, except knowing that using the same data with Torresani's implementation gives even
worse reconstruction results.


Q: I don't understand italian, please translate your thesis in english.

A: Don't have time for that, sorry. Every important implementation detail written in the thesis
is either already available in the other papers I provide in ./doc or is written in code comments
and/or this FAQ. In case something is still not clear AFTER reading those, you can always send me
an e-mail at elvezzaro@gmail.com.



PACKAGE CONTENTS

./datasets/

Datasets included in the implementation. Each dataset includes a manually-adjusted 
triangulation (./<dataset>/triangulation.mat) to ensure good fitting performance with 
that specific dataset and manually-produced landmark data for 2D images 
(./<dataset>/data/<image_path>.mat). 

'triangulation.mat' simply contains a matrix variable called 'triangulation', specifying 
a triangular mesh in the same format as the one used by MATLAB's 'delaunay' routine. 

See the 'annotate' documentation for more details about the annotation format, in short, 
each annotation file is pretty much a matrix variable called 'annotations' whose rows 
contains the cartesian coordinates of each landmark.

NOTE: The image data is not of my property, only the annotation data (with the exception 
      of the IMM dataset). 
      See ./<dataset>/LICENSE.txt for specific licensing issues.

./doc/

	Essential papers for the understanding of the implementation's inner workings. 
	Also includes my thesis on AAMs (only availabe in italian).

./examples/

	The starting point to familiarize with the code. See the specific scripts for more details.

./annotate.m

	Annotate images, starting from scratch or using another annotation file as a template.

./asf2annotations.m

	Converts annotations from asf format (used by the IMM database) to our native .mat format.

./build_model_2d.m

	Builds an Active Appearance Model using provided shape and appearance data.

./build_model_2d_from_files.m

	Builds an Active Appearance Model using shape and appearance data retrieved from
	the given directory.

./fit_2d.m

	Fit an Active Appearance Model to an image, starting from the provided initial shape.

./fit_3d.m

	Fit an Active Appearance Model to an image combining 2D and 3D information to
	recover both 2D and 3D shapes. 

./gradient_2d.m

	Approximate the gradient of a two-dimensional function represented by M(i,j), using
	a 3x3 plane fitting algorithm.

./gs_orthonorm.m

	Classic Gram-Schmidt orthonormalization.

./ij2xy.m

	Converts shapes from "image" coordinates to cartesian coordinates.
	In cartesian coordinates, the origin is on the lower-left corner of
	the image and y moves vertically while x moves horizontally.
	
	Image coordinates follow a matrix notation where the origin is in
	the upper left corner and the first coordinate 'i' moves vertically
	(in the opposite direction of y), while the second 'j' coordinate
	moves horizontally in the same direction as x.

./pa_warp.cpp
./pa_warp.m

	C++ MEX-file.
	Warps the portion of image_data delimited by a source shape to a                                                               
	destination shape (which by default is is the mean shape) using a piecewise affine warp.   

./pa_warp_composition.m

	Composition of two piecewiese affine warps, as described in 
	'Active Appearance Models Revisited' paper by Iain Matthews and 
	Simon Baker.

./pts2annotations.m

	Converts annotations from pts format to our native .mat format.

./sm_recovery.m

	Recover 3D information from deforming and moving 2D shapes, as
	described in the paper:
	"A Closed-Form Solution to Non-Rigid Shape and Motion Recovery"
	by Jing Xiao, Jin-xiang Chai, Takeo Kanade.
	
	The algorithm is randomized, try running it another time if the results
	are not satisfying.

./to_affine.m         

	Compute the affine transform which corresponds to the parameters q.

./var_pca.m

	Principal Component Analysis.

./xy2ij.m

	Converts shapes from cartesian coordinates to "image" coordinates.
	In cartesian coordinates, the origin is on the lower-left corner of
	the image and y moves vertically while x moves horizontally.
	
	Image coordinates follow a matrix notation where the origin is in
	the upper left corner and the first coordinate 'i' moves vertically
	(in the opposite direction of y), while the second 'j' coordinate
	moves horizontally in the same direction as x.



INSTALLATION

1. Copy the content of the package in a place of your choice and add the path 
   to MATLAB's search paths.

2. Configure the mex-file building system: 'mex -setup'. Depending on your platform,
   the preferred choice here are GCC and Visual Studio 2005 or later. 
   If you can't use/afford any of those compilers, try using LCC, the compiler included 
   in MATLAB (only 32 bit versions).

3. Compile the MEX-file by typing 'pa_warp' at the MATLAB command prompt. On recent versions 
   of MATLAB and with recent compilers this is the equivalent of 'mex -O pa_warp.cpp'. 
   A binary is included for 64-bit MATLAB users. It should work as long as you have the Visual C++
   2005 runtime: http://www.microsoft.com/downloads/en/details.aspx?familyid=EB4EBE2D-33C0-4A47-9DD4-B9A6D7BD44DA&displaylang=en
   



BUGS/LIMITATIONS

- The code has been developed using a 32-bit Matlab r2008b, but it also works on 64-bit r2010b, as that's what I've
  been using recently. I've still not tested it under other operating system.
  Please report any bug you encounter on different operating systems or while using older versions of Matlab.