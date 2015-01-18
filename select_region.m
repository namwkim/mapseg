function [polygons, regions, colored] = select_region(fig, bw, rgb)  
    bw=~bw;
    [nr, nc] = size(bw);
    [x, y] = getpts(fig);
    y=round(y); x=round(x);
    [numpts,~] = size(y);
    polygons = {};
    regions = bw;
    progressbar('Extracting Regions');
    t=cputime;
    for i=1:numpts
        region = imfill(bw, [y(i),x(i)]);
        
        %extract selected region (0: black, 1: white)
        region(find(bw)) = 0;  
        
        % fill holes in regions
        region = imfill(region, 'holes');
        region = bwmorph(region, 'close');
        
        indices = find(region);
        r = randi(255);
        g = randi(255);
        b = randi(255);
        for j=indices
            ri = j;   
            gi = j + nr*nc;
            bi = j + nr*nc*2;
            rgb(ri) = r;
            rgb(gi) = g;
            rgb(bi) = b;
        end        
        
        % find polygons
        [px, py] = minperpoly(region, 2);
        
        area = size(find(region), 1);
        npts = size(px, 1);
        cx   = sum(px)/npts;
        cy   = sum(py)/npts;
        
        polygons = [polygons, [px, py], [area, cx, cy], [region]];
        regions = (regions | region);
        progressbar(i/numpts);
    end
    disp(['poly(t): ', num2str(cputime-t)]);

    regions = ~regions;
    colored = rgb;
    progressbar(1);
end