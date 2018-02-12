function d = getVPDist(line, vp)
    p1 = line(1:2); p2 = line(3:4);
    p1h = [p1'; 1]; p2h = [p2'; 1];
    c = (p1 + p2) / 2; ch = [c'; 1];
    lH = cross(ch,vp);
    d = ldist(lH,p1h);
end

