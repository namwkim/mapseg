function count = count_line(canvas, x0, y0, x1, y1)
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
    
    count = 0;
    while (x0~=x1 || y0~=y1)
        if (canvas(x0, y0)==1)
            count = count+1;
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
    if (canvas(x0, y0)==1)
        count = count+1;
    end
end
