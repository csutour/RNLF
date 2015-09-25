function h = plotvideo(video, video_ref, stitle)

    if ~exist('video_ref', 'var') || isempty(video_ref)
        video_ref = video;
    end
    if ~exist('stitle', 'var')
        stitle = '';
    end

    cur_gca = gca;
    T = size(video, 3);
    h = plotimage(video(:,:,1), video_ref(:,:,1), stitle);
    ud = struct('plotframe', @plotframe);
    set(h, 'UserData', ud);

    function h = plotframe(h, t)

        axes(cur_gca);
        f = mod(t - 1, T) + 1;
        h = plotimage(video(:,:,f), video_ref(:,:,f), stitle);
        set(h, 'UserData', ud);
                axes(cur_gca);

    end

end
