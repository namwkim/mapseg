function [vgrid, result] = remove_vgrid5(bw, width, vth, range, thk, len)
    [nr, nc] = size(bw);
    
    % grid
    vgrid   = true(nr, nc);
    
    ibw = ~bw; %invert image
    
    vmax  = width*nr;

    %column pass
    j=1;
    vhist = zeros(1, nc);
    
    progressbar('Remove Vertical Grid Lines');
    while j<=nc
        % collect the intensities of jittered-lines 
        idx = 1;
        dts = zeros(1, range*2+1);
        count   = zeros(1, range*2+1);
        for dt = -range:range
            eidx = j+dt;
            if (eidx>0 && (eidx+width-1)<=nc && j>0 && (j+width-1)<=nc)
                count(idx) = count_thickline_v(ibw, width, 1, j, nr, eidx);
            else
                count(idx) = 0;
            end
            dts(idx) = dt;
            idx = idx + 1;
        end 
        % find the maximun intensity 
        [C, I]  = max(count);
        ints = C/vmax;
        eidx = j+dts(I);
        vhist(j) = ints;
        if (ints>=vth)
            vgrid   = draw_line_v(vgrid, ibw, width, 1, j, nr, eidx, thk, len); 
        end
        j = j+1;
        progressbar(j/nc);
    end
    progressbar(1);
%     figure, imshow(bw);
%     figure, imshow(vgrid);
    result = bw;
    result(find(vgrid==0))=1;
%     figure, imshow(result);  
%     figure, hist(vhist);       
end