function bw = tobinary(filename)
img = imread(filename);
level = graythresh(img);
bw = im2bw(img, level);
end