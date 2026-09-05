Macro.new("slashArcs")
    .withName("Slash Arcs")
    .withIcon("e421")
    .withParent("sennya")
    .withDefinition(function()

    local req1 = EventSelectionInput.requestSingleEvent(EventSelectionConstraint.create().arc(), "Select the domainant arc")
    coroutine.yield()
    local arc1 = req1.result["arc"][1]
    local req2 = EventSelectionInput.requestSingleEvent(EventSelectionConstraint.create().arc(), "select the extension arc")
    coroutine.yield()
    local arc2 = req2.result["arc"][1]
    local command = Command.create("slash arc conversion")

    command.add(arc1.delete())
    command.add(arc2.delete())

    local timing = arc1.timing
    while timing < arc1.endTiming do
        if timing >= arc1.endTiming then
            break
        end
        local endTiming = timing + Context.beatLengthAt(timing, arc1.timingGroup) / Context.beatlineDensity
        command.add(
            Event.arc(
                timing, arc1.positionAt(timing), endTiming, arc2.positionAt(endTiming), 
                arc1.isTrace, arc1.color, 
                "s", arc1.timingGroup, 
                arc1.sfx, arc1.arcResolutionMultiplier
            ).save()
        )
        timing = timing + Context.beatLengthAt(timing, arc1.timingGroup) / Context.beatlineDensity
    end
    command.commit()
    end)
    .add()