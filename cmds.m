
bw = tobinary('map1.jpg');



%grid removal
t = cputime;
[vgrid, vresult] = remove_vgrid5(bw, 2, 0.25, 20, 2, 3);
[hgrid, map1] = remove_hgrid5(vresult, 2, 0.25, 20, 2, 3);
e = cputime-t;
disp(['grid(t): ', num2str(e)])
%figure, imshow(map1);

%thining
thinmap1 = thinning(map1);

%remove isolated pixels
%cleanedmap1 = bwmorph(thinmap1, 'clean');

%remove characters
t = cputime;
rmch = remove_characters(thinmap1, 5, 800);
rmch_f = remove_fragments(rmch, 15);
e = cputime-t;
disp(['char_frag(t): ', num2str(e)])
% close holes
t = cputime;
result = close_lands(rmch_f, 35, 4);
e = cputime-t;
disp(['hole(t): ', num2str(e)])
% region growing 
rgb = bw2rgb(bw);
t = cputime;
[polygons, regions, colored] = select_region(result, bw, rgb);
e = cputime-t;
disp(['poly(t): ', num2str(e)])

% bw = tobinary('map2.jpg');
% [vgrid, vresult] = remove_vgrid5(bw, 2, 0.4, 20, 2, 3);
% [hgrid, map2] = remove_hgrid5(vresult, 2, 0.3, 20, 2, 3);
% figure, imshow(map2);
