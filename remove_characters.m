function [result, cts] = remove_characters(bw, nb, usize)
% bw: binary image where 1=white(lines), 0:black(background)
    bw = ~bw;
    cts = 0;
    [nr, nc] = size(bw);
    cc = bwconncomp(bw);
    
    progressbar('Remove Characters');
    for i=1:cc.NumObjects % for each connected component
        ridx = rem(cc.PixelIdxList{i}, nr);  % row indices
        cidx = uint32(ceil(cc.PixelIdxList{i}/nr)); % column indices
        
        % find a bounding box (min, max)
        min_r = min(ridx);
        min_c = min(cidx);
        if (min_r==0), min_r = 1;, end
        max_r = max(ridx);
        max_c = max(cidx);
        if (max_r==0), max_r = 1;, end
        % find the size of the box
        rside = (max_r-min_r+1);
        cside = (max_c-min_c+1);
        if (rside > 3*cside || cside > 3*rside) % check the ratio of sides of the box
            continue;
        end
        bsize = rside*cside;
        if (bsize > usize)
            continue;
        end
        
        unbs  = (bsize/usize)*nb; % allowable # of branch points for the box
        
        % find the number of branch points
        cc_img = bw(min_r:max_r, min_c:max_c);
        bpts = find(bwmorph(cc_img, 'branchpoints'));
        if (isempty(bpts))
            nbs = 0;
        else
            [nbs, ~] = size(find(bpts));
        end
        
        if (nbs>=nb) % if there are more than desirable
            bw(cc.PixelIdxList{i}) = 0;
            cts = cts + 1;
        end   
        progressbar(i/cc.NumObjects);
    end
    progressbar(1);
    result = ~bw;
end