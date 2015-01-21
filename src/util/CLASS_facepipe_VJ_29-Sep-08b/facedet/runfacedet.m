function DETS = runfacedet(I,imgpath)

tmppath=tempname;
pgmpath=[tmppath '.pgm'];
if nargin<2
    detpath=[tmppath '.vj'];
else
    detpath=[imgpath '.vj'];
end

imwrite(I,pgmpath);

root=[fileparts(which(mfilename)) '/OpenCV_ViolaJones'];
disp(root);
disp('DEBUG 0');
system(sprintf('%s/Release/OpenCV_ViolaJones.exe %s/haarcascade_frontalface_alt.xml %s %s',root,root,pgmpath,detpath));
disp('DEBUG 1');

DETS=readfacedets(detpath);
delete(pgmpath);
if nargin<2
    delete(detpath);
end

