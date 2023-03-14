fun merge(xs:int list, ys:int list): int list = 
    if xs... empty?
        if hd xs < hd ys
        then merge(tl xs, hd xs::ys)
        else merge(hd ys::xs, tl ys)