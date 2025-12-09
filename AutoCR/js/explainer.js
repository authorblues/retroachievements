// --------------------------------------------------
// Infrastructure & Basic Processors
// --------------------------------------------------

const ExplanationCategory = Object.freeze({
	Context: 0,
	Transition: 1,
	Complex: 2, // Accumulators / Measured / Trigger
	Reset: 3,
	Pause: 4,
	MeasuredIf: 5
});

class ProcessorResult
{
	text = "";
	conditionsConsumed = 1;
	category = ExplanationCategory.Context;
	detailedDrillDowns = {}; // Map<string, string>

	constructor(text = "", category = ExplanationCategory.Context, consumed = 1) {
		this.text = text;
		this.category = category;
		this.conditionsConsumed = consumed;
	}
}

class ExplanationContext
{
	group; // Array of Requirements
	notesLookup; // Map<number, CodeNote>
	rangeCache; // Array<{start, end, node}>
	showDecimal;
	processedIndices = new Set(); // HashSet<int>
	lastRemembered = null; // Tracks the content of the last Remember instruction

	constructor(group, notesLookup, rangeCache, showDecimal)
	{
		this.group = group;
		this.notesLookup = notesLookup;
		this.rangeCache = rangeCache;
		this.showDecimal = showDecimal;
	}

	// Shared Helper: Get operand name using Operand
	getName(op, index, suppressPointers = false)
	{
		// 1. Try to resolve Bit Label (e.g. [Started Career]) if size is BitX
		const bitLabel = this.tryGetBitLabel(op.value, op.size, index);
		if (bitLabel)
		{
			return `[${bitLabel}]`;
		}

		// 2. Standard address lookup
		let name = this.getNameFromAddr(op.value, index, suppressPointers);

        // 3. Array Indexing Suffix Logic
        // If this address is modified by an 8-bit/16-bit AddAddress (Array Indexing),
        // append the name of the index to the base name for clarity.
		if (this.group && index > 0)
		{
			const prevReq = this.group[index - 1];
			if (prevReq.flag && prevReq.flag.name === "AddAddress" && prevReq.lhs.size && prevReq.lhs.size.bytes < 3)
			{
                // Resolve the name of the Index address.
                // Pass -1 to prevent recursive chain building for the index itself.
                const indexName = this.getNameFromAddr(prevReq.lhs.value, -1, true);
                
                // If we have both names, format as "Base [offset by Index]"
                // Remove existing brackets from Base to look cleaner if needed, 
                // but keeping them distinguishes the two distinct memory lookups.
                if (name && indexName)
                {
                    // Clean up "Memory 0x..." fallback to be shorter if used in suffix
                    const cleanIndex = indexName.replace("Memory ", "");
                    name = `${name} [offset by ${cleanIndex}]`;
                }
			}
		}

        return name;
	}

	// Shared Helper: Get operand name using Address String
	getNameFromAddr(addrVal, index, suppressPointers = false)
	{
		if (addrVal === null || addrVal === undefined) return "";

		// Use resolver (handles Redirects and Pointers)
		const alias = ConditionFormatter.resolveAlias(addrVal, this.group, index, this.notesLookup, this.rangeCache);
		if (alias) return `[${alias}]`;

		// Check for Pointer chain context (AddAddress on previous line)
		if (this.group && index > 0 && index < this.group.length)
		{
			const prevReq = this.group[index - 1];
            
            // Note: If this was Array Indexing, buildChainInfo excluded it, so resolveAlias failed (correctly).
            // We check here if it's a standard pointer to show the fallback text.
            // If it IS Array Indexing (bytes < 3), we treat it as a direct memory read + modifier, 
            // so we usually fall through to "Memory 0x..." which getName() decorates.
			if (prevReq.flag && prevReq.flag.name === "AddAddress" && (!prevReq.lhs.size || prevReq.lhs.size.bytes >= 3))
			{
				const hexAddr = "0x" + addrVal.toString(16).toUpperCase();
				if (suppressPointers)
					return `[... + ${hexAddr}]`;
				return `[Pointer ... + ${hexAddr}]`;
			}
		}

		return `Memory 0x${addrVal.toString(16).toUpperCase()}`;
	}

	// Shared Helper: Format values (0x10 vs 16)
	formatValue(op, index, contextAddress = null, contextSize = null, suppressBooleans = false)
	{
		if (contextAddress !== null && contextAddress !== undefined)
		{
			// 1. Check for Bit Label Value
			if (!suppressBooleans && contextSize && contextSize.name && contextSize.name.startsWith("Bit"))
			{
				let bitVal = -1;
				if (typeof op.value === 'string') bitVal = parseInt(op.value.replace("0x", ""), 16);
				else bitVal = op.value;

				if (bitVal === 0) return "false";
				if (bitVal === 1)
				{
					const bitLabel = this.tryGetBitLabel(contextAddress, contextSize, index);
					if (bitLabel) return `"${bitLabel}"`;
					return "true";
				}
			}

			// 2. Check for Enum Label using centralized formatter
            // If we are doing math (e.g. + 1), we don't want to substitute "1" with "Red" or "true".
            if (!suppressBooleans) 
            {
			    const chainInfo = this.buildChainInfo(index);
                
			    const enumLabel = ConditionFormatter.resolveEnum(
                    op.value, 
                    contextAddress, 
                    contextSize, 
                    this.notesLookup, 
                    chainInfo
                );
                
			    if (enumLabel) return `"${enumLabel}"`;
            }
		}

        // 3. Fallback formatting
        if (op.type === ReqType.FLOAT) return op.value.toString();

		if (typeof op.value === 'number')
		{
			if (this.showDecimal) return op.value.toString();
			return "0x" + op.value.toString(16).toUpperCase();
		}

		return op.value.toString();
	}

	// Shared Helper: Get operand text with prefix (delta/prior)
	getOperandText(op, index, isRight = false, contextAddress = null, contextSize = null, suppressPointers = false, suppressBooleans = false)
	{
        if (!op) return "";
		if (op.type === ReqType.RECALL) {
			if (this.lastRemembered) return `the stored value in ${this.lastRemembered}`;
			return "the stored value";
		}

		if (op.type === ReqType.VALUE || op.type === ReqType.FLOAT)
			return this.formatValue(op, index, contextAddress, contextSize, suppressBooleans);

		let prefix = "";
		if (op.type === ReqType.DELTA) prefix = "previous frame ";
		if (op.type === ReqType.PRIOR) prefix = "prior frame ";

		const name = this.getName(op, index, suppressPointers);
		return `${prefix}${name}`;
	}

	getOperatorText(op)
	{
		switch (op)
		{
			case "=": return "is";
			case "!=": return "is not";
			case "<": return "is less than";
			case "<=": return "is at most";
			case ">": return "is greater than";
			case ">=": return "is at least";
			default: return op;
		}
	}

	// Helper to reconstruct pointer chain info for ConditionFormatter
	buildChainInfo(index) {
		if (!this.group || index <= 0) return [];
		
		let chainContext = [];
		let stack = [];
		let scan = index - 1;
		while(scan >= 0) {
			if (scan >= this.group.length) { scan--; continue; }
			const req = this.group[scan];
			if (req.flag && req.flag.name === "AddAddress") {
				stack.unshift(req);
				scan--;
			} else {
				break;
			}
		}

        // Handle Array Indexing (Index + Base)
        // If the chain starts with an 8-bit or 16-bit AddAddress, it is likely an Index.
        // We REMOVE it from the chainContext used for resolving the Base Address.
        // This ensures ConditionFormatter looks up the Base Address directly in the notes,
        // rather than treating it as an offset inside the Index's note.
        if (stack.length > 0 && stack[0].lhs.size && stack[0].lhs.size.bytes < 3) {
            stack.shift();
        }

		for(let i=0; i<stack.length; i++) {
			const req = stack[i];
			if (chainContext.length === 0 && req.lhs.type.addr) {
				chainContext.push({ type: 'base', value: req.lhs.value });
			} else if (req.lhs.type.addr) {
				chainContext.push({ type: 'offset', value: req.lhs.value });
			}
			if (req.rhs && req.rhs.type.addr) {
				chainContext.push({ type: 'offset', value: req.rhs.value });
			}
		}
		return chainContext;
	}

	tryGetBitLabel(addrVal, size, index)
	{
		if (!size || !size.name || !size.name.startsWith("Bit")) return "";
		
		const bitChar = size.name.charAt(size.name.length - 1);
		const bitIndex = parseInt(bitChar, 10);
		if (isNaN(bitIndex)) return "";

		const chainInfo = this.buildChainInfo(index);
		let targetNode = null;
		
		let baseAddr = addrVal;
		let offsets = [];
		if (chainInfo.length > 0) {
			const baseObj = chainInfo.find(x => x.type === 'base');
			if (baseObj) {
				baseAddr = baseObj.value;
				offsets = chainInfo.filter(x => x.type === 'offset').map(x => x.value);
				offsets.push(addrVal);
			}
		}

		const note = ConditionFormatter.getEffectiveNote(this.notesLookup, baseAddr);
		
		if (note) {
			if (offsets.length === 0) {
				if (note.noteNodes) {
					targetNode = note.noteNodes.find(n => n.indentLevel === -2) || note.noteNodes[0];
				}
			} else if (note.noteNodes) {
				let currentLevelNodes = note.noteNodes.filter(n => n.indentLevel !== -2 && (!n.parent || n.parent.indentLevel === -1));
				
				const parseOff = (s) => {
					let clean = s.replace('+', '').replace('-', '').trim();
					if (clean.startsWith("0x")) clean = clean.substring(2);
					let v = parseInt(clean, 16);
					if (s.includes('-')) v = -v;
					return v;
				};

				for (let i = 0; i < offsets.length; i++) {
					const off = offsets[i];
					let match = null;
					for (const n of currentLevelNodes) {
						const nOff = parseOff(n.offset);
						if (off >= nOff && off < nOff + n.size) {
							match = n;
							break;
						}
					}
					if (match) {
						if (i === offsets.length - 1) targetNode = match;
						else currentLevelNodes = match.children;
					} else {
						break;
					}
				}
			}
		}

		if (!targetNode && this.rangeCache && offsets.length === 0) {
			const match = this.rangeCache.find(r => addrVal >= r.start && addrVal < r.end);
			if (match && match.node) targetNode = match.node;
		}

		if (targetNode)
		{
			return this.parseBitLabelFromContent(targetNode.content, bitIndex);
		}
		return "";
	}

	parseBitLabelFromContent(content, bitIndex)
	{
		if (!content) return "";
		const lines = content.split(/\r\n|\r|\n/);
		const regex = new RegExp(`^\\s*Bit\\s*${bitIndex}\\s*[:=]\\s*(.+)`, "i");

		for (const line of lines)
		{
			const match = line.match(regex);
			if (match) return match[1].trim();
		}
		return "";
	}
}

class LogicProcessor
{
	get priority() { return 100; }
	canProcess(conditions, index) { return false; }
	process(ctx, conditions, index) { return new ProcessorResult(); }
}

// Handles Pointer Chain Setup (AddAddress) - Priority 5
class PointerCleanupProcessor extends LogicProcessor
{
	get priority() { return 5; }
	canProcess(conditions, index) { return conditions[index].flag && conditions[index].flag.name === "AddAddress"; }
	process(ctx, conditions, index)
	{
		return new ProcessorResult("", ExplanationCategory.Context, 1);
	}
}

// Fallback Processor - Priority 100
class StandardConditionProcessor extends LogicProcessor
{
	get priority() { return 100; }
	canProcess(conditions, index) { return true; }
	
	process(ctx, conditions, index)
	{
		const cond = conditions[index];

		if (cond.flag && cond.flag.name === "AddAddress")
			return new ProcessorResult("", ExplanationCategory.Context, 1);

		if (cond.lhs.type === ReqType.VALUE && cond.rhs && cond.rhs.type === ReqType.VALUE)
		{
			if (cond.op === "=")
			{
				if (cond.lhs.value === cond.rhs.value) 
				{
					// Display hit count for dummy conditions as they are often used as frame timers
					if (cond.hits > 0)
						return new ProcessorResult(`Always True (Dummy Condition) for ${cond.hits} frames`, ExplanationCategory.Context, 1);
					return new ProcessorResult("Always True (Dummy Condition)", ExplanationCategory.Context, 1);
				}
				else 
					return new ProcessorResult("Always False", ExplanationCategory.Context, 1);
			}
		}

		if (cond.lhs.type === ReqType.MEM && cond.rhs && cond.rhs.type === ReqType.DELTA && cond.lhs.value === cond.rhs.value)
		{
			const name = ctx.getName(cond.lhs, index);
			let chg = "compares";
			switch(cond.op) {
				case ">": chg = "increases"; break;
				case "<": chg = "decreases"; break;
				case "!=": chg = "changes"; break;
				case "=": chg = "remains unchanged"; break;
			}
			return new ProcessorResult(`${name} ${chg}`, ExplanationCategory.Transition, 1);
		}

		if (cond.op === "&")
		{
			const bitExplanation = this.tryExplainBitwise(cond, ctx, index);
			if (bitExplanation)
				return new ProcessorResult(bitExplanation, ExplanationCategory.Context, 1);
		}

		let left = ctx.getOperandText(cond.lhs, index);
        
        // Suppress boolean formatting for arithmetic operations
        const isArithmetic = ['+', '-', '*', '/', '%'].includes(cond.op);
        
		let right = cond.rhs ? ctx.getOperandText(cond.rhs, index, true, cond.lhs.value, cond.lhs.size, false, isArithmetic) : "";
		let op = ctx.getOperatorText(cond.op);

		let hits = "";
		if (cond.hits > 0)
		{
			if (cond.hits === 1) hits = " (once)";
			else hits = ` (once this happens ${cond.hits} times)`;
		}

        // Handle friendly name from context or raw token
		if (left === "the stored value" || left.includes("{recall}")) left = "recalled value";
        
		let text = `${left} ${op} ${right}${hits}`;

		if (cond.flag && cond.flag.name === "MeasuredIf")
		{
			return new ProcessorResult(
				`The Measured condition will work if ${text} (MeasuredIf)`,
				ExplanationCategory.MeasuredIf,
				1
			);
		}

        const isDelta = cond.lhs.type === ReqType.DELTA || cond.lhs.type === ReqType.PRIOR || (cond.rhs && cond.rhs.type === ReqType.DELTA);
		const cat = isDelta ? ExplanationCategory.Transition : ExplanationCategory.Context;

		return new ProcessorResult(text, cat, 1);
	}

	tryExplainBitwise(cond, ctx, index)
	{
		if (!cond.rhs || cond.rhs.type !== ReqType.VALUE) return "";
		const maskVal = cond.rhs.value;
		if (maskVal <= 0) return "";

		if ((maskVal & (maskVal - 1)) === 0)
		{
			const bitIndex = Math.log2(maskVal);
			const name = ctx.getName(cond.lhs, index);
			return `${name} has Bit ${bitIndex} set`;
		}
		return "";
	}
}

// --------------------------------------------------
// Complex Logic Processors (1/2)
// --------------------------------------------------

// Handles ResetIf - Priority 30
class ResetProcessor extends LogicProcessor
{
	get priority() { return 30; }
	canProcess(conditions, index) { return conditions[index].flag && conditions[index].flag.name === "ResetIf"; }

	process(ctx, conditions, index)
	{
		const res = new StandardConditionProcessor().process(ctx, conditions, index);
		res.text = `If ${res.text}, reset the achievement.`;
		res.category = ExplanationCategory.Reset;
		return res;
	}
}

// Handles PauseIf - Priority 40
class PauseProcessor extends LogicProcessor
{
	get priority() { return 40; }
	canProcess(conditions, index) { return conditions[index].flag && conditions[index].flag.name === "PauseIf"; }

	process(ctx, conditions, index)
	{
		const res = new StandardConditionProcessor().process(ctx, conditions, index);
		const cond = conditions[index];
		const action = cond.hits > 0 ? "lock the achievement until a Reset occurs (PauseLock)" : "pause the achievement";
		res.text = `If ${res.text}, ${action}.`;
		res.category = ExplanationCategory.Pause;
		return res;
	}
}

// Handles Measured / Trigger - Priority 50
class MeasuredTriggerProcessor extends LogicProcessor
{
	get priority() { return 50; }
	canProcess(conditions, index)
	{
		const f = conditions[index].flag ? conditions[index].flag.name : "";
		// Exclude MeasuredIf
		return (f.startsWith("Measured") && f !== "MeasuredIf") || f === "Trigger";
	}

	process(ctx, conditions, index)
	{
		const cond = conditions[index];
		const f = cond.flag ? cond.flag.name : "";

		// 1. Handle Trigger
		if (f === "Trigger")
		{
			// Dummy triggers
			if (cond.lhs.type === ReqType.VALUE && cond.rhs.type === ReqType.VALUE)
			{
				return new ProcessorResult("", ExplanationCategory.Complex, 1);
			}

			const res = new StandardConditionProcessor().process(ctx, conditions, index);
			res.category = ExplanationCategory.Complex;
			return res;
		}

		// 2. Handle Measured with Hits (e.g. "Increases up to 8")
		if (cond.hits > 0)
		{
			// Delegate to Standard/Transition logic to describe WHAT is happening
			const stdRes = new StandardConditionProcessor().process(ctx, conditions, index);

			return new ProcessorResult(
				`A Measured Indicator will start measuring: ${stdRes.text} up to ${cond.hits}`,
				ExplanationCategory.Complex,
				1
			);
		}

		// 3. Standard Value Measurement
		// Pass LHS address/size as context to RHS
		const name = ctx.getOperandText(cond.lhs, index);
        
        // Handle cases where RHS/Operator is missing
        let limit = "";
        if (cond.rhs) {
		    limit = ctx.getOperandText(cond.rhs, index, true, cond.lhs.value, cond.lhs.size);
        }
        
		let text = "";

		if (f === "Measured%") text = `${name} as %`;
		else
		{
            if (!cond.op) {
                text = name;
            }
			else if (cond.op === "=" || cond.op === ">=" || cond.op === ">")
				text = `${name} up to ${limit}`;
			else
				text = `${name} (${ctx.getOperatorText(cond.op)} ${limit})`;
		}

		return new ProcessorResult(
			`A Measured Indicator will start measuring: ${text}`,
			ExplanationCategory.Complex,
			1
		);
	}
}

// Handles Remember - Priority 60
class RememberProcessor extends LogicProcessor
{
	get priority() { return 60; }
	canProcess(conditions, index) { return conditions[index].flag && conditions[index].flag.name === "Remember"; }

	process(ctx, conditions, index)
	{
		// 1. Look Ahead: Is this Remember feeding into an Accumulator (AddHits/Source) that uses {recall}?
		// If so, we hide this line because the AccumulatorProcessor will explain it contextually
		// (e.g., "Start measuring the stored value...").
		if (index + 1 < conditions.length)
		{
			const nextFlag = conditions[index + 1].flag ? conditions[index + 1].flag.name : "";
			if (nextFlag.includes("Add") || nextFlag.includes("Sub"))
			{
				let scan = index + 1;
				let usesRecall = false;
				while (scan < conditions.length)
				{
					const c = conditions[scan];
					const cFlag = c.flag ? c.flag.name : "";

					// Stop if we hit the end of the accumulator chain
					if (!cFlag.includes("Add") && !cFlag.includes("Sub") && !cFlag.includes("Next") && cFlag !== "AddAddress")
						break;

					if (c.lhs.type === ReqType.RECALL || (c.rhs && c.rhs.type === ReqType.RECALL))
					{
						usesRecall = true;
						break;
					}
					scan++;
				}

				if (usesRecall)
				{
                    // Only hide this line if it is a "Transition Calculation" (Delta/Mem subtraction).
                    // If it is a value definition (e.g. Mem + 1), we SHOULD display it so the user knows what "the stored value" is.
                    const cond = conditions[index];
                    const isTransitionCalc = cond.op === "-" && 
                        ((cond.lhs.type === ReqType.DELTA && cond.rhs && cond.rhs.type === ReqType.MEM) || 
                         (cond.lhs.type === ReqType.MEM && cond.rhs && cond.rhs.type === ReqType.DELTA));

                    if (isTransitionCalc) {
					    // Return empty text to "consume" this line silently.
					    // The AccumulatorProcessor will pick up the context from this line.
					    return new ProcessorResult("", ExplanationCategory.Context, 1);
                    }
				}
			}
		}

		// 2. Transition Logic (Increase/Decrease calculation)
		const cond = conditions[index];
		const leftIsDelta = cond.lhs.type === ReqType.DELTA;
		const rightIsMem = cond.rhs && cond.rhs.type === ReqType.MEM;
		const sameAddr = cond.rhs && cond.lhs.value === cond.rhs.value;

		if (leftIsDelta && rightIsMem && sameAddr && cond.op === "-")
		{
			const name = ctx.getName(cond.lhs, index);
			return new ProcessorResult(`Store the amount ${name} decreased by`, ExplanationCategory.Context, 1);
		}
		if (cond.lhs.type === ReqType.MEM && cond.rhs && cond.rhs.type === ReqType.DELTA && sameAddr && cond.op === "-")
		{
			const name = ctx.getName(cond.lhs, index);
			return new ProcessorResult(`Store the amount ${name} increased by`, ExplanationCategory.Context, 1);
		}

		// 3. Standard Storage Logic
		// We use the standard processor to resolve names/values, but we wrap the output text.
		const stdProcessor = new StandardConditionProcessor();
		const res = stdProcessor.process(ctx, conditions, index);

        // Capture the logic string of what is being stored.
        ctx.lastRemembered = res.text;

		if (!cond.op) // No operator means we are just remembering a value/address
		{
			// We can grab the name directly here to be safe.
			const name = ctx.getName(cond.lhs, index);
			res.text = `Store ${name}`;
            ctx.lastRemembered = name; // Update with the clean name
		}
		else
		{
			// Operator exists means we are remembering the result of a comparison (1 or 0)
            // OR the result of an arithmetic operation (e.g. Mem + Value)
			res.text = `Store result: ${res.text}`;
		}

		// Force category to Context so it appears at the top of the explanation block
		// This ensures the "Store" action is read before the "Trigger" action that uses it.
		res.category = ExplanationCategory.Context;

		return res;
	}
}

// Handles AndNext / OrNext / ResetNextIf chains - Priority 0 (Top Priority)
class AndNextProcessor extends LogicProcessor
{
	get priority() { return 0; }
	canProcess(conditions, index) 
	{
		const f = conditions[index].flag ? conditions[index].flag.name : "";
		return f === "AndNext" || f === "OrNext" || f === "ResetNextIf";
	}

	process(ctx, conditions, index)
	{
		const chainItems = []; 
		const resetConditions = [];
		const combinedDrillDowns = {}; // Collect drilldowns from steps and target

		let ptr = index;

		// 1. Consume the chain
		while (ptr < conditions.length)
		{
			const cond = conditions[ptr];
			const f = cond.flag ? cond.flag.name : "";

			if (f === "AddAddress") {
				ptr++;
				continue;
			}

			if (f !== "AndNext" && f !== "OrNext" && f !== "ResetNextIf") break;

            // Fallback to StandardConditionProcessor
            let stepRes = null;
            const transProc = new TransitionProcessor();
            if (transProc.canProcess(conditions, ptr)) {
                stepRes = transProc.process(ctx, conditions, ptr);
            } else {
                stepRes = new StandardConditionProcessor().process(ctx, conditions, ptr);
            }

			// Propagate drilldowns from chain steps
			Object.assign(combinedDrillDowns, stepRes.detailedDrillDowns);

            // Determine the connector
            // Check flags on the start/end of the step to find the connector flag
            const lastConsumedIndex = ptr + stepRes.conditionsConsumed - 1;
            const firstCond = conditions[ptr];
            const lastCond = conditions[lastConsumedIndex];

            const fFirst = firstCond.flag ? firstCond.flag.name : "";
            const fLast = lastCond.flag ? lastCond.flag.name : "";

            // If the last condition of the step (e.g. the end of a Transition)
            // does NOT have a chaining flag, this step is actually the Target (or the end of the chain).
            // We must break here to allow the Target Resolution phase to handle it properly,
            // rather than swallowing it as a "connector" and merging it with the next unrelated condition.
            const isLastChaining = (fLast === "AndNext" || fLast === "OrNext" || fLast === "ResetNextIf");
            if (!isLastChaining) {
                break;
            }

            let effectiveFlag = "";
            if (fFirst === "AndNext" || fFirst === "OrNext" || fFirst === "ResetNextIf") effectiveFlag = fFirst;
            else if (fLast === "AndNext" || fLast === "OrNext" || fLast === "ResetNextIf") effectiveFlag = fLast;

			if (effectiveFlag === "ResetNextIf") {
				resetConditions.push(stepRes.text);
			} else {
				const connector = (effectiveFlag === "OrNext") ? "OR" : "AND";
				chainItems.push({ text: stepRes.text, connector: connector });
			}

			ptr += stepRes.conditionsConsumed;
		}

		// 2. Skip AddAddress
		while (ptr < conditions.length && conditions[ptr].flag && conditions[ptr].flag.name === "AddAddress")
		{
			ptr++;
		}

		let resultText = "";
		let consumed = ptr - index;
		let category = ExplanationCategory.Context;

		if (ptr < conditions.length)
		{
			// 3. Resolve Target
			const processors = [
				new TransitionProcessor(),
				new AsciiStringProcessor(),
				new AccumulatorProcessor(),
				new MeasuredTriggerProcessor(),
				new ResetProcessor(),
				new PauseProcessor(),
				new MathChainProcessor(), 
				new StandardConditionProcessor()
			]; 

			let targetRes = null;
			for (const proc of processors) {
				if (proc.canProcess(conditions, ptr)) {
					targetRes = proc.process(ctx, conditions, ptr);
					break;
				}
			}

			// Propagate drilldowns from the target
			if (targetRes) {
				Object.assign(combinedDrillDowns, targetRes.detailedDrillDowns);
				consumed += targetRes.conditionsConsumed;
				category = targetRes.category;
			} else {
				// Fallback safety (should rarely happen given processors list)
				targetRes = { text: "Unknown Logic", conditionsConsumed: 1 };
				consumed += 1;
			}

			// 4. Build Final Logic String
			if (chainItems.length > 0)
			{
				let targetText = targetRes.text;
				const measuredHeader = "A Measured Indicator will start measuring: ";

				// Measured Logic
				if (targetText.startsWith(measuredHeader))
				{
					let sb = measuredHeader;
					// Append the body (what is being measured)
					sb += targetText.substring(measuredHeader.length);

					// Append the condition clause at the end
					sb += " when (";
					for (let k = 0; k < chainItems.length; k++)
					{
						const item = chainItems[k];
						sb += item.text;
						if (k < chainItems.length - 1) sb += ` ${item.connector} `;
					}
					sb += ")";
					resultText = sb;
				}
				else
				{
					let prefixWrapper = "";
					let suffixWrapper = "";

					if (category === ExplanationCategory.MeasuredIf)
					{
						const p = "The Measured condition will work if ";
						const s = " (MeasuredIf)";
						if (targetText.startsWith(p) && targetText.endsWith(s)) {
							prefixWrapper = p; suffixWrapper = s;
							targetText = targetText.substring(p.length, targetText.length - s.length);
						}
					}
					else if (category === ExplanationCategory.Reset)
					{
						const p = "If "; const s = ", reset the achievement.";
						if (targetText.startsWith(p) && targetText.endsWith(s)) {
							prefixWrapper = p; suffixWrapper = s;
							targetText = targetText.substring(p.length, targetText.length - s.length);
						}
					}
					else if (category === ExplanationCategory.Pause)
					{
						const p = "If ";
						if (targetText.startsWith(p)) {
							const lastComma = targetText.lastIndexOf(',');
							if (lastComma > p.length) {
								prefixWrapper = p;
								suffixWrapper = targetText.substring(lastComma);
								targetText = targetText.substring(p.length, lastComma);
							}
						}
					}
					else if (targetText.startsWith("Calculate: "))
					{
						targetText = targetText.substring(11);
					}

					let sb = prefixWrapper + "(";
					for (const item of chainItems)
					{
						sb += item.text + ` ${item.connector} `;
					}
					sb += targetText + ")" + suffixWrapper;
					resultText = sb;
				}
			}
			else
			{
				resultText = targetRes.text;
			}

			if (resetConditions.length > 0)
			{
				const resets = resetConditions.join(" OR ");
				resultText += ` (resets if ${resets})`;
			}
		}
		else
		{
			let sb = "";
			for (const item of chainItems) sb += `${item.text} ${item.connector} `;
			resultText = `${sb} (Incomplete Chain)`;
		}

		const result = new ProcessorResult(resultText, category, consumed);
		result.detailedDrillDowns = combinedDrillDowns;
		return result;
	}
}

// Handles Delta Transitions - Priority 01
class TransitionProcessor extends LogicProcessor
{
	get priority() { return 1; }

	canProcess(conditions, index)
	{
		// AddAddress lines are structural (pointer arithmetic) and should never be interpreted 
		// as value transitions, even if they technically look like "Mem & Value".
		if (conditions[index].flag && conditions[index].flag.name === "AddAddress") return false;

		// 1. Is Head?
		if (this.findPairIndex(conditions, index) !== -1) return true;
		
        // 2. Is Tail?
        const headIdx = this.findHeadIndex(conditions, index);
		if (headIdx !== -1) {
            // Only claim (and silence) the tail if the transition was contiguous (not interrupted).
            // This ensures ResetNextIf on the tail is not hidden.
            if (!this.isInterrupted(conditions, headIdx, index)) return true;
        }
        
		return false;
	}

	process(ctx, conditions, index)
	{
		// Case 1: Tail (Silence)
        // We only reach here if canProcess returned true, which means it's a non-interrupted tail.
		const headIdx = this.findHeadIndex(conditions, index);
		if (headIdx !== -1)
		{
			return new ProcessorResult("", ExplanationCategory.Transition, 1);
		}

		// Case 2: Head
		const pairIndex = this.findPairIndex(conditions, index);
		if (pairIndex === -1) return new StandardConditionProcessor().process(ctx, conditions, index);

		const condA = conditions[index];
		const condPair = conditions[pairIndex];
		const aIsDelta = condA.lhs.type === ReqType.DELTA || condA.lhs.type === ReqType.PRIOR;
		
		const name = ctx.getName(condA.lhs, index);
		const prevCond = aIsDelta ? condA : condPair;
		const currCond = !aIsDelta ? condA : condPair;

		const prevVal = ctx.formatValue(prevCond.rhs, conditions.indexOf(prevCond), condA.lhs.value, condA.lhs.size);
		const currVal = ctx.formatValue(currCond.rhs, conditions.indexOf(currCond), condA.lhs.value, condA.lhs.size);

        // Detect Prior to distinguish from Delta
        const isPrior = prevCond.lhs.type === ReqType.PRIOR;
        const prevLabel = isPrior ? " (Prior)" : "";

		let suffix = "";
		const currFlag = currCond.flag ? currCond.flag.name : "";
		if (currFlag === "Measured%") suffix = ". This condition also acts as a Measured% indicator";
		else if (currFlag.startsWith("Measured")) suffix = `. This condition will also display a Measured Indicator`;

		let text = "";
		const valuesMatch = prevVal === currVal;

		if (prevCond.op === "=" && currCond.op === "=")
		{
			// Check if values are identical to say "stays at" instead of "changes from X to X"
			if (valuesMatch) text = `${name} stays at ${currVal}${suffix}`;
			else text = `${name} changes from ${prevVal}${prevLabel} to ${currVal}${suffix}`;
		}
		else if (prevCond.op === "!=" && currCond.op === "=" && valuesMatch)
			text = `${name} becomes ${currVal}${suffix}`;
		else if (prevCond.op === "=" && currCond.op === "!=" && valuesMatch)
			text = `${name} changed from ${prevVal}${prevLabel}${suffix}`;
		else if (prevCond.op === "<" && currCond.op === ">=" && valuesMatch)
			text = `${name} increases to at least ${currVal}${suffix}`;
		else if (prevCond.op === "<=" && currCond.op === ">" && valuesMatch)
			text = `${name} increases to more than ${currVal}${suffix}`;
		else if (prevCond.op === ">" && currCond.op === "<=" && valuesMatch)
			text = `${name} decreases to at most ${currVal}${suffix}`;
		else if (prevCond.op === ">=" && currCond.op === "<" && valuesMatch)
			text = `${name} decreases to less than ${currVal}${suffix}`;
		else
		{
            // Grammar normalization
            const cleanOp = (txt) => {
                if (txt === "is") return "";
                if (txt.startsWith("is ")) return txt.substring(3);
                return txt;
            };

			const prevOp = cleanOp(ctx.getOperatorText(prevCond.op));
			const currOp = cleanOp(ctx.getOperatorText(currCond.op));
            
            const prevOpStr = prevOp ? ` ${prevOp}` : "";
            const currOpStr = currOp ? ` ${currOp}` : "";

			text = `${name} was${prevOpStr} ${prevVal}${prevLabel} and is now${currOpStr} ${currVal}${suffix}`;
		}

		let category = ExplanationCategory.Transition;

		// Check flags for special behavior (Reset/Pause)
		const flagA = condA.flag ? condA.flag.name : "";
		const flagB = condPair.flag ? condPair.flag.name : "";

		if (flagA === "ResetIf" || flagB === "ResetIf") {
			text = `If ${text}, reset the achievement.`;
			category = ExplanationCategory.Reset;
		} else if (flagA === "PauseIf" || flagB === "PauseIf") {
			const pauseCond = (flagA === "PauseIf") ? condA : condPair;
			const action = pauseCond.hits > 0 ? "lock the achievement until a Reset occurs (PauseLock)" : "pause the achievement";
			text = `If ${text}, ${action}.`;
			category = ExplanationCategory.Pause;
		}

		const isInterrupted = this.isInterrupted(conditions, index, pairIndex);
		
		return new ProcessorResult(
			text, 
			category,
			isInterrupted ? 1 : (pairIndex - index) + 1
		);
	}

	findPairIndex(conditions, index)
	{
		const condA = conditions[index];
		if (condA.hits > 0 || !condA.rhs || condA.rhs.type !== ReqType.VALUE) return -1;
		
		const aIsDelta = condA.lhs.type === ReqType.DELTA || condA.lhs.type === ReqType.PRIOR;
		const aIsMem = condA.lhs.type === ReqType.MEM;
		if (!aIsDelta && !aIsMem) return -1;

		for (let j = index + 1; j < conditions.length; j++)
		{
			const condB = conditions[j];
			if (condB.flag && condB.flag.name === "AddAddress") continue;

			const f = condB.flag ? condB.flag.name : "";
            
			const isValidFlag = !f || f === "Trigger" || f === "ResetIf" || f === "PauseIf" || f.startsWith("Measured") || f === "AndNext" || f === "OrNext" || f === "ResetNextIf";
			if (!isValidFlag) return -1;

			if (condB.hits > 0 || !condB.rhs || condB.rhs.type !== ReqType.VALUE) continue;

			const bIsDelta = condB.lhs.type === ReqType.DELTA || condB.lhs.type === ReqType.PRIOR;
			const bIsMem = condB.lhs.type === ReqType.MEM;

			if ((aIsDelta && bIsDelta) || (aIsMem && bIsMem)) continue;

			if (condA.lhs.value === condB.lhs.value && condA.lhs.size === condB.lhs.size)
			{
				return j;
			}
		}
		return -1;
	}

	findHeadIndex(conditions, index)
	{
		const condB = conditions[index];
		if (condB.hits > 0 || !condB.rhs || condB.rhs.type !== ReqType.VALUE) return -1;
		
		const bIsDelta = condB.lhs.type === ReqType.DELTA || condB.lhs.type === ReqType.PRIOR;
		const bIsMem = condB.lhs.type === ReqType.MEM;
		if (!bIsDelta && !bIsMem) return -1;

		for (let j = index - 1; j >= 0; j--)
		{
			const condA = conditions[j];
			if (condA.flag && condA.flag.name === "AddAddress") continue;

			if (condA.hits > 0 || !condA.rhs || condA.rhs.type !== ReqType.VALUE) continue;

			const aIsDelta = condA.lhs.type === ReqType.DELTA || condA.lhs.type === ReqType.PRIOR;
			const aIsMem = condA.lhs.type === ReqType.MEM;

			if ((aIsDelta && bIsDelta) || (aIsMem && bIsMem)) continue;
			if (!aIsDelta && !aIsMem) continue;

			if (condA.lhs.value === condB.lhs.value && condA.lhs.size === condB.lhs.size)
			{
				if (this.findPairIndex(conditions, j) === index) return j;
			}
		}
		return -1;
	}

	isInterrupted(conditions, start, end)
	{
		for (let k = start + 1; k < end; k++)
		{
			if (!conditions[k].flag || conditions[k].flag.name !== "AddAddress") return true;
		}
		return false;
	}
}

// Handles Sequence Processing (0->1, 1->2) - Priority 14
class SequenceProcessor extends LogicProcessor
{
	get priority() { return 14; }
	canProcess(conditions, index)
	{
		if (index + 3 >= conditions.length) return false;

		if (!this.isTransitionPair(conditions[index], conditions[index+1])) return false;
		if (!this.isTransitionPair(conditions[index+2], conditions[index+3])) return false;

		if (conditions[index].lhs.value !== conditions[index+2].lhs.value) return false;

		const c1 = conditions[index+1];
		const c2 = conditions[index+2];
		if (!c1.rhs || !c2.rhs) return false;

		const end1 = this.parseValue(c1.rhs.value);
		const start2 = this.parseValue(c2.rhs.value);

		return end1 === start2;
	}

	process(ctx, conditions, index)
	{
		let currentIdx = index;
		let conditionsConsumed = 0;

		const variableName = ctx.getName(conditions[index].lhs, index);
		const startValStr = ctx.formatValue(conditions[index].rhs, index, conditions[index].lhs.value, conditions[index].lhs.size);

		let lastEndValue = -1;
		let lastEndIndex = -1;

		while (currentIdx + 1 < conditions.length)
		{
			const condA = conditions[currentIdx];
			const condB = conditions[currentIdx + 1];

			if (!this.isTransitionPair(condA, condB)) break;
			if (condA.lhs.value !== conditions[index].lhs.value) break;

			const valA = this.parseValue(condA.rhs.value);
			const valB = this.parseValue(condB.rhs.value);

			if (conditionsConsumed > 0)
			{
				if (valA !== lastEndValue) break;
			}

			lastEndValue = valB;
			lastEndIndex = currentIdx + 1;

			currentIdx += 2;
			conditionsConsumed += 2;
		}

		const lastCond = conditions[lastEndIndex];
		const endValStr = ctx.formatValue(lastCond.rhs, lastEndIndex, lastCond.lhs.value, lastCond.lhs.size);

		return new ProcessorResult(
			`${variableName} increments sequentially from ${startValStr} to ${endValStr} (step-by-step)`,
			ExplanationCategory.Complex,
			conditionsConsumed
		);
	}

	isTransitionPair(a, b)
	{
		const flagA = a.flag ? a.flag.name : "";
		if (flagA !== "AndNext") return false;

		const aIsPriorOrDelta = a.lhs.type === ReqType.PRIOR || a.lhs.type === ReqType.DELTA;
		const bIsMem = b.lhs.type === ReqType.MEM;

		if (!aIsPriorOrDelta || !bIsMem) return false;
		if (a.lhs.value !== b.lhs.value) return false;

		return true;
	}

	parseValue(val)
	{
		if (typeof val === 'number') return val;
		const clean = val.toString().trim().replace("0x", "");
		return parseInt(clean, 16);
	}
}

// Handles ASCII Strings - Priority 2
class AsciiStringProcessor extends LogicProcessor
{
	get priority() { return 2; }
	
	canProcess(conditions, index)
	{
		const cond = conditions[index];
		if (cond.lhs.type !== ReqType.MEM || !cond.rhs || cond.rhs.type !== ReqType.VALUE || cond.op !== "=") return false;
		
		const flag = cond.flag ? cond.flag.name : "";
		if (flag && flag !== "Trigger") return false;

		return true;
	}

	process(ctx, conditions, index)
	{
		const startCond = conditions[index];
		const varName = ctx.getName(startCond.lhs, index);
		
		const rawDescription = this.getRawNoteDescription(ctx, startCond.lhs.value, index);
		const isExplicit = /ASCII|Region|Serial|Text|String/i.test(rawDescription);

		return this.processExplicitString(ctx, conditions, index, varName, isExplicit);
	}

	getRawNoteDescription(ctx, addressVal, index)
	{
        // 1. Reconstruct Pointer Chain Info
        const chainInfo = ctx.buildChainInfo(index);
        
        // 2. Determine Base Address
        let baseAddr = addressVal;
        let offsets = [];
        
        if (chainInfo.length > 0) {
            const baseObj = chainInfo.find(x => x.type === 'base');
            if (baseObj) {
                baseAddr = baseObj.value;
                offsets = chainInfo.filter(x => x.type === 'offset').map(x => x.value);
                // Add the final offset (the address of the current condition)
                offsets.push(addressVal);
            }
        }

        // 3. Get Base Note (with Redirects)
        const note = ConditionFormatter.getEffectiveNote(ctx.notesLookup, baseAddr);
        if (!note) return "";

        // 4. Traverse Node Tree
        let targetNode = null;

        if (offsets.length === 0) {
            // Direct Note
            if (note.noteNodes) {
                targetNode = note.noteNodes.find(n => n.indentLevel === -2) || note.noteNodes[0];
            }
            if (!targetNode) return note.note; 
        } else if (note.noteNodes) {
            // Pointer Traversal
            let currentLevelNodes = note.noteNodes.filter(n => n.indentLevel !== -2 && (!n.parent || n.parent.indentLevel === -1));
            
            const parseOff = (s) => {
                let clean = s.replace('+', '').replace('-', '').trim();
                if (clean.startsWith("0x")) clean = clean.substring(2);
                let v = parseInt(clean, 16);
                if (s.includes('-')) v = -v;
                return v;
            };

            for (let i = 0; i < offsets.length; i++) {
                const off = offsets[i];
                let match = null;
                
                for (const n of currentLevelNodes) {
                    const nOff = parseOff(n.offset);
                    if (off >= nOff && off < nOff + n.size) {
                        match = n;
                        break;
                    }
                }

                if (match) {
                    if (i === offsets.length - 1) {
                        targetNode = match;
                    } else {
                        currentLevelNodes = match.children;
                    }
                } else {
                    break;
                }
            }
        }

        if (targetNode) {
            return targetNode.description || targetNode.content || "";
        }
        
		return "";
	}

	processExplicitString(ctx, conditions, index, baseName, forceStringMode)
	{
		const startCond = conditions[index];
		let collectedBytes = [];
		let collectedHex = "";
		let count = 0;
        
        // Helper to get effective address of a condition by resolving its pointer chain
        const resolveEffectiveAddress = (idx) => {
            const chainInfo = ctx.buildChainInfo(idx);
            let baseAddr = conditions[idx].lhs.value;
            let offsetSum = 0;
            
            if (chainInfo.length > 0) {
                const baseObj = chainInfo.find(x => x.type === 'base');
                if (baseObj) baseAddr = baseObj.value;
                
                chainInfo.filter(x => x.type === 'offset').forEach(off => {
                    offsetSum += off.value;
                });
            }
            return conditions[idx].lhs.value;
        };

		let currentAddr = resolveEffectiveAddress(index);
		let currentSize = this.getByteSize(startCond.lhs.size); 
        
        // Capture initial pointer chain structure to ensure subsequent lines match the same pointer
        const getPointerFingerprint = (idx) => {
            const chain = ctx.buildChainInfo(idx);
            if (chain.length === 0) return "";
            const base = chain.find(x => x.type === 'base');
            return base ? base.value.toString() : "";
        };
        
        const startFingerprint = getPointerFingerprint(index);

		const processValue = (val, sizeObj) => {
			let size = this.getByteSize(sizeObj);
			let isBigEndian = sizeObj && sizeObj.name && sizeObj.name.includes("BE");
			
			collectedHex += val.toString(16).toUpperCase().padStart(size*2, '0');

			if (isBigEndian) {
				for (let b = size - 1; b >= 0; b--) {
					collectedBytes.push((val >> (b * 8)) & 0xFF);
				}
			} else {
				for (let b = 0; b < size; b++) {
					collectedBytes.push((val >> (b * 8)) & 0xFF);
				}
			}
		};

		processValue(startCond.rhs.value, startCond.lhs.size);
		count++;
        
        // Track total lines consumed (including skipped AddAddress lines)
        let totalLinesConsumed = 1; 

		let scan = index + 1;
		while (scan < conditions.length)
		{
            // SKIP: AddAddress lines (we assume they are setting up the next check)
            let skippedLines = 0;
            while (scan < conditions.length && conditions[scan].flag && conditions[scan].flag.name === "AddAddress") {
                scan++;
                skippedLines++;
            }
            
            if (scan >= conditions.length) break;

			const next = conditions[scan];
            
			const nextFlag = next.flag ? next.flag.name : "";
			const startFlag = startCond.flag ? startCond.flag.name : "";

			if (nextFlag !== startFlag) break;
			if (next.lhs.type !== ReqType.MEM || !next.rhs || next.rhs.type !== ReqType.VALUE || next.op !== "=") break;

            // Check if it belongs to the same Pointer (if applicable)
            if (startFingerprint && getPointerFingerprint(scan) !== startFingerprint) break;

			const nextAddr = next.lhs.value; // This is the offset if inside a pointer chain
			if (nextAddr !== currentAddr + currentSize) break;

			const nextSize = this.getByteSize(next.lhs.size);
			processValue(next.rhs.value, next.lhs.size);

			currentAddr = nextAddr;
			currentSize = nextSize;
			count++;
            
            // Add skipped lines to total
            totalLinesConsumed += 1 + skippedLines;
            
			scan++;
		}

		if (count > 1 || (count === 1 && forceStringMode))
		{
			if (!forceStringMode)
			{
				if (collectedBytes.length < 3) return new StandardConditionProcessor().process(ctx, conditions, index);
				const printable = collectedBytes.filter(b => b >= 0x20 && b <= 0x7E).length;
				if ((printable / collectedBytes.length) < 0.7) return new StandardConditionProcessor().process(ctx, conditions, index);
			}

			let cleanName = baseName.replace(/\s*\+0x[0-9A-Fa-f]+/g, "");
			if (cleanName.startsWith("[") && cleanName.endsWith("]")) cleanName = cleanName.substring(1, cleanName.length - 1);
			cleanName = cleanName.trim();

			let asciiString = collectedBytes.map(b => (b >= 0x20 && b <= 0x7E) ? String.fromCharCode(b) : ".").join("");
			
			const prefix = count === 1 ? "String at" : `${count} grouped`;
			const addrText = count === 1 ? "address" : "addresses";

			return new ProcessorResult(
				`${prefix} ${cleanName} ${addrText} is "${asciiString}" (0x${collectedHex})`,
				ExplanationCategory.Context,
				totalLinesConsumed 
			);
		}

		return new StandardConditionProcessor().process(ctx, conditions, index);
	}

	getByteSize(sizeObj)
	{
		if (!sizeObj) return 4;
		const name = sizeObj.name || sizeObj;
		if (name.includes("8-bit")) return 1;
		if (name.includes("16-bit")) return 2;
		if (name.includes("24-bit")) return 3;
		if (name.includes("32-bit")) return 4;
		return 4;
	}
}

// Handles Math Chains - Priority 10
class MathChainProcessor extends LogicProcessor
{
	get priority() { return 10; }

	canProcess(conditions, index)
	{
		const cond = conditions[index];
		const f = cond.flag ? cond.flag.name : "";
		
		if (f !== "Remember") return false;
		
		const op = cond.op;
		return (op === "+" || op === "-" || op === "*" || op === "/" || op === "%");
	}

	process(ctx, conditions, index)
	{
		let ptr = index;
		let currentExpression = "";
		let chainEnded = false;

		// 1. Build the Mathematical Expression
		while (ptr < conditions.length && !chainEnded)
		{
			const cond = conditions[ptr];
			const f = cond.flag ? cond.flag.name : "";

			// Skip AddAddress lines so they don't break the math chain
			if (f === "AddAddress")
			{
				ptr++;
				continue;
			}

			if (f !== "Remember")
			{
				chainEnded = true;
				continue;
			}

			if (!cond.op)
			{
				chainEnded = true;
				continue;
			}

			const op = cond.op;
			let left = "";
			let right = "";

			// Get Operand Text
			if (cond.lhs.type === ReqType.RECALL) left = currentExpression;
			else left = ctx.getOperandText(cond.lhs, ptr, false, "", "", true);

			// Check RHS Safety
			// Pass true for suppressBooleans since we are in arithmetic context
			if (cond.rhs && cond.rhs.type === ReqType.RECALL) right = currentExpression;
			else if (cond.rhs) right = ctx.getOperandText(cond.rhs, ptr, true, cond.lhs.value, cond.lhs.size, true, true);
			else right = "0"; // Fallback

			// Simplify 0+X, X*1, etc.
			const leftIsZero = this.isZero(cond.lhs);
			const rightIsZero = cond.rhs ? this.isZero(cond.rhs) : true;
			const leftIsOne = this.isOne(cond.lhs);
			const rightIsOne = cond.rhs ? this.isOne(cond.rhs) : false;

			if (op === "+")
			{
				if (leftIsZero) currentExpression = right;
				else if (rightIsZero) currentExpression = left;
				else currentExpression = `(${left} + ${right})`;
			}
			else if (op === "-" && rightIsZero)
			{
				currentExpression = left;
			}
			else if (op === "*" && (leftIsOne || rightIsOne))
			{
				currentExpression = leftIsOne ? right : left;
			}
			else if (op === "/" && rightIsOne)
			{
				currentExpression = left;
			}
			else
			{
				// Wrap previous expression if needed
				if (currentExpression && currentExpression.includes(" "))
				{
					if (cond.lhs.type === ReqType.RECALL) left = `(${left})`;
					if (cond.rhs && cond.rhs.type === ReqType.RECALL) right = `(${right})`;
				}

				currentExpression = `${left} ${op} ${right}`;
			}

			ptr++;
		}

        // Update context with the calculated expression so subsequent steps (like Accumulators)
        // can refer to "the stored value in [expression]"
        if (currentExpression) {
            // Clean up outer parens for display cleanliness
            if (currentExpression.startsWith("(") && currentExpression.endsWith(")")) {
                ctx.lastRemembered = currentExpression.substring(1, currentExpression.length - 1);
            } else {
                ctx.lastRemembered = currentExpression;
            }
        }

        // 2. Look Ahead: Is this Math Chain feeding into an Accumulator that uses {recall}?
        // If so, consume this line silently. The AccumulatorProcessor will explain the context ("increasing"/"decreasing").
        if (ptr < conditions.length)
        {
            const nextFlag = conditions[ptr].flag ? conditions[ptr].flag.name : "";
            if (nextFlag.includes("Add") || nextFlag.includes("Sub"))
            {
                let scan = ptr;
                let usesRecall = false;
                while (scan < conditions.length)
                {
                    const c = conditions[scan];
                    const f = c.flag ? c.flag.name : "";
                    
                    if (!f.includes("Add") && !f.includes("Sub") && !f.includes("Next") && f !== "AddAddress")
                        break;

                    // Check LHS or RHS for Recall
                    // Safety check for RHS
                    if (c.lhs.type === ReqType.RECALL || (c.rhs && c.rhs.type === ReqType.RECALL))
                    {
                        usesRecall = true;
                        break;
                    }
                    scan++;
                }

                if (usesRecall)
                {
                    // Return empty text to "consume" these lines silently.
                    return new ProcessorResult("", ExplanationCategory.Context, ptr - index);
                }
            }
        }

		// 3. Process Result Checks
		let sb = `Calculate: ${currentExpression}\n`;

        // Scan the lines we just processed (from index to ptr) to see if we skipped any 
        // AddAddress lines that use {recall}. If so, explicitly state that the result is used as an offset.
        for (let k = index; k < ptr; k++) {
            const c = conditions[k];
            if (c.flag && c.flag.name === "AddAddress" && c.lhs.type === ReqType.RECALL) {
                 sb += `- Calculated result is used as an address offset\n`;
            }
        }

		let consumed = ptr - index;

		while (ptr < conditions.length)
		{
			const cond = conditions[ptr];
			const f = cond.flag ? cond.flag.name : "";

			// Skip AddAddress lines here too
            // We already caught them in the loop above for display purposes if they used Recall
			if (f === "AddAddress")
			{
				consumed++;
				ptr++;
				continue;
			}

			const leftIsRecall = cond.lhs.type === ReqType.RECALL;
			const rightIsRecall = cond.rhs && cond.rhs.type === ReqType.RECALL;

			if (!leftIsRecall && !rightIsRecall) break;

			if (f === "Measured%")
			{
				const limit = leftIsRecall
					? (cond.rhs ? ctx.getOperandText(cond.rhs, ptr) : "0")
					: ctx.getOperandText(cond.lhs, ptr);

				sb += `- Display result as % (Limit: ${limit})\n`;
				consumed++;
				ptr++;
				continue;
			}

			if (!f || f === "Trigger" || f === "MeasuredIf")
			{
				const opText = ctx.getOperatorText(cond.op);
				const compareVal = leftIsRecall
					? (cond.rhs ? ctx.getOperandText(cond.rhs, ptr) : "0")
					: ctx.getOperandText(cond.lhs, ptr);

				const prefix = f === "MeasuredIf" ? "Only measure if" : "Require";
				sb += `- ${prefix} result ${opText} ${compareVal}\n`;

				consumed++;
				ptr++;
				continue;
			}
			break;
		}

		return new ProcessorResult(sb.trim(), ExplanationCategory.Complex, consumed);
	}

	isZero(op)
	{
		if (op.type === ReqType.FLOAT) return parseFloat(op.value) === 0;
		if (op.type === ReqType.VALUE) return op.value === 0;
		return false;
	}

	isOne(op)
	{
		if (op.type === ReqType.FLOAT) return parseFloat(op.value) === 1.0;
		if (op.type === ReqType.VALUE) return op.value === 1;
		return false;
	}
}

// Handles Accumulator Chains (Add Source/Hits) - Priority -1
class AccumulatorProcessor extends LogicProcessor
{
	get priority() { return -1; }

	canProcess(conditions, index)
	{
		const cond = conditions[index];
		const f = cond.flag ? cond.flag.name : "";

		// 1. Direct Accumulator Start
		if (f === "AddSource" || f === "SubSource" || f === "AddHits" || f === "SubHits") return true;

		// 2. Logic Chain Start
		const isPotentialLead = f === "AddAddress" || f === "AndNext" || f === "OrNext" || f === "ResetNextIf";
		if (isPotentialLead)
		{
			let scan = index + 1;
			while (scan < conditions.length)
			{
				const sf = conditions[scan].flag ? conditions[scan].flag.name : "";
				if (sf === "AddAddress" || sf === "AndNext" || sf === "OrNext" || sf === "ResetNextIf")
				{
					scan++;
					continue;
				}
				if (sf.includes("Add") || sf.includes("Sub")) return true;
				break;
			}
		}
		return false;
	}

	process(ctx, conditions, index)
	{
		// Skip if consumed via Lookahead
		if (ctx.processedIndices.has(index))
		{
			const { endPtr } = this.extractChain(conditions, index);
			return new ProcessorResult("", ExplanationCategory.Complex, (endPtr - index) + 1);
		}

		const result = new ProcessorResult("", ExplanationCategory.Complex);
		const chains = [];
		let currentPtr = index;

		// Collect Chains Loop
		while (currentPtr < conditions.length)
		{
			if (ctx.processedIndices.has(currentPtr)) break;

			const { chain, endPtr } = this.extractChain(conditions, currentPtr);
			
			if (chain.length === 0)
			{
				if (chains.length > 0)
				{
					// Check for barriers
					const currCond = conditions[currentPtr];
					const f = currCond.flag ? currCond.flag.name : "";
					if (f === "ResetIf" || f === "PauseIf" || f === "OrNext") break;
					currentPtr++;
					continue;
				}
				else break;
			}

			// Verify Accumulator Action
			const hasAcc = chain.some(c => {
				const f = c.flag ? c.flag.name : "";
				return f === "AddSource" || f === "SubSource" || f === "AddHits" || f === "SubHits";
			});

			if (!hasAcc)
			{
				if (chains.length > 0) {
					currentPtr = endPtr + 1;
					continue;
				}
				break;
			}

			// Valid Chain Found
			let termCond = null;
			if (endPtr < conditions.length) termCond = conditions[endPtr];

			// Link Check
			if (chains.length > 0) {
				const prev = chains[chains.length - 1];
				const prevConnected = prev.terminal && (prev.terminal.flag && (prev.terminal.flag.name === "OrNext" || prev.terminal.flag.name === "AndNext"));
				const skippedLines = currentPtr > (prev.endIndex + 1);
				if (prevConnected && skippedLines) break;

                // Stop grouping if transitioning from Measured to MeasuredIf
                // This ensures MeasuredIf is treated as a conditional ("once...") rather than merged into the measurement string.
                const lastIsMeasured = prev.terminal && prev.terminal.flag && prev.terminal.flag.name.startsWith("Measured") && prev.terminal.flag.name !== "MeasuredIf";
                const currentIsMeasuredIf = termCond && termCond.flag && termCond.flag.name === "MeasuredIf";

                if (lastIsMeasured && currentIsMeasuredIf) {
                    break;
                }
			}

			const chainDef = {
				conditions: chain,
				terminal: termCond,
				startIndex: currentPtr,
				endIndex: endPtr
			};

			// Terminal Stealing Logic
			if (chains.length > 0 && chainDef.conditions.length > 0)
			{
				const prev = chains[chains.length - 1];
				const first = chainDef.conditions[0];
				const ff = first.flag ? first.flag.name : "";
				
				const isNakedGate = (ff === "AndNext" || ff === "OrNext" || ff === "ResetNextIf");
				if (!prev.terminal && isNakedGate)
				{
					prev.terminal = first;
					chainDef.conditions.shift();
					if (chainDef.conditions.length === 0 || !chainDef.conditions.some(c => c.flag && (c.flag.name.includes("Add") || c.flag.name.includes("Sub"))))
					{
						currentPtr = chainDef.startIndex + 1;
						continue;
					}
				}
			}

			chains.push(chainDef);

			if (chains.length > 1) ctx.processedIndices.add(currentPtr);

			const hasExplicitConnector = termCond && termCond.flag && (termCond.flag.name === "AndNext" || termCond.flag.name === "OrNext");
			if (hasExplicitConnector) {
				currentPtr = endPtr + 1;
			} else {
				currentPtr = endPtr + 1;
			}
		}

		if (chains.length === 0) return new StandardConditionProcessor().process(ctx, conditions, index);

		// --- RECALL CONTEXT ---
		let recallContext = "";
		let hasRecallContext = false;
		if (index > 0 && conditions[index-1].flag && conditions[index-1].flag.name === "Remember")
		{
			const remCond = conditions[index-1];
			const chainUsesRecall = chains.some(ch => ch.conditions.some(c => c.lhs.type === ReqType.RECALL || (c.rhs && c.rhs.type === ReqType.RECALL)));
			
            if (chainUsesRecall)
			{
				let targetOp = null;
				let direction = "";
				if (remCond.op === "-")
				{
					if (remCond.lhs.type === ReqType.DELTA && remCond.rhs.type === ReqType.MEM) { targetOp = remCond.rhs; direction = "decreasing"; }
					else if (remCond.lhs.type === ReqType.MEM && remCond.rhs.type === ReqType.DELTA) { targetOp = remCond.lhs; direction = "increasing"; }
				}

				if (targetOp) {
					const varName = ctx.getName(targetOp, index - 1, true);
					recallContext = `${varName} ${direction}`;
					hasRecallContext = true;
				} else {
					recallContext = "stored value";
				}
			}
		}

		// --- TRANSITION ANALYSIS ---
		const deltaChains = chains.filter(c => this.isChainDelta(c.conditions));
		const memChains = chains.filter(c => !this.isChainDelta(c.conditions));
        const hasHitsLogic = chains.some(ch => ch.conditions.some(c => c.flag && (c.flag.name === "AddHits" || c.flag.name === "SubHits")));

		let isTransition = false;
		if (!hasHitsLogic && deltaChains.length > 0 && memChains.length > 0)
		{
			const lastDelta = deltaChains[deltaChains.length - 1];
			const termFlag = (lastDelta.terminal && lastDelta.terminal.flag) ? lastDelta.terminal.flag.name : "";
			if (!lastDelta.terminal || termFlag !== "OrNext")
			{
				isTransition = true;
			}
		}

		if (isTransition)
		{
            const fromText = this.buildCondensedChainString(deltaChains, ctx, conditions);
            const toText = this.buildCondensedChainString(memChains, ctx, conditions);

            const rawBlocks = this.prepareDisplayBlocks(chains[0]);
            const displayBlocks = this.deduplicateBlocks(rawBlocks, ctx);

            const id = crypto.randomUUID();
            result.detailedDrillDowns[id] = this.generateChainDetails(displayBlocks, ctx, chains[0].terminal);
            
            const expandToken = `[[EXPAND:${id}:Show ${displayBlocks.length} conditions]]`;

            let suffix = "";
            const finalMemChain = memChains[memChains.length - 1];
            if (finalMemChain.terminal && finalMemChain.terminal.flag)
            {
                const f = finalMemChain.terminal.flag.name;
                if (f === "ResetIf") suffix = " (ResetIf)";
                else if (f === "PauseIf") suffix = " (PauseIf)";
            }

            result.text = `Sum of ${displayBlocks.length} items ${expandToken} changes from (${fromText}) to (${toText})${suffix}`;
            result.category = ExplanationCategory.Transition;
            
            if (chains.length > 0) {
                result.conditionsConsumed = (chains[0].endIndex - chains[0].startIndex) + 1;
            }
            
            return result;
		}

		// --- MEASURED CONTEXT DETECTION ---
		let finalTerminal = chains.length > 0 ? chains[chains.length - 1].terminal : null;
		let isMeasuredContext = false;
		let measuredHeader = "";

		const lastChainEnd = chains[chains.length - 1].endIndex;
		if (lastChainEnd + 1 < conditions.length)
		{
			const nextCond = conditions[lastChainEnd + 1];
			const chainsUseHits = chains.some(ch => ch.conditions.some(c => c.flag && c.flag.name.includes("Hits")) || (ch.terminal && ch.terminal.flag && ch.terminal.flag.name.includes("Hits")));
			if (chainsUseHits && nextCond.flag && nextCond.flag.name.startsWith("Measured") && nextCond.hits > 0)
			{
				finalTerminal = nextCond;
				isMeasuredContext = true;
			}
		}

		if (!isMeasuredContext && finalTerminal && finalTerminal.flag && finalTerminal.flag.name.startsWith("Measured") && finalTerminal.flag.name !== "MeasuredIf")
		{
			isMeasuredContext = true;
		}

		if (isMeasuredContext && finalTerminal)
		{
			const isHitChain = chains.some(ch => ch.conditions.some(c => c.flag && c.flag.name.includes("Hits"))) || (finalTerminal.flag && finalTerminal.flag.name.includes("Hits"));
			const label = isHitChain ? "hits" : "value";
            const rhsVal = finalTerminal.rhs ? ctx.formatValue(finalTerminal.rhs, conditions.indexOf(finalTerminal)) : "0";
			const valText = (finalTerminal.hits > 0) ? finalTerminal.hits.toString() : rhsVal;

            if (hasRecallContext) {
                // If we have a specific recall context (e.g. "Var increasing"), we will fold it into the chain text 
                // to avoid the redundancy of "Start measuring Var increasing ... when sum of ... Var increasing ...".
                measuredHeader = "Start measuring";
            } else {
			    measuredHeader = `Start measuring ${label} up to ${valText}`;
            }
			result.category = ExplanationCategory.Complex;
		}

		let sb = "";
		let isTriggerStart = !isMeasuredContext;
		let i = 0;

		while (i < chains.length)
		{
			const chainTemplate = chains[i];
            
			const currentChainUsesRecall = chainTemplate.conditions.some(c => c.lhs.type === ReqType.RECALL || (c.rhs && c.rhs.type === ReqType.RECALL));
			
            const chainHasHits = chainTemplate.conditions.some(c => c.flag && c.flag.name.includes("Hits"));
			const ignoreTerminal = isMeasuredContext && chainHasHits;

			// Array Detection
			let rangeEnd = i;
			while (rangeEnd + 1 < chains.length)
			{
				if (this.areChainsStructureEqual(chains[i], chains[rangeEnd + 1], true, ignoreTerminal)) rangeEnd++;
				else break;
			}

			const count = (rangeEnd - i) + 1;

			if (count > 3)
			{
				// Array Logic
				const lastChain = chains[rangeEnd];
				const terminal = lastChain.terminal;
                
                // Use Recall Context but avoid redundancy if already in header
				let noun = "logic groups";
                if (hasRecallContext && currentChainUsesRecall) {
                    noun = recallContext;
                }

				let showVal = true;
				if (isMeasuredContext) showVal = false;
				else if (chainHasHits && (!terminal || terminal.hits === 0)) showVal = false;

                const termRhsSafe = (terminal && terminal.rhs) ? terminal.rhs : {value:0, type:ReqType.VALUE};
				const valText = (terminal && terminal.hits > 0) ? terminal.hits.toString() : (terminal ? ctx.formatValue(termRhsSafe, conditions.indexOf(terminal)) : "(varies)");
				
				let prefix = "";
				if (isTriggerStart)
				{
					if (terminal && terminal.flag && terminal.flag.name === "PauseIf") prefix = "Pause when ";
					else if (terminal && terminal.flag && terminal.flag.name === "ResetIf") prefix = "Reset when ";
                    else if (terminal && terminal.flag && terminal.flag.name === "Trigger") prefix = "Trigger when ";
					else prefix = "Activate when ";
					isTriggerStart = false;
				}

				// Details
				let sbDetails = "";
				for (let k = i; k <= rangeEnd; k++)
				{
					const c = chains[k];
                    const cTermRhs = (c.terminal && c.terminal.rhs) ? c.terminal.rhs : {value:0, type:ReqType.VALUE};
					const instanceVal = (c.terminal && c.terminal.hits > 0) ? c.terminal.hits.toString() : ctx.formatValue(cTermRhs, 0);
					
                    const firstAdd = c.conditions.find(cond => cond.flag && (cond.flag.name.includes("Add") || cond.flag.name.includes("Sub")));
					const name = firstAdd ? ctx.getName(firstAdd.lhs, 0) : `Item ${k - i + 1}`;
					sbDetails += `- ${name} ... ${instanceVal}\n`;
				}

				const id = crypto.randomUUID();
				result.detailedDrillDowns[id] = sbDetails;
				
                const expandToken = `[[EXPAND:${id}:Show ${count} groups]]`;

				const summary = showVal
					? `${prefix}any of the following ${count} ${noun} match (at least ${valText}): ${expandToken}`
					: `${prefix}any of the following ${count} ${noun} match: ${expandToken}`;
				
				sb += summary;
				if (rangeEnd < chains.length - 1)
				{
					const conn = (terminal && terminal.flag && terminal.flag.name === "OrNext") ? " OR " : " AND ";
					sb += conn;
				}
				i = rangeEnd + 1;
			}
			else
			{
				// Single Chain
				const chain = chains[i];
				const rawBlocks = this.prepareDisplayBlocks(chain);
				const displayBlocks = this.deduplicateBlocks(rawBlocks, ctx);
				
				const id = crypto.randomUUID();
				result.detailedDrillDowns[id] = this.generateChainDetails(displayBlocks, ctx, chain.terminal);
                
				const expandToken = `[[EXPAND:${id}:Show ${displayBlocks.length} conditions]]`;
				
				let chainText = "";
				if (chain.terminal)
				{
					const term = chain.terminal;
                    
					let noun = "items";
                    if (hasRecallContext && currentChainUsesRecall) {
                        noun = recallContext;
                    } else if (isMeasuredContext) {
                        noun = "events";
                    }
                    
					const tFlag = term.flag ? term.flag.name : "";

                    const termRhsSafe = term.rhs ? term.rhs : {value:0, type:ReqType.VALUE};

					if (tFlag === "MeasuredIf")
					{
						const valText = ctx.formatValue(termRhsSafe, conditions.indexOf(term));
						const opText = ctx.getOperatorText(term.op);
						chainText = `Accumulator: sum of ${displayBlocks.length} ${noun} ${expandToken} ${opText} ${valText} (MeasuredIf)`;
						result.category = ExplanationCategory.MeasuredIf;
						isTriggerStart = false;
					}
					else if (tFlag.startsWith("Measured"))
					{
						const valText = (term.hits > 0) ? term.hits.toString() : ctx.formatValue(termRhsSafe, conditions.indexOf(term));
						const opText = ctx.getOperatorText(term.op);
						
						if (isMeasuredContext)
						{
                            if (hasRecallContext && currentChainUsesRecall) {
                                chainText = `sum of ${displayBlocks.length} ${noun} ${expandToken} up to ${valText}`;
                            } else {
                                // Simplified display: Just show the expandable details token
                                // This removes redundant "sum of N events... is X" text
							    chainText = `${expandToken}`;
                            }
						}
						else
						{
							const isHitChain = chain.conditions.some(c => c.flag && c.flag.name.includes("Hits")) || tFlag.includes("Hits");
							const label = isHitChain ? "hits" : "value";
							chainText = hasRecallContext
								? `Start measuring ${recallContext} up to ${valText}: ${expandToken}`
								: `Start measuring ${label} up to ${valText}: ${expandToken}`;
							isTriggerStart = false;
						}
					}
					else
					{
						const isHitChain = chain.conditions.some(c => c.flag && c.flag.name.includes("Hits"));
						let showVal = true;
						if (isMeasuredContext) showVal = false;
						else if (isHitChain && term.hits === 0) showVal = false;

						let valText = "";
                        let opText = "";
                        
                        if (term.rhs) {
                            valText = (term.hits > 0) ? term.hits.toString() : ctx.formatValue(termRhsSafe, conditions.indexOf(term));
                            opText = ctx.getOperatorText(term.op);
                        }

						let prefix = "";
                        if (tFlag === "PauseIf") {
                            prefix = (term.hits > 0) ? "Lock the achievement (PauseLock) when " : "Pause the achievement when ";
                            result.category = ExplanationCategory.Pause;
                        } else if (tFlag === "ResetIf") {
                            prefix = "Reset the achievement when ";
                            result.category = ExplanationCategory.Reset;
                        } else if (isTriggerStart) {
                            if (tFlag === "Trigger") prefix = "Trigger when ";
                            else prefix = "Accumulator: ";
                        }
                        
                        // Reset trigger start for next loop unless we just set it
                        isTriggerStart = false;

						if (isHitChain)
						{
							if (showVal)
								chainText = hasRecallContext
									? `${prefix}${recallContext} occurs at least ${valText} times: ${expandToken}`
									: `${prefix}at least ${valText} hits of the following occur: ${expandToken}`;
							else
								chainText = `${prefix}the following occur: ${expandToken}`;
						}
						else
						{
                            if (opText && valText) {
							    chainText = `${prefix}sum of ${displayBlocks.length} ${noun} ${expandToken} ${opText} ${valText}`;
                            } else {
                                chainText = `${prefix}sum of ${displayBlocks.length} ${noun} ${expandToken}`;
                            }
						}
					}

					if (i < chains.length - 1)
					{
						const conn = tFlag === "OrNext" ? " OR " : " AND ";
						chainText += conn;
					}
				}
				else
				{
					const noun = (hasRecallContext && currentChainUsesRecall) ? recallContext : "Logic sequence";
					chainText = `${noun} ${expandToken} (Incomplete)`;
				}
				sb += chainText;
				i++;
			}
		}

        if (isMeasuredContext) {
            if (hasRecallContext) {
                // If we have a recall context (and thus customized chainText "up to X"),
                // we merge simply by space instead of " when ".
                result.text = `${measuredHeader} ${sb}`;
            } else {
                // Check if sb is simplified (starts with expand token).
                // If so, join with space. If not, use " when ".
                const joiner = sb.trim().startsWith("[[EXPAND:") ? " " : " when ";
                result.text = `${measuredHeader}${joiner}${sb}`;
            }
        } else {
		    result.text = sb;
        }

		if (chains.length > 0) {
			result.conditionsConsumed = (chains[0].endIndex - chains[0].startIndex) + 1;
		} else {
			result.conditionsConsumed = 1;
		}

		return result;
	}

	extractChain(conditions, start)
	{
		const chain = [];
		let ptr = start;
		let buffer = [];
		let hasAccumulator = false;
        let accumType = ""; // Track context

		while (ptr < conditions.length)
		{
			const c = conditions[ptr];
			const f = c.flag ? c.flag.name : "";

			if (f === "AddAddress")
			{
				buffer.push(c);
			}
			else if (f === "AndNext" || f === "OrNext" || f === "ResetNextIf")
			{
                const isSourceMath = accumType === "AddSource" || accumType === "SubSource";
				if (hasAccumulator && f === "OrNext" && isSourceMath) break;
				
                buffer.push(c);
			}
			else if (f.includes("Add") || f.includes("Sub"))
			{
				hasAccumulator = true;
                accumType = f;
				chain.push(...buffer);
				buffer = [];
				chain.push(c);
			}
			else
			{
				break; // Terminal
			}
			ptr++;
		}

		if (!hasAccumulator && chain.length === 0) return { chain: [], endPtr: start };
		
		chain.push(...buffer);
		return { chain: chain, endPtr: ptr };
	}

	prepareDisplayBlocks(chain)
	{
		const blocks = [];
		let currentBlock = [];

		for (const c of chain.conditions)
		{
			currentBlock.push(c);
			const f = c.flag ? c.flag.name : "";
			if (f === "AddSource" || f === "SubSource" || f === "AddHits" || f === "SubHits")
			{
				blocks.push([...currentBlock]);
				currentBlock = [];
			}
		}
		if (currentBlock.length > 0) blocks.push(currentBlock);

		if (chain.terminal)
		{
			const t = chain.terminal;
			const isDummy = t.lhs.type === ReqType.VALUE && t.rhs && t.rhs.type === ReqType.VALUE;
			
            if (!isDummy)
			{
				if (blocks.length > 0 && blocks[blocks.length-1].every(c => c.flag && c.flag.name === "AddAddress"))
				{
					blocks[blocks.length-1].push(t);
				}
				else
				{
					blocks.push([t]);
				}
			}
		}
		return blocks;
	}

	deduplicateBlocks(blocks, ctx)
	{
		const unique = [];
		const seen = new Set();
		
		for (const block of blocks)
		{
			if (block.length === 0) continue;
			const leaf = block[block.length - 1];
			
			if (leaf.lhs.type === ReqType.RECALL) {
				unique.push(block);
				continue;
			}

			const idx = ctx.group.indexOf(leaf);
			const name = ctx.getName(leaf.lhs, idx, false);
            
            const rhsVal = leaf.rhs ? leaf.rhs.value : "null";
			const signature = `${name} ${leaf.op} ${rhsVal}`;
			
			if (!seen.has(signature)) {
				seen.add(signature);
				unique.push(block);
			}
		}
		return unique;
	}

	generateChainDetails(blocks, ctx, terminal)
	{
		let output = "";
		for (const block of blocks)
		{
            for (let i = 0; i < block.length; i++)
			{
                const c = block[i];
				if (c.flag && c.flag.name === "AddAddress") continue;
				const isTerm = (terminal && c === terminal);
				
				// Explain Single
				let left = ctx.getOperandText(c.lhs, ctx.group.indexOf(c), false, "", "", true);
				left = left.replace("previous frame ", "").replace("prior frame ", "");
				
				// Standard Handling:
				let fullText = left;
                const isArithmetic = ['+', '-', '*', '/', '%'].includes(c.op);

				if (c.op && c.rhs) {
                    if (c.op === '&') {
                         // Keep fullText as just 'left'
                    } else {
                        let right = ctx.getOperandText(c.rhs, ctx.group.indexOf(c), true, c.lhs.value, c.lhs.size, false, isArithmetic);
                        let op = ctx.getOperatorText(c.op);
                        let hits = (c.hits > 0) ? ` (occurs ${c.hits} times)` : "";
                        if (left.includes("{recall}")) left = "recalled value";
                        fullText = `${left} ${op} ${right}${hits}`;
                    }
				}

                let linePrefix = "- ";
				
                if (isTerm) {
                    // Terminal usually doesn't need special prefix in this list
				} else {
                    const flagName = c.flag ? c.flag.name : "";
                    if (flagName === "SubSource" || flagName === "SubHits") {
                        linePrefix = "- Subtract result of: ";
                    }
				}

                output += `${linePrefix}${fullText}\n`;
			}
		}
		return output.trim();
	}

	areChainsStructureEqual(c1, c2, ignoreAddresses, ignoreTerminal)
	{
		if (!ignoreTerminal)
		{
			if (!c1.terminal !== !c2.terminal) return false;
			
			if (c1.terminal && c2.terminal)
			{
				const flag1 = c1.terminal.flag ? c1.terminal.flag.name : "";
				const flag2 = c2.terminal.flag ? c2.terminal.flag.name : "";
				
				if (flag1 !== flag2) return false;
				if (c1.terminal.op !== c2.terminal.op) return false;
                
                if (!c1.terminal.rhs && !c2.terminal.rhs) {
                    // Match
                } else if (!c1.terminal.rhs || !c2.terminal.rhs) {
                    return false;
                } else {
				    if (c1.terminal.rhs.value !== c2.terminal.rhs.value) return false;
                }
			}
		}

		if (c1.conditions.length !== c2.conditions.length) return false;
		for (let i = 0; i < c1.conditions.length; i++)
		{
			const cond1 = c1.conditions[i];
			const cond2 = c2.conditions[i];
			const f1 = cond1.flag ? cond1.flag.name : "";
			const f2 = cond2.flag ? cond2.flag.name : "";
			
			if (f1 !== f2) return false;
			if (!ignoreAddresses && cond1.lhs.value !== cond2.lhs.value) return false;
			
            if (cond1.lhs.type !== cond2.lhs.type && f1 === "AddAddress") return false;
			if (cond1.lhs.size !== cond2.lhs.size) return false;
			if (cond1.op !== cond2.op) return false;
		}
		return true;
	}

	// Helpers for Transition Logic
	formatTerminalCondition(cond, ctx, conditions)
	{
		if (!cond) return "(No Check)";
        const rhsVal = cond.rhs ? ctx.formatValue(cond.rhs, conditions.indexOf(cond), cond.lhs.value, cond.lhs.size) : "0";
		const op = cond.op;
		if (op === "=") return rhsVal;
		return `${op} ${rhsVal}`;
	}

	buildCondensedChainString(chains, ctx, conditions)
	{
		let sb = "";
		let i = 0;
		while (i < chains.length)
		{
			let rangeEnd = i;
			while (rangeEnd + 1 < chains.length)
			{
				if (this.areChainsStructureEqual(chains[i], chains[rangeEnd + 1], false, false))
					rangeEnd++;
				else
					break;
			}

			if (i > 0)
			{
				const prev = chains[i - 1];
				const conn = (prev.terminal && prev.terminal.flag && prev.terminal.flag.name === "OrNext") ? " OR " : " AND ";
				sb += conn;
			}

			const termText = this.formatTerminalCondition(chains[i].terminal, ctx, conditions);
			sb += termText;

			if (rangeEnd > i)
			{
				sb += ` (x${rangeEnd - i + 1})`;
				i = rangeEnd + 1;
			}
			else
			{
				i++;
			}
		}
		return sb;
	}

    isChainDelta(chain) {
		return chain.filter(c => c.flag && c.flag.name !== "AddAddress")
			.some(c => c.lhs.type === ReqType.DELTA || c.lhs.type === ReqType.PRIOR);
	}
}

// --------------------------------------------------
// Main Controller
// --------------------------------------------------

class LogicExplainer
{
	static processors = [
		new PointerCleanupProcessor(),
		new AsciiStringProcessor(),
		new AccumulatorProcessor(),
		new SequenceProcessor(),
		new AndNextProcessor(),
		new TransitionProcessor(),
		new MathChainProcessor(),
		new ResetProcessor(),
		new PauseProcessor(),
		new MeasuredTriggerProcessor(),
		new RememberProcessor(),
		new StandardConditionProcessor()
	];

	static explainAsset(asset, groups, notesLookup, rangeCache, showDecimal)
	{
		let mainText = "";
		let detailedInfo = {}; // Map<string, string>

		if (!groups || groups.length === 0)
		{
			mainText += "No logic defined.";
			return { mainText, detailedInfo };
		}

		// 1. Explain Core Group
		if (groups.length > 0 && groups[0].length > 0)
		{
			mainText += "## Core Requirements (Must be true):\n";
			mainText += LogicExplainer.explainGroupNatural(groups[0], notesLookup, rangeCache, showDecimal, detailedInfo);
			mainText += "\n\n";
		}

		// 2. Process Alt Groups
		if (groups.length > 1)
		{
			const allAlts = groups.slice(1);
			const regularAlts = [];
			const globalResets = [];
			const displayLogic = [];

			for (let i = 0; i < allAlts.length; i++)
			{
				const alt = allAlts[i];
				if (alt.length > 0)
				{
					// Detect Global Resets (Alt containing ONLY ResetIfs)
					if (alt.every(c => c.flag && c.flag.name === "ResetIf"))
					{
						globalResets.push(alt);
					}
					// Detect Display/UX Logic
					else if (LogicExplainer.isGroupDisplayOnly(alt))
					{
						displayLogic.push({ group: alt, index: i + 1 });
					}
					else
					{
						regularAlts.push({ group: alt, index: i + 1 });
					}
				}
				else
				{
					// Empty alt? Treat as regular
					regularAlts.push({ group: alt, index: i + 1 });
				}
			}

			// 3. Explain Regular Alts
			if (regularAlts.length > 0)
			{
				mainText += "## Alternative Requirements (At least one set must be true):\n";
				mainText += LogicExplainer.processMergedGroups(regularAlts, notesLookup, rangeCache, showDecimal, detailedInfo, false);
			}

			// 4. Explain Display Logic
			if (displayLogic.length > 0)
			{
				mainText += "## Overlay / UX Logic (Does not trigger achievement):\n";
				mainText += LogicExplainer.processMergedGroups(displayLogic, notesLookup, rangeCache, showDecimal, detailedInfo, true);
			}

			// 5. Explain Global Resets
			if (globalResets.length > 0)
			{
				mainText += "## Global Reset Conditions (Applies to all):\n";
				const flatResets = globalResets.flat();
				const dummyCtx = new ExplanationContext([], notesLookup, rangeCache, showDecimal);
				const resetProc = new ResetProcessor();

				for (let k = 0; k < flatResets.length; k++)
				{
					const res = resetProc.process(dummyCtx, flatResets, k);
					mainText += `- ${res.text}\n`;
				}
			}
		}

		return { mainText, detailedInfo };
	}

	static processMergedGroups(groupWrappers, notes, range, showDec, details, isUxHeader)
	{
		let sb = "";
		const processedIndices = new Set();

		for (let i = 0; i < groupWrappers.length; i++)
		{
			if (processedIndices.has(i)) continue;

			const currentFP = LogicExplainer.getCoreLogicFingerprint(groupWrappers[i].group);
			const matchingIndices = [i];

			for (let j = i + 1; j < groupWrappers.length; j++)
			{
				if (processedIndices.has(j)) continue;
				if (LogicExplainer.getCoreLogicFingerprint(groupWrappers[j].group) === currentFP)
				{
					matchingIndices.push(j);
					processedIndices.add(j);
				}
			}

			if (matchingIndices.length > 1)
			{
				// Determine Sequential
				let isSequential = true;
				for (let k = 0; k < matchingIndices.length - 1; k++)
				{
					// Check if Wrapper Index (Alt Number) is sequential
					if (groupWrappers[matchingIndices[k+1]].index !== groupWrappers[matchingIndices[k]].index + 1)
					{
						isSequential = false;
						break;
					}
				}

				const isLargeGroup = matchingIndices.length > 4;

				if ((isSequential && matchingIndices.length > 2) || isLargeGroup)
				{
					// Array Logic
					const firstAlt = groupWrappers[matchingIndices[0]].index;
					const lastAlt = groupWrappers[matchingIndices[matchingIndices.length-1]].index;

					// Header Handling
					if (isSequential)
					{
						sb += `### Alt ${firstAlt} - Alt ${lastAlt} (Array Logic):\n`;
					}
					else
					{
						const names = matchingIndices.map(idx => `Alt ${groupWrappers[idx].index}`);
						let headerNames = "";

						if (names.length > 5)
						{
							const shortList = names.slice(0, 3).join(", ");
							const hiddenList = names.slice(3).join(", ");
							const listId = crypto.randomUUID();
							
							details[listId] = hiddenList;
							headerNames = `${shortList}... [[EXPAND:${listId}:and ${names.length - 3} more]]`;
						}
						else
						{
							headerNames = names.join(", ");
						}
						sb += `### ${headerNames} (Split Array Logic):\n`;
					}

					sb += `Activate when any of the following ${matchingIndices.length} slots match:\n`;

					const explanation = LogicExplainer.explainGroupNatural(groupWrappers[i].group, notes, range, showDec, details, isUxHeader);
					
					// Indent
					let sbIndent = "";
					const lines = explanation.split(/\r\n|\r|\n/);
					for (const line of lines) {
						if (line.trim()) sbIndent += "  " + line + "\n";
					}

					const arrayId = crypto.randomUUID();
					details[arrayId] = sbIndent.trim();
					sb += `[[EXPAND:${arrayId}:Array Details]]\n\n`;
				}
				else
				{
					// Multi-Region Logic
					const names = matchingIndices.map(idx => `Alt ${groupWrappers[idx].index}`);
					let headerNames = "";

					if (names.length > 5)
					{
						const shortList = names.slice(0, 3).join(", ");
						const hiddenList = names.slice(3).join(", ");
						const listId = crypto.randomUUID();
						
						details[listId] = hiddenList;
						headerNames = `${shortList}... [[EXPAND:${listId}:and ${names.length - 3} more]]`;
					}
					else
					{
						headerNames = names.join(", ");
					}

					sb += `### ${headerNames} (Multi-Region):\n`;
					
					const explanation = LogicExplainer.explainGroupNatural(groupWrappers[i].group, notes, range, showDec, details, isUxHeader, true);
					sb += explanation + "\n";
					sb += "- (Region specific locks apply)\n\n";
				}
			}
			else
			{
				// Single
				sb += `### Alt ${groupWrappers[i].index}:\n`;
				const explanation = LogicExplainer.explainGroupNatural(groupWrappers[i].group, notes, range, showDec, details, isUxHeader);
				sb += explanation + "\n\n";
			}
		}
		return sb;
	}

	static explainGroupNatural(group, notes, range, showDec, details, isUxHeader = false, filterRegionLocks = false)
	{
		const ctx = new ExplanationContext(group, notes, range, showDec);
		const results = [];
		let i = 0;

		while (i < group.length)
		{
			if (filterRegionLocks && group[i].flag && group[i].flag.name === "PauseIf")
			{
				i++;
				continue;
			}

			// Find Processor
			const sortedProcs = LogicExplainer.processors.sort((a, b) => a.priority - b.priority);
			const proc = sortedProcs.find(p => p.canProcess(group, i));
			
			const res = proc.process(ctx, group, i);

			// Merge details
			Object.assign(details, res.detailedDrillDowns);

			results.push(res);
			i += res.conditionsConsumed;
		}

		let sb = "";
		const hasMeasured = group.some(c => c.flag && c.flag.name.startsWith("Measured"));
		const hasTrigger = group.some(c => c.flag && c.flag.name === "Trigger");

		const isRemnant = (r) => {
			if (isUxHeader && hasMeasured && (r.text.startsWith("A Measured Indicator") || r.text.startsWith("Start measuring"))) return false;
			if (isUxHeader && r.category === ExplanationCategory.MeasuredIf) return false;
			if (!r.text) return false;
			if (isUxHeader && (r.text.startsWith("Always False") || r.text.startsWith("Always True"))) return false;
			return true;
		};

        // Find the main measured result for exclusion check
        const measuredRes = results.find(r => r.text.startsWith("A Measured Indicator") || r.text.startsWith("Start measuring"));
		const hasRemnants = results.some(isRemnant);

		if (isUxHeader)
		{
			if (hasMeasured)
			{
				if (measuredRes) sb += measuredRes.text;
				else sb += "A Measured Indicator will be displayed";

				const mIfs = results.filter(r => r.category === ExplanationCategory.MeasuredIf && r !== measuredRes);
				
                if (mIfs.length > 0)
				{
					sb += " once ";
					const cleanedIfs = mIfs.map(r => 
						r.text.replace("The Measured condition will work if ", "")
							  .replace(" (MeasuredIf)", "")
							  .replace(". (MeasuredIf)", "")
					);
					sb += cleanedIfs.join(" AND ");
					if (hasRemnants) sb += " and the following:\n";
					else sb += ".\n";
				}
				else
				{
					if (hasRemnants) sb += " once the following logic is satisfied:\n";
					else sb += ".\n";
				}
			}
			else if (hasTrigger)
			{
				if (hasRemnants) sb += "A Trigger Indicator is displayed once the following logic is satisfied:\n";
				else sb += "A Trigger Indicator is displayed.\n";
			}
			else
			{
				if (hasRemnants) sb += "Perform display logic when:\n";
				else sb += "Display logic active.\n";
			}
		}

		const cats = [
			ExplanationCategory.MeasuredIf,
			ExplanationCategory.Context,
			ExplanationCategory.Transition,
			ExplanationCategory.Complex,
			ExplanationCategory.Pause,
			ExplanationCategory.Reset
		];

		for (const cat of cats)
		{
			const catResults = results.filter(r => r.category === cat);
			if (cat === ExplanationCategory.Transition && catResults.length > 0)
			{
				const validLines = catResults.filter(isRemnant).map(r => r.text.replace(/\.$/, ""));
				if (validLines.length > 0)
					sb += `- Activate when ${validLines.join(" AND ")}.\n`;
			}
			else
			{
				for (const res of catResults)
				{
					if (!isRemnant(res)) continue;
					sb += `- ${res.text}\n`;
				}
			}
		}

		return sb.trim();
	}

	static isGroupDisplayOnly(group)
	{
		const hasUXFlag = group.some(c => (c.flag && c.flag.name.startsWith("Measured")) || (c.flag && c.flag.name === "Trigger"));
		if (!hasUXFlag) return false;

		let impossibleCount = 0;
		let validAccumulatorTerminators = 0;

		for (let i = 0; i < group.length; i++)
		{
			if (LogicExplainer.isConditionAlwaysFalse(group[i]))
			{
				impossibleCount++;
				if (i > 0)
				{
					const prevFlag = group[i-1].flag ? group[i-1].flag.name : "";
					if (prevFlag.includes("Add") || prevFlag.includes("Sub"))
					{
						validAccumulatorTerminators++;
					}
				}
			}
		}
		return impossibleCount > validAccumulatorTerminators;
	}

	static isConditionAlwaysFalse(c)
	{
		// Check RHS existence before accessing properties
		if (!c.lhs || !c.rhs || c.lhs.type !== ReqType.VALUE || c.rhs.type !== ReqType.VALUE) return false;
		const left = c.lhs.value;
		const right = c.rhs.value;

		switch(c.op) {
			case "=": return left !== right;
			case "!=": return left === right;
			case "<": return !(left < right);
			case "<=": return !(left <= right);
			case ">": return !(left > right);
			case ">=": return !(left >= right);
			default: return false;
		}
	}

	static getCoreLogicFingerprint(group)
	{
		let sb = "";
		let startIndex = 0;
		// Skip leading PauseIf (Region Locks)
		while (startIndex < group.length && group[startIndex].flag && group[startIndex].flag.name === "PauseIf")
		{
			startIndex++;
		}

		const isMem = (t) => t === ReqType.MEM || t === ReqType.DELTA || t === ReqType.PRIOR || t === ReqType.BCD || t === ReqType.INVERT;

		for (let i = startIndex; i < group.length; i++)
		{
			const c = group[i];
			sb += (c.flag ? c.flag.name : "") + "|";
			
			// Safety check for LHS
			if (c.lhs) {
				sb += (c.lhs.type ? c.lhs.type.name : "") + "|" + (c.lhs.size ? c.lhs.size.name : "") + "|";
				if (c.lhs.type && !isMem(c.lhs.type)) sb += c.lhs.value + "|";
				else sb += "MEM|";
			} else {
				sb += "NULL|NULL|NULL|";
			}

			sb += c.op + "|";

			// Safety check for RHS (it can be null)
			if (c.rhs) {
				sb += (c.rhs.type ? c.rhs.type.name : "") + "|" + (c.rhs.size ? c.rhs.size.name : "") + "|";
				if (c.rhs.type && !isMem(c.rhs.type)) sb += c.rhs.value + "|";
				else sb += "MEM|";
			} else {
				sb += "NULL|NULL|NULL|";
			}

			sb += c.hits + ";";
		}
		return sb;
	}
}