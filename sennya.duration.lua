Macro.new("duration")
    .withName("Duration")
    .withIcon("e192")
    .withParent("sennya")
    .withDefinition(function()
        local req1 = TrackInput.requestTiming()
        coroutine.yield()
        local time1 = req1.result["timing"]

        local req2 = TrackInput.requestTiming()
        coroutine.yield()
        local time2 = req2.result["timing"]

        notify(math.abs(time2 - time1))
    end)
.add()