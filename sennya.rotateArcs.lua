Macro.new("rotateArcs")
    .withName("Rotate Arcs")
    .withIcon("e577")
    .withParent("sennya")
    .withDefinition(function()
        local selected = Event.getCurrentSelection(EventSelectionConstraint.create().arc())
        if #selected.resultCombined == 0 then
            notifyWarn("Please choose atleast 1 arc/trace")
            return
        end

        local field_theta = DialogField.create("theta")
            .setLabel("angle")
            .defaultTo(0)
            .setHint("The theta to Rotate")
            .textField(FieldConstraint.create().float())
        local field_anchorX = DialogField.create("anchorX")
            .setLabel("Anchor X")
            .defaultTo(0)
            .setHint("Rotation Anchor X")
            .textField(FieldConstraint.create().float())
        local field_anchorY = DialogField.create("anchorY")
            .setLabel("Anchor Y")
            .setHint("Rotation Ynchor Y")
            .defaultTo(0)
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
                .withTitle("Rotate Arcs")
                .requestInput({
                    field_theta,
                    field_anchorX,
                    field_anchorY,
                    lockHead,
                    lockTail
                })
        coroutine.yield()

        local radians = -(math.rad(userInput.result["theta"]))
        local anchorX = userInput.result["anchorX"]
        local anchorY = userInput.result["anchorY"]
        local lockHead = userInput.result["lockHead"]
        local lockTail = userInput.result["lockTail"]


        local command = Command.create("rotated notes")

        for _, arc in ipairs(selected.resultCombined) do
            command.add(arc.delete())
            local newStartX = ((arc.startX - anchorX)*2 * math.cos(radians) - (arc.startY - anchorY) * math.sin(radians))/2 + anchorX
            local newStartY = (arc.startX - anchorX)*2 * math.sin(radians) + (arc.startY - anchorY) * math.cos(radians) + anchorY
            local newEndX = ((arc.endX - anchorX)*2 * math.cos(radians) - (arc.endY - anchorY) * math.sin(radians))/2 + anchorX
            local newEndY = ((arc.endX - anchorX)*2 * math.sin(radians)) + (arc.endY - anchorY) * math.cos(radians) + anchorY
            
            command.add(Event.arc(
                arc.timing, (not lockHead and newStartX or arc.startX), (not lockHead and newStartY or arc.startY),
                arc.endTiming, (not lockTail and newEndX or arc.endX), (not lockTail and newEndY or arc.endY),
                arc.isVoid, arc.color, arc.type, arc.timingGroup, arc.sfx, arc.arcResolutionMultiplier).save()
            )
        end
        command.commit()
    end)
    .add()