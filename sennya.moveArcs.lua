Macro.new("moveArcs")
    .withName("Move Arcs")
    .withIcon("e89f")
    .withParent("sennya")
    .withDefinition(function()
        local selected = Event.getCurrentSelection(EventSelectionConstraint.create().arc())
        if #selected.resultCombined == 0 then
            notifyWarn("Please choose atleast 1 arc/trace")
            return
        end

        local FieldX = DialogField.create("X")
            .setLabel("X")
            .defaultTo(0)
            .setHint("X-axis movement distance...")
            .textField(FieldConstraint.create().float())
        local FieldY = DialogField.create("Y")
            .setLabel("Y")
            .defaultTo(0)
            .setHint("Y-axis movement distance...")
            .textField(FieldConstraint.create().float())
        local lockHead = DialogField.create("lockHead")
            .setLabel("Lock Head")
            .setTooltip("Lock Head of Arcs/Trails")
            .checkbox()
        local lockTail = DialogField.create("lockTail")
            .setLabel("Lock Tail")
            .setTooltip("Lock Tail of Arcs/Trails")
            .checkbox()
        
        local userInput = 
            DialogInput
                .withTitle("Move Arcs")
                .requestInput({
                    FieldX,
                    FieldY,
                    lockHead,
                    lockTail
                })
        coroutine.yield()

        local x = tonumber(userInput.result["X"])
        local y = tonumber(userInput.result["Y"])
        local lockHead = userInput.result["lockHead"]
        local lockTail = userInput.result["lockTail"]

        local allArctaps = Event.query(EventSelectionConstraint.create().arctap())

        local command = Command.create("Moved Arcs")
        local arcs = {}
        local traces = {}
        local newTraces = {}

        for _, object in ipairs(selected.resultCombined) do
            table.insert(arcs, Event.arc(
                object.timing, (not lockHead and (object.startX + x) or object.startX), (not lockHead and (object.startY + y) or object.startY),
                object.endTiming, (not lockTail and object.endX + x) or object.endX, (not lockTail and (object.endY + y) or object.endY),
                object.isVoid, object.color, object.type, object.timingGroup, object.sfx, object.arcResolutionMultiplier))

            if object.is("voidarc") then
                table.insert(traces, object)
                table.insert(newTraces, arcs[#arcs])
            end
            command.add(arcs[#arcs].save())
            command.add(object.delete())
        end
        for _, arctap in ipairs(allArctaps.arctap) do
            for traceIndex, trace in ipairs(traces) do
                if arctap.arc == trace then
                    command.add(Event.arctap(arctap.timing,newTraces[traceIndex] , arctap.width).save())
                    command.add(arctap.delete())
                end
            end
        end
        command.commit()
    end)
    .add()