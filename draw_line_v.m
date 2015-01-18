function canvas = draw_line_v(canvas, ibw, width, x0, y0, x1, y1, thk, len)
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
        if (check_neighbors_v(ibw, x0, y0, width, thk, len))
            canvas(x0, y0:(y0+width-1)) = 0;
        end
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
    if (check_neighbors_v(ibw, x0, y0, width, thk, len))
        canvas(x0, y0:(y0+width-1)) = 0;
    end
end
function ok = check_neighbors_v(ibw, x, y, width, thickness, length)
    % METHOD 1
    if (true)
        % upper left and lower right
        if (count_blk(ibw, x-length+1, x, y-thickness, y-1)>0 && count_blk(ibw, x, x+length-1, y+width, y+width+thickness-1)>0)
            ok = false;
        % lower left and upper right
        elseif (count_blk(ibw, x, x+length-1, y-thickness, y-1)>0 && count_blk(ibw, x-length+1, x, y+width, y+width+thickness-1)>0)
            ok = false;
        else
            ok = true;
        end
    % METHOD 2
    else
        if (count_blk(ibw, x, x, y-thickness, y-1)>0 || count_blk(ibw, x, x, y+width, y+width+thickness-1)>0)
            ok = false;
        else
            ok = true;
        end
    end
end
function num_blk = count_blk(ibw, r_sidx, r_eidx, c_sidx, c_eidx)
    [nr, nc] = size(ibw);
    if r_sidx>=1 && r_eidx<=nr && c_sidx>=1 && c_eidx<=nc
        num_blk = sum(sum(ibw(r_sidx:r_eidx, c_sidx:c_eidx)));
    else
        num_blk = 0;
    end        
end