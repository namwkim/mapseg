function canvas = draw_line(fig, canvas)
%============ READ MOUSE INPUT
    [x, y] = getpts(fig);
    y=round(y); x=round(x);
    [numpts,~] = size(y);
    if numpts == 2
        x0 = y(1);
        x1 = y(2);
        y0 = x(1);
        y1 = x(2);
        %============ DRAWING A LINE
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
            canvas(x0, y0) = 0;
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
        canvas(x0, y0) = 0;
    end


end
