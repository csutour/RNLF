function h = playvideo(h, framerate)

    ht = timer( 'ExecutionMode', 'fixedRate', ...
                'TimerFcn', @subplayvideo, ...
                'Period', framerate);

    start(ht);

    function subplayvideo(ht, event)

        try
            t = get(ht, 'TasksExecuted');
            for k = 1:length(h)
                ud = get(h(k), 'UserData');
                h(k) = ud.plotframe(h(k), t);
            end
        catch
            stop(ht);
        end

    end
end