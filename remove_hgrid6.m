function [hgrid, result] = remove_hgrid6(bw, width, hth, range, thk, len)   
    [nr, nc] = size(bw);
    
    % grid
    hgrid   = true(nr, nc);
    
    ibw = ~bw; %invert image
        
    hmax  = width*nc;
    
    %row pass
    i=1;
    %rhist = zeros(1, nr);
    
    progressbar('Remove Horizontal Grid Lines');
    while i<=nr
        % collect the intensities of jittered-lines 
        idx = 1;
        dts = zeros(1, range*2+1);
        count   = zeros(1, range*2+1);
        for dt = -range:range
            eidx = i+dt;
            if (eidx>0 && (eidx+width-1)<=nr && i>0 && (i+width-1)<=nr)
                count(idx) = count_thickline_h(ibw, width, i, 1, eidx, nc);
            else
                count(idx) = 0;
            end
            dts(idx) = dt;
            idx = idx + 1;
        end 
        % find the maximun intensity 
        for i = 1:max(size(count))
            ints = count(i)/hmax;
            eidx  = i + dts(i);
            if (ints>=hth)
                hgrid   = draw_line_h(hgrid, ibw, width, i, 1, eidx, nc, thk, len); 
            end
        end
        %[C, I]  = max(count);
        %ints = C/hmax;
        %eidx = i+dts(I);
        %rhist(i) = ints;

        i = i+1;
        progressbar(i/nr);
    end
    progressbar(1);
%     figure, imshow(bw);
%     figure, imshow(hgrid);
    result = bw;
    result(find(hgrid==0))=1;
%     figure, imshow(result);  
%     figure, hist(rhist);
end