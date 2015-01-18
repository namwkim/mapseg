function result = remove_fragments(bw, frag_size)
    bw = ~bw;
    [nr, nc] = size(bw);
    cc = bwconncomp(bw);
    progressbar('Remove Fragments');
    for i=1:cc.NumObjects % for each connected component
        [comp_size, ~] = size(cc.PixelIdxList{i});
        if (comp_size<frag_size)
            bw(cc.PixelIdxList{i}) = 0;
        end
        progressbar(i/cc.NumObjects);
    end
    progressbar(1);
    result = ~bw;
end