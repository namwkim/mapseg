function result = close_lands(bw, ray_length, lookup)
% bw: binary image where black pixels represent background and white pixels
% constitute lands
% box_size: used to find the ray direction
% ray_length: the maximum distance to which the ray can go
% lookup: the number of previous pixels to lookup to determine the ray
% direction
bw=~bw;
% find endpoints of a discrete set of connected components
endpoints = bwmorph(bw, 'endpoints');

% for each end point, construct a box to find the ray direction
 [nr, nc] = size(bw);
 result = bw;
 progressbar('Close Holes');
 none = true;
 for i=1:nr
    for j=1:nc
        if (endpoints(i, j)==1) % an end point is found
            % construct a box centered on the end point
            dir = find_ray_dir(bw, i, j, lookup);
            if (strcmp(dir, 'top')) % top
                % shoot a ray along the bottom direction
                [ei, ej, found] = shoot_ray(i,j,ray_length, 'top', endpoints);
                if (found) 
                    result = connect_with_line(result, i,j, ei, ej);
                    none = false;
                end
            end
            if (strcmp(dir, 'bottom')) % bottom
                % shoot a ray along the top direction
                [ei, ej, found] = shoot_ray(i,j,ray_length, 'bottom', endpoints);
                if (found) 
                    result = connect_with_line(result, i,j, ei, ej);
                    none = false;
                end
            end
            if (strcmp(dir, 'left')) % left
                % shoot a ray along the right direction
                [ei, ej, found] = shoot_ray(i,j,ray_length, 'left', endpoints);
                if (found) 
                    result = connect_with_line(result, i,j, ei, ej);
                    none = false;
                end
            end
            if (strcmp(dir, 'right')) % right
                % shoot a ray along the left direction
                [ei, ej, found] = shoot_ray(i,j,ray_length, 'right', endpoints);
                if (found) 
                    result = connect_with_line(result, i,j, ei, ej);
                    none = false;
                end
            end
            if (strcmp(dir, 'top-left')) % top-left
                [ei, ej, found] = shoot_ray(i,j,ray_length, 'top-left', endpoints);
                if (found) 
                    result = connect_with_line(result, i,j, ei, ej);
                    none = false;
                end
            end
            if (strcmp(dir, 'top-right')) % top-right
                [ei, ej, found] = shoot_ray(i,j,ray_length, 'top-right', endpoints);
                if (found) 
                    result = connect_with_line(result, i,j, ei, ej);
                    none = false;
                end
            end
            if (strcmp(dir, 'bottom-left')) % bottom-left
                [ei, ej, found] = shoot_ray(i,j,ray_length, 'bottom-left', endpoints);
                if (found) 
                    result = connect_with_line(result, i,j, ei, ej);
                    none = false;
                end
            end
            if (strcmp(dir, 'bottom-right')) % bottom-right
                [ei, ej, found] = shoot_ray(i,j,ray_length, 'bottom-right', endpoints);
                if (found) 
                    result = connect_with_line(result, i,j, ei, ej);
                    none = false;
                end
            end
            % if no corresponding end point is found, check if near image
            % boundary
            if (none)
                if (abs(i-1)<ray_length)
                    result = connect_with_line(result, i,j, 1, j);
                end
                if (abs(i-nr)<ray_length)
                    result = connect_with_line(result, i,j, nr, j);
                end
                
                if (abs(j-1)<ray_length)
                    result = connect_with_line(result, i,j, i, 1);
                end
                if (abs(j-nc)<ray_length)
                    result = connect_with_line(result, i,j, i, nc);
                end
                
            end
            none = true;
        end
    end
    progressbar(i/nr);
 end
 progressbar(1);
 result=~result;
end

function [eidx_r, eidx_c, found] = shoot_ray(ci, cj, ray_length, dir, endpoints)
    [nr, nc] = size(endpoints);
    found = 0;
    if (strcmp(dir, 'top'))
        inc = ray_length+1;
        for i = ci-ray_length : ci-1 % along the ray direction
            inc = inc - 1;
            for j = cj-inc:cj+inc % scan orthogonal range
                if (inside_boundary(nr, nc, i, j) && endpoints(i,j)==1)
                    % method 1 : connect to the first end-point found
                    if (found)
                        %compare distances using 1-norm
                        pdist = abs(eidx_r-ci)+abs(eidx_c-cj);
                        cdist = abs(i-ci)+abs(j-cj);
                        if (cdist<pdist) % if current dist is less than the previous one
                            eidx_r = i;
                            eidx_c = j;
                        end                           
                    else
                        eidx_r = i;
                        eidx_c = j;
                        found = 1;
                    end
                    
                end
            end            
        end
    elseif (strcmp(dir, 'bottom'))
        inc = 0;
        for i = ci+1:ci+ray_length
            inc = inc + 1;
            for j = cj-inc:cj+inc
                if (inside_boundary(nr, nc, i, j) && endpoints(i,j)==1)
                    if (found)
                        %compare distances using 1-norm
                        pdist = abs(eidx_r-ci)+abs(eidx_c-cj);
                        cdist = abs(i-ci)+abs(j-cj);
                        if (cdist<pdist) % if current dist is less than the previous one
                            eidx_r = i;
                            eidx_c = j;
                        end                           
                    else
                        eidx_r = i;
                        eidx_c = j;
                        found = 1;
                    end
                end
            end
        end        
    elseif (strcmp(dir, 'left'))
        inc = ray_length+1;
        for j = cj-ray_length:cj-1
            inc = inc - 1;
            for i = ci-inc:ci+inc                
                if (inside_boundary(nr, nc, i, j) && endpoints(i,j)==1)
                    if (found)
                        %compare distances using 1-norm
                        pdist = abs(eidx_r-ci)+abs(eidx_c-cj);
                        cdist = abs(i-ci)+abs(j-cj);
                        if (cdist<pdist) % if current dist is less than the previous one
                            eidx_r = i;
                            eidx_c = j;
                        end                           
                    else
                        eidx_r = i;
                        eidx_c = j;
                        found = 1;
                    end
                end
            end
        end       
    elseif (strcmp(dir, 'right'))
        inc = 0;
        for j = cj+1:cj+ray_length
            inc = inc + 1;
            for i = ci-inc:ci+inc
                if (inside_boundary(nr, nc, i, j) && endpoints(i,j)==1)
                    if (found)
                        %compare distances using 1-norm
                        pdist = abs(eidx_r-ci)+abs(eidx_c-cj);
                        cdist = abs(i-ci)+abs(j-cj);
                        if (cdist<pdist) % if current dist is less than the previous one
                            eidx_r = i;
                            eidx_c = j;
                        end                           
                    else
                        eidx_r = i;
                        eidx_c = j;
                        found = 1;
                    end
                end
            end
        end       
    elseif (strcmp(dir, 'top-left'))        
        for loop = 1:ray_length
            di = 0;
            dj = loop; 
            while (di~=loop+1 && dj~=-1)
                if (inside_boundary(nr, nc, ci-di, cj-dj) && endpoints(ci-di, cj-dj)==1)
                    if (found)
                        %compare distances using 1-norm
                        pdist = abs(eidx_r-ci)+abs(eidx_c-cj);
                        cdist = abs(di)+abs(dj);
                        if (cdist<pdist) % if current dist is less than the previous one
                            eidx_r = ci-di;
                            eidx_c = cj-dj;
                        end                           
                    else
                        eidx_r = ci-di;
                        eidx_c = cj-dj;
                        found = 1;
                    end
                end
                di = di + 1;
                dj = dj - 1;
            end
        end
    elseif (strcmp(dir, 'top-right'))
        for loop = 1:ray_length
            di = 0;
            dj = loop; 
            while (di~=loop+1 && dj~=-1)
                if (inside_boundary(nr, nc, ci-di, cj+dj) && endpoints(ci-di, cj+dj)==1)
                    if (found)
                        %compare distances using 1-norm
                        pdist = abs(eidx_r-ci)+abs(eidx_c-cj);
                        cdist = abs(di)+abs(dj);
                        if (cdist<pdist) % if current dist is less than the previous one
                            eidx_r = ci-di;
                            eidx_c = cj+dj;
                        end                           
                    else
                        eidx_r = ci-di;
                        eidx_c = cj+dj;
                        found = 1;
                    end
                end
                di = di + 1;
                dj = dj - 1;
            end
        end
    elseif (strcmp(dir, 'bottom-left'))
        for loop = 1:ray_length
            di = 0;
            dj = loop; 
            while (di~=loop+1 && dj~=-1)
                if (inside_boundary(nr, nc, ci+di, cj-dj) && endpoints(ci+di, cj-dj)==1)
                    if (found)
                        %compare distances using 1-norm
                        pdist = abs(eidx_r-ci)+abs(eidx_c-cj);
                        cdist = abs(di)+abs(dj);
                        if (cdist<pdist) % if current dist is less than the previous one
                            eidx_r = ci+di;
                            eidx_c = cj-dj;
                        end                           
                    else
                        eidx_r = ci+di;
                        eidx_c = cj-dj;
                        found = 1;
                    end
                end
                di = di + 1;
                dj = dj - 1;
            end
        end
    elseif (strcmp(dir, 'bottom-right'))
        for loop = 1:ray_length
            di = 0;
            dj = loop; 
            while (di~=loop+1 && dj~=-1)
                if (inside_boundary(nr, nc, ci+di, cj+dj) && endpoints(ci+di, cj+dj)==1)
                    if (found)
                        %compare distances using 1-norm
                        pdist = abs(eidx_r-ci)+abs(eidx_c-cj);
                        cdist = abs(di)+abs(dj);
                        if (cdist<pdist) % if current dist is less than the previous one
                            eidx_r = ci+di;
                            eidx_c = cj+dj;
                        end                           
                    else
                        eidx_r = ci+di;
                        eidx_c = cj+dj;
                        found = 1;
                    end
                end
                di = di + 1;
                dj = dj - 1;
            end
        end
    end
    if (found)
        return;
    end        
    eidx_r = 0;
    eidx_c = 0;
    found = 0;
end


function canvas = connect_with_line(canvas, x0, y0, x1, y1)
    dx = abs(x1-x0);
    dy = abs(y1-y0);
    if (x0<x1),
        sx = 1;
    else
        sx = -1;
    end
    if (y0<y1)
        sy = 1;
    else
        sy = -1;
    end
    err = dx - dy;

    while (x0~=x1 || y0~=y1)
        canvas(x0, y0) = 1;
        e2 = 2*err;
        if (e2>-dy)
            err = err-dy;
            x0 = x0 + sx;
        end
        if (e2 <dx)
            err = err+dx;
            y0 = y0 + sy;
        end
    end
    canvas(x0, y0) = 1;
end
function dir = find_ray_dir(img, i, j, limit)
    [nr, nc] = size(img);
    s = 1;
    ridx = i;
    cidx = j;
    while (s<=limit)   
        img(ridx, cidx) = 0;
        if (inside_boundary(nr, nc, ridx-1, cidx-1) && img(ridx-1, cidx-1)) % top-left
            ridx = ridx - 1;
            cidx = cidx - 1;            
        elseif (inside_boundary(nr, nc, ridx-1, cidx) && img(ridx-1, cidx)) % top
            ridx = ridx - 1;
        elseif (inside_boundary(nr, nc, ridx-1, cidx+1) && img(ridx-1, cidx+1)) % top-right
            ridx = ridx - 1;
            cidx = cidx + 1;
        elseif (inside_boundary(nr, nc, ridx, cidx+1) && img(ridx, cidx+1)) % right
            cidx = cidx + 1;
        elseif (inside_boundary(nr, nc, ridx+1, cidx+1) && img(ridx+1, cidx+1)) % bottom-right
            ridx = ridx + 1;
            cidx = cidx + 1;
        elseif (inside_boundary(nr, nc, ridx+1, cidx) && img(ridx+1, cidx)) % bottom
            ridx = ridx + 1;
        elseif (inside_boundary(nr, nc, ridx+1, cidx-1) && img(ridx+1, cidx-1)) % bottom-left
            ridx = ridx + 1;
            cidx = cidx - 1;            
        elseif (inside_boundary(nr, nc, ridx, cidx-1) && img(ridx, cidx-1)) % left
            cidx = cidx - 1;
        else
            break;
        end        
        s = s + 1;
    end
    dir_r = i - ridx;
    dir_c = j - cidx;
    if (abs(dir_r) == abs(dir_c)) % diagonal direction
        if (dir_r<0 && dir_c<0) % -.-
            dir = 'top-left';
        elseif (dir_r>0 && dir_c<0) % +,-
            dir = 'bottom-left';
        elseif (dir_r<0 && dir_c>0) % -,+
            dir = 'top-right';
        elseif (dir_r>0 && dir_c>0) % +,+
            dir = 'bottom-right';
        end          
    elseif (abs(dir_r)<abs(dir_c)) % horizontal
        if (dir_c>0) % +
            dir = 'right';
        else % -
            dir = 'left';
        end
    elseif (abs(dir_r)>abs(dir_c)) % vertical
        if (dir_r>0) % +
            dir = 'bottom';
        else % -
            dir = 'top';
        end
    end
        
end

function bool = inside_boundary(nr, nc, i, j)
    if (i>=1 && i<=nr && j>=1 && j<=nc)
        bool = true;
    else
        bool = false;
    end
end
