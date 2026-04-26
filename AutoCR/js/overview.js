const sidebar = ReactDOM.createRoot(document.getElementById('list-body'));
const container = ReactDOM.createRoot(document.getElementById('info-container'));
const filePicker = document.getElementById('file-picker');

var current = { id: -1, };

function clearSelected()
{
	for (let e of document.querySelectorAll('#list-body .selected'))
		e.classList.remove('selected');
}

function scrollTo(elem) { elem.scrollIntoView({behavior: 'smooth', block: 'nearest'}); }

function selectTab(tab)
{
	const ASSETLIST = document.getElementById('asset-list');
	for (let x of ASSETLIST.getElementsByClassName('selected'))
		x.classList.remove('selected');
	tab.classList.add('selected');

	scrollTo(tab);
	document.getElementById('asset-info').scrollTop = 0;
}

function reset_loaded()
{
	current.set = new AchievementSet();
	current.notes = new CodeNoteSet();
	current.rp = null;
	clearSelected();
}

document.getElementById('unload-set').addEventListener('click', () => {
	history.pushState(null, '', location.pathname);
	location.reload();
});

let submit_gameid = () => {	location.hash = '#!/game/' + document.getElementById('game-id').value; }
document.getElementById('load-game-id').addEventListener('click', submit_gameid);
document.getElementById('game-id').addEventListener('keyup', ({key}) => { if (key == 'Enter') submit_gameid(); });

filePicker.addEventListener('change', () => {
	load_files(filePicker.files);
});

function __noop(event)
{
	event.stopPropagation();
	event.preventDefault();
}

document.ondragover = __noop;
document.ondragenter = __noop;

document.ondrop = function(event)
{
	event.preventDefault();
	load_files(event.dataTransfer.files);
}

document.onkeydown = function(event)
{
	let handled = true;
	let crow = document.querySelector('.asset-row.selected');
	switch (event.key)
	{
		case "Up":
		case "ArrowUp":
			for (let n = crow.previousSibling; n; n = n.previousSibling)
				if (n.classList.contains('asset-row')) { n.click(); break; }
			break;
		case "Down":
		case "ArrowDown":
			for (let n = crow.nextSibling; n; n = n.nextSibling)
				if (n.classList.contains('asset-row')) { n.click(); break; }
			break;
		default:
			handled = false;
	}

	if (handled)
	{
		event.preventDefault();
		event.stopPropagation();
	}
}

function load_files(fileList)
{
	for (const file of fileList)
	{
		let idregex = file.name.match(/^(\d+)/);
		let thisid = +idregex[1] ?? -1;
		if (thisid != current.id)
		{
			current.id = thisid;
			reset_loaded();
		}
		
		let reader = new FileReader();
		if (file.name.endsWith('-Notes.json'))
			reader.onload = function(event)
			{
				let data = JSON.parse(event.target.result);
				load_code_notes(data);
			};
		else if (file.name.endsWith('.json'))
			reader.onload = function(event)
			{
				let data = JSON.parse(event.target.result);
				load_achievement_set(data);
			};
		else if (file.name.endsWith('-Rich.txt'))
			reader.onload = function(event)
			{
				let data = event.target.result;
				load_rich_presence(data, true);
			};
		else if (file.name.endsWith('-User.txt'))
			reader.onload = function(event)
			{
				let data = event.target.result;
				load_user_file(data);
			};
		reader.readAsText(file);
	}
}

function get_game_title()
{
	if (current.set) return current.set.title;
	return null;
}

async function copy_to_clipboard(text)
{
	try {
		await navigator.clipboard.writeText(text);
	} catch (error) {
		console.error(error.message);
	}
}

function jump_to_asset(asset)
{ document.getElementById(asset?.toRefString?.())?.click(); }

// --------------------------------------------------
// TOOLTIP SYSTEM (Portal-based)
// --------------------------------------------------

const TooltipManager = {
	// Phase 1: Grace period before closing starts (allows moving mouse to tooltip)
	HIDE_DELAY_MS: 150, 
	// Phase 2: Duration of the fade-out animation (Must match CSS)
	ANIMATION_MS: 150,   

	state: {
		visible: false,
		content: null,
		targetRect: null, 
		isExiting: false, // Tracks if we are currently animating out
	},
	listeners: [],
	
	timer: null,      // Timer for the HIDE_DELAY
	exitTimer: null,  // Timer for the ANIMATION

	subscribe(listener) {
		this.listeners.push(listener);
		return () => {
			this.listeners = this.listeners.filter(l => l !== listener);
		};
	},

	notify() {
		this.listeners.forEach(l => l(this.state));
	},

	show(content, targetRect) {
		// Cancel any pending hide or exit timers
		this.cancelHide();

		this.state = {
			visible: true,
			isExiting: false, // Ensure we aren't fading out
			content: content,
			targetRect: targetRect
		};
		this.notify();
	},

	startHide() {
		// Prevent stacking timers
		if (this.timer) clearTimeout(this.timer);
		
		// 1. Wait the Buffer Time
		this.timer = setTimeout(() => {
			// 2. Start Exiting (Trigger CSS Animation)
			this.state = { ...this.state, isExiting: true };
			this.notify();

			// 3. Wait for Animation to finish, then unmount
			this.exitTimer = setTimeout(() => {
				this.state = { ...this.state, visible: false, isExiting: false };
				this.notify();
				this.exitTimer = null;
			}, this.ANIMATION_MS);

			this.timer = null;
		}, this.HIDE_DELAY_MS);
	},

	cancelHide() {
		if (this.timer) {
			clearTimeout(this.timer);
			this.timer = null;
		}
		if (this.exitTimer) {
			clearTimeout(this.exitTimer);
			this.exitTimer = null;
		}
		// If we catch it while exiting, snap back to fully visible
		if (this.state.isExiting) {
			this.state = { ...this.state, isExiting: false };
			this.notify();
		}
	}
};

function GlobalTooltip() {
	const [state, setState] = React.useState(TooltipManager.state);
	
	// Default to hidden so it measures before showing
	const [layout, setLayout] = React.useState({ 
		top: 0, 
		left: 0, 
		opacity: 0,
		placement: 'left',
		arrowOffset: 0
	});

	const tooltipRef = React.useRef(null);

	React.useEffect(() => {
		return TooltipManager.subscribe(setState);
	}, []);

	// Perform measurement and positioning whenever content or target changes
	React.useLayoutEffect(() => {
		if (!state.visible || !state.targetRect || !tooltipRef.current) return;

		const target = state.targetRect;
		const tooltip = tooltipRef.current.getBoundingClientRect();
		
		// Use Actual Dimensions from the DOM
		const actualWidth = tooltip.width;
		const actualHeight = tooltip.height;

		const GAP = 10;
		const VIEWPORT_WIDTH = window.innerWidth;
		const VIEWPORT_HEIGHT = window.innerHeight;

		let leftPos = 0;
		let topPos = target.top;
		let placement = 'left';
		let transform = '';

		// --- Horizontal Logic ---
		// Try Left first
		if (target.left - GAP - actualWidth > 0) {
			leftPos = target.left - GAP;
			placement = 'left';
			transform = 'translateX(-100%)'; 
		} 
		// Fallback to Right
		else {
			leftPos = target.right + GAP;
			placement = 'right';
			transform = 'none';
		}

		// --- Vertical Logic ---
		const targetCenterY = target.top + (target.height / 2);
		topPos = target.top;

		const bottomPadding = 20;
		if (topPos + actualHeight > VIEWPORT_HEIGHT - bottomPadding) {
			const overflow = (topPos + actualHeight) - (VIEWPORT_HEIGHT - bottomPadding);
			topPos -= overflow;
		}

		if (topPos < 10) topPos = 10;

		// --- Arrow Logic ---
		let arrowOffset = targetCenterY - topPos;
		const maxArrow = actualHeight - 12; 
		const minArrow = 12;

		if (arrowOffset < minArrow) arrowOffset = minArrow;
		if (arrowOffset > maxArrow) arrowOffset = maxArrow;

		setLayout({
			top: topPos,
			left: leftPos,
			transform: transform,
			placement: placement,
			arrowOffset: arrowOffset,
			opacity: 1 
		});

	}, [state.visible, state.content, state.targetRect]); 

	if (!state.visible || !state.content) return null;

	return ReactDOM.createPortal(
		<div 
			id="global-tooltip-container" 
			ref={tooltipRef}
			style={{
				top: layout.top,
				left: layout.left,
				transform: layout.transform,
				opacity: layout.opacity, 
				pointerEvents: 'auto' 
			}}
			onMouseEnter={() => TooltipManager.cancelHide()}
			onMouseLeave={() => TooltipManager.startHide()}
		>
			<div 
				className={`tooltip-arrow ${layout.placement}`} 
				style={{ top: layout.arrowOffset + 'px' }}
			></div>
			<div className={`tooltip-content ${state.isExiting ? 'exiting' : ''}`}>
				{state.content}
			</div>
		</div>,
		document.body
	);
}

// --------------------------------------------------
// COMPONENT UPDATES
// --------------------------------------------------

function OperandCells({operand, skipNote = false, chainInfo = [], showAliases = false, contextOperand = null, group = null, rowIndex = -1})
{
	function OperandValue()
	{
		if (operand == null) return null;
		
		// 0. RECALL TYPE
		if (operand.type.name === "Recall")
		{
			return <span className="recall-val">{operand.toString()}</span>;
		}

		// 1. MEMORY TYPE
		if (operand.type.addr)
		{
			let displayValue = null;
			if (showAliases && current.notes) {
				const alias = ConditionFormatter.resolveAlias(operand.value, group, rowIndex, current.notes, null);
				if (alias) {
					// Set title to full alias so hover shows full text if truncated
					displayValue = <span className="alias" title={`${alias} (0x${operand.value.toString(16)})`}>{alias}</span>;
				}
			}

			if (!displayValue) {
				let memaddr = operand.toValueString();
				if (chainInfo.length) memaddr = (
					<React.Fragment>
						<span className="AddAddressIndicator">[+</span>
						{memaddr}
						<span className="AddAddressIndicator">]</span>
					</React.Fragment>);
				displayValue = memaddr;
			}
			
			const note_text = current.notes.get_text(operand.value, chainInfo);
			
			if (!skipNote && note_text) {
				return (
					<span 
						className="tooltip"
						onMouseEnter={(e) => {
							const rect = e.currentTarget.getBoundingClientRect();
							TooltipManager.show(<pre>{note_text}</pre>, rect);
						}}
						onMouseLeave={() => TooltipManager.startHide()}
					>
						{displayValue}
					</span>
				);
			}
			else return displayValue;
		}
		
		// 2. VALUE / FLOAT TYPE
		else
		{
			// Only try enum lookup if value exists
			if (showAliases && contextOperand && contextOperand.type.addr && current.notes && operand.value !== undefined && operand.value !== null) {
				const enumLabel = ConditionFormatter.resolveEnum(
					operand.value, 
					contextOperand.value, 
					contextOperand.size, 
					current.notes, 
					chainInfo
				);
				
				if (enumLabel) {
					let rawVal = "";
					if (operand.type === ReqType.FLOAT) rawVal = Number(operand.value).toFixed(1);
					else if (typeof operand.value === 'number') rawVal = `0x${operand.value.toString(16)}`;
					else rawVal = operand.value;
					
					// Apply alias class here too just in case enums get super long
					return <span className="enum-label alias" title={`${operand.value} (${rawVal})`}>{enumLabel}</span>;
				}
			}

			// Standard Display
			if (operand.type === ReqType.FLOAT) {
				return <span className="float-val">{operand.value}</span>;
			}
			
			// Final fallback for integers/strings
			const valStr = operand.value !== undefined && operand.value !== null ? operand.value.toString() : "";
			const valHex = (typeof operand.value === 'number') ? operand.value.toString(16).padStart(8, '0') : "";

			return (<>
				<span className="in-dec">{valStr}</span>
				{valHex && <span className="in-hex">0x{valHex}</span>}
			</>);
		}
	}
	
	return (<>
		<td>{operand ? operand.type.name : ''}</td>
		<td>{operand && operand.size ? operand.size.name : ''}</td>
		<td><OperandValue /></td>
	</>);
}

function LogicGroup({group, gi, logic, issues, showAliases, collapseAddAddress})
{
	let header = gi == 0 ? "Core Group" : `Alt Group ${gi}`;
	if (logic.value) header = `Value Group ${gi+1}`;

	let chain_context = []; 

	return (<>
		<tr className="group-hdr header">
			<td colSpan={10}>{header}</td>
		</tr>
		<tr className="col-hdr header">
			<td>id</td>
			<td>Flag</td>
			<td>Type</td>
			<td>Size</td>
			<td>Mem/Val</td>
			<td>Cmp/Op</td>
			<td>Type</td>
			<td>Size</td>
			<td>Mem/Val</td>
			<td>Hits</td>
		</tr>
		{[...group.entries()].map(([ri, req]) => {
			let match = [...issues.entries()].filter(([_, issue]) => issue.target == req);
			const isAddAddress = req.flag === ReqFlag.ADDADDRESS;
			
			const operand_chain_context_for_this_row = [...chain_context];

			// Calculate context for the NEXT row, even if this one is hidden
			if (isAddAddress) {
				// If starting a chain with an address that lacks a code note, assume Array Indexing (Index + Base).
				// Do not add the Index to the chain context, so the Base (next line) resolves as a direct address.
				const isArrayIndexing = chain_context.length === 0 && (!req.lhs.type.addr || !ConditionFormatter.getEffectiveNote(current.notes, req.lhs.value));

				if (!isArrayIndexing) {
					if (chain_context.length === 0 && req.lhs.type.addr) {
						chain_context.push({ type: 'base', value: req.lhs.value });
					} else if (req.lhs.type.addr) { 
						chain_context.push({ type: 'offset', value: req.lhs.value });
					}
					if (req.rhs && req.rhs.type.addr) {
						chain_context.push({ type: 'offset', value: req.rhs.value });
					}
				}
			} else {
				chain_context = [];
			}

			// If collapsed, do not render the row at all.
			// This ensures CSS nth-child striping works correctly on visible rows.
			if (collapseAddAddress && isAddAddress) return null;
			
			const flagClass = req.flag ? 'flag-' + req.flag.name.replace(/\s+/g, '') : '';

			return (<tr key={`g${gi}-r${ri}`} id={req.toRefString()} className={`${match.some(([_, issue]) => issue.severity >= FeedbackSeverity.FAIL) ? 'warn' : ''} ${flagClass}`}>
				<td>{ri + 1} {match.map(([ndx, _]) => 
					<React.Fragment key={ndx}>{' '} <sup key={ndx}>(#{ndx+1})</sup></React.Fragment>)}</td>
				<td>{req.flag ? req.flag.name : ''}</td>
				
				{/* LHS: Pass group/rowIndex for pointer resolving */}
				<OperandCells 
					operand={req.lhs} 
					skipNote={false} 
					chainInfo={operand_chain_context_for_this_row} 
					showAliases={showAliases}
					group={group}
					rowIndex={ri}
				/>
				
				<td>{req.op ? req.op : ''}</td>
				
				{/* RHS: Pass contextOperand (LHS) for Enum resolution */}
				<OperandCells 
					operand={req.rhs} 
					skipNote={false} 
					chainInfo={operand_chain_context_for_this_row} 
					showAliases={showAliases}
					contextOperand={req.lhs} 
					group={group}
					rowIndex={ri}
				/>
				
				<td data-hits={req.hits}>{req.hasHits() ? `(${req.hits})` : ''}</td>
			</tr>);
		})}
	</>);
}


function LogicTable({logic, issues = [], isHex = null, toggleHex = null})
{
	// Preferences
	// Uncontrolled mode fallback
	const [internalIsHex, setInternalIsHex] = React.useState(() => localStorage.getItem('pref-isHex') === 'true');
	const [collapseAddAddress, setCollapseAddAddress] = React.useState(() => localStorage.getItem('pref-collapseAddAddress') === 'true');
	const [showAliases, setShowAliases] = React.useState(() => localStorage.getItem('pref-showAliases') === 'true');

	// Determine effective hex state
	const effectiveIsHex = (isHex !== null && isHex !== undefined) ? isHex : internalIsHex;

	issues = [].concat(...issues);
	const collapseID = "collapse-addaddress-" + crypto.randomUUID();
	const aliasID = "show-aliases-" + crypto.randomUUID();

	const handleToggleHex = () => {
		if (toggleHex) {
			toggleHex();
		} else {
			const newVal = !internalIsHex;
			setInternalIsHex(newVal);
			localStorage.setItem('pref-isHex', newVal);
		}
	};

	const toggleCollapse = (e) => {
		const newVal = e.currentTarget.checked;
		setCollapseAddAddress(newVal);
		localStorage.setItem('pref-collapseAddAddress', newVal);
	};

	const toggleAliases = (e) => {
		const newVal = e.currentTarget.checked;
		setShowAliases(newVal);
		localStorage.setItem('pref-showAliases', newVal);
	};

	return (<div className="logic-table">
		<table className={`${effectiveIsHex ? 'show-hex' : ''} ${collapseAddAddress ? 'collapse-addaddress' : ''}`}>
			<tbody>
				{[...logic.groups.entries()].map(([gi, g]) => {
					// Pass collapseAddAddress down to the group
					return (<LogicGroup key={gi} group={g} gi={gi} logic={logic} issues={issues} showAliases={showAliases} collapseAddAddress={collapseAddAddress} />);
				})}
			</tbody>
		</table>
		<div className="logic-panel">
			<div style={{display: "inline-block", marginRight: "10px"}}>
				<input type="checkbox" id={collapseID} checked={collapseAddAddress} onChange={toggleCollapse}></input>
				<label htmlFor={collapseID}>Collapse AddAddress</label>
			</div>
			<div style={{display: "inline-block", marginRight: "10px"}}>
				<input type="checkbox" id={aliasID} checked={showAliases} onChange={toggleAliases}></input>
				<label htmlFor={aliasID}>Show Aliases</label>
			</div>
			<button onClick={handleToggleHex}>
				Toggle Hex Values
			</button>
			<button onClick={() => copy_to_clipboard(logic.toMarkdown())}>
				Copy Markdown
			</button>
		</div>
	</div>);
}

function ConsoleIcon({console = null})
{
	if (console == null && current.set) console = current.set.console;
	if (console == null) return null;

	return (<a href={`https://retroachievements.org/system/${console.id}/games`}>
		<img title={console.name} src={`https://static.retroachievements.org/assets/images/system/${console.icon}.png`} />
	</a>);
}

function KeywordList({list, sorted = true})
{
	list = [...list];
	if (list.length == 0) return <>None</>;
	if (sorted) list.sort();
	return (<>{list.map((x, i) => (<React.Fragment key={x}>{i == 0 ? '' : ', '} <code>{x}</code></React.Fragment>))}</>);
}

function LogicStats({logic, stats = {}})
{
	function LogicOnlyStats()
	{
		if (logic && logic.value) return null;
		return (<>
			<li>Requirements with hitcounts: {stats.hit_targets}</li>
			<ul>
				<li><span title="a checkpoint hit is a hitcount of 1, which locks when satisfied">Checkpoint hits</span>: {stats.hit_counts_one}</li>
			</ul>
			<li>Pauses and Resets</li>
			<ul>
				<li><code>PauseIf</code>s: {stats.pause_ifs} ({stats.pause_locks} <span title="a PauseLock is a PauseIf with a hitcount">PauseLock</span>s)</li>
				<li><code>ResetIf</code>s: {stats.reset_ifs} ({stats.reset_with_hits} with hits)</li>
			</ul>
		</>);
	}

	return (
	<ul>
		<li>Memory Length: {logic.mem.length} / 65535</li>
		<li>Group Count: {stats.group_count} {logic && logic.value ? `value groups` : `(1 Core + ${stats.alt_groups} Alts)`}</li>
		<li>Requirement Count: {stats.cond_count}</li>
		<ul>
			<li>Max Requirements Per Group: {stats.group_maxsize}</li>
			<li><span title="A sequence of requirements linked by flags">Longest Chain</span>: {stats.max_chain}</li>
		</ul>
		<li><span title="Number of unique lookups, including lookups with AddAddress">Memory Lookup Count</span>: {stats.memlookups.size} {logic && logic.value ? '' : (stats.memlookups.size <= 1 ? '(possible OCA)' : '')}</li>
		<li>Logic Features</li>
		<ul>
			<li>{stats.deltas} <code>Delta</code>s, {stats.priors} <code>Prior</code>s</li>
			<li>Unique Flags: ({stats.unique_flags.size}) <KeywordList list={[...stats.unique_flags].map(x => x.name)} /></li>
			<li>Unique Mem Sizes: ({stats.unique_sizes.size}) <KeywordList list={[...stats.unique_sizes].map(x => x.name)} /></li>
			<li>Unique Comparisons: ({stats.unique_cmps.size}) <KeywordList list={[...stats.unique_cmps]} /></li>
			<li>Source Modifications: {[...stats.source_modification.entries()].filter(([_, c]) => c > 0).map(([op, c], i) => 
				(<React.Fragment key={op}>{i == 0 ? '' : ', '} <code>{op}</code> ({c})</React.Fragment>))}</li>
		</ul>
		<LogicOnlyStats />
	</ul>);
}

function IssueList({issues = []})
{
	if (issues.length == 0) return null;
	return (<ul>{issues.map((issue, i) => (
		<li key={i}>
			<sup>(<a href="#" onClick={() => {
				let ctarget = typeof issue.target == 'string' ? `asset-${issue.target}` : issue.target?.toRefString();
				if (ctarget) scrollTo(document.getElementById(ctarget));
			}}>#{i+1}</a>)</sup> {issue.type.desc}
			{issue.type.ref.map((ref, i) => <React.Fragment key={i}>
				<sup key={ref}>[<a href={ref}>ref</a>]</sup>
			</React.Fragment>)}
			{issue.detail}
		</li>
	))}</ul>);
}

function SubFeedback({issues = [], label=""})
{
	if (issues.length == 0) return null;
	return (<>
		<h2>{label}</h2>
		<IssueList issues={issues} />
	</>);
}

function AssetFeedback({issues = []})
{
	if (!issues.some(x => x.length > 0)) return null;
	return (<div className="feedback">
		<h1>Feedback</h1>
		{issues.map((group, i) => (
			<SubFeedback key={i}
				label={group.label}
				issues={group}
			/>
		))}
	</div>);
}

function SetBadge({href = null})
{
	return (<a href={href ? href : `https://retroachievements.org/game/${current.id}`}>
		<img className="icon float-left" src={current.set && current.set.icon ? current.set.icon : "https://media.retroachievements.org/Images/000001.png"} />
	</a>);
}

function AchievementBadge({ach, className=""})
{
	if (ach == null) return null;
	return (<img className={"icon " + className} src={ach.badge ? ach.badge : "https://media.retroachievements.org/Images/000001.png"} />);
}

function LinkedAchievementBadge({ach, className=""})
{
	return (<a href={`https://retroachievements.org/achievement/${ach.id}`}><AchievementBadge ach={ach} className={className} /></a>);
}

function AssetCard({asset, warn})
{
	let body = null;
	if (asset instanceof Achievement)
	{
		let icon = null;
		if (asset.achtype == 'progression')   icon = <span title="progression">✅</span>;
		if (asset.achtype == 'win_condition') icon = <span title="win_condition">🏅</span>;
		if (asset.achtype == 'missable')      icon = <span title="missable">⚠️</span>;
		body = (<>
			<div>
				<AchievementBadge ach={asset} />
			</div>
			<div>
				<p>🏆 <strong>{asset.title}</strong> ({asset.points}) {icon}</p>
				<p><em>{asset.desc}</em></p>
			</div>
		</>);
	}
	else if (asset instanceof Leaderboard)
	{
		body = (<>
			<div>
				<p>📊 <strong>{asset.title}</strong></p>
				<p><em>{asset.desc}</em></p>
			</div>
		</>);
	}
	return (<div className={"asset-card" + (warn ? " warning" : "")} onClick={() => { jump_to_asset(asset); }}>{body}</div>);
}

function CollapsibleExplainer({ title = "Logic Analysis", children })
{
	// Load state from localStorage, default to true if not set
	const [isOpen, setIsOpen] = React.useState(() => {
		const saved = localStorage.getItem('pref-showExplainer');
		return saved === null ? true : saved === 'true';
	});

	const toggle = () => {
		const newState = !isOpen;
		setIsOpen(newState);
		localStorage.setItem('pref-showExplainer', newState);
	};

	const headerStyle = {
		padding: '10px',
		backgroundColor: 'black',
		color: 'white',
		cursor: 'pointer',
		display: 'flex',
		alignItems: 'center',
		userSelect: 'none',
		borderRadius: isOpen ? '5px 5px 0 0' : '5px',
		fontWeight: 'bold',
		transition: 'border-radius 0.3s ease'
	};

	return (
		<div style={{ marginBottom: '20px' }}>
			<div onClick={toggle} style={headerStyle}>
				<span style={{ 
					marginRight: '10px', 
					display: 'inline-block',
					transform: isOpen ? 'rotate(90deg)' : 'rotate(0deg)',
					transition: 'transform 0.3s ease'
				}}>▶</span>
				{title}
			</div>
			<div className={`explainer-anim-wrapper ${isOpen ? 'open' : ''}`}>
				<div className="explainer-anim-inner">
					<div className="explanation-container" style={{ 
						border: '1px solid #ccc', 
						borderTop: 'none', 
						borderRadius: '0 0 5px 5px',
						margin: 0 // Override existing margin in CSS for explanation-container
					}}>
						{children}
					</div>
				</div>
			</div>
		</div>
	);
}

function AchievementInfo({ach}) {
	let feedback = ach.feedback;
	let feedback_targets = new Set([].concat(...feedback.issues).map(x => x.target));

	const [isHex, setIsHex] = React.useState(() => localStorage.getItem('pref-isHex') === 'true');
	const toggleHex = () => {
		const newVal = !isHex;
		setIsHex(newVal);
		localStorage.setItem('pref-isHex', newVal);
	};

	return (<>
		<div className="main-header">
			<LinkedAchievementBadge ach={ach} className="float-left" />
			<div>
				<button className="float-right" onClick={() => copy_to_clipboard(`[${ach.title}](${window.location})`)}>
					Copy Markdown Link
				</button>
			</div>
			<h2 id="asset-title">
				🏆 <span className={`${feedback_targets.has("title") ? 'warn' : ''}`}>{ach.title}</span> ({ach.points})
			</h2>
			<div className="float-right">
				<em>{`[${[ach.state.name, ach.achtype].filter(x => x).join(', ')}]`}</em>
			</div>
			<p id="asset-desc">
				<span className={`${feedback_targets.has("desc") ? 'warn' : ''}`}>{ach.desc}</span>
			</p>
		</div>

		<CollapsibleExplainer title={`Logic Analysis for: ${ach.title}`}>
			<LogicExplanation asset={ach} groups={ach.logic.groups} showDecimal={!isHex} />
		</CollapsibleExplainer>

		<div className="data-table">
			<LogicTable logic={ach.logic} issues={feedback.issues} isHex={isHex} toggleHex={toggleHex} />
		</div>
		<div className="stats">
			<h1>Statistics</h1>
			<LogicStats logic={ach.logic} stats={feedback.stats} />
		</div>

		<AssetFeedback issues={feedback.issues} />
	</>);
}

function LeaderboardInfo({lb}) {
	let feedback = lb.feedback;
	let feedback_targets = new Set([].concat(...feedback.issues).map(x => x.target));

	const [isHex, setIsHex] = React.useState(() => localStorage.getItem('pref-isHex') === 'true');
	const toggleHex = () => {
		const newVal = !isHex;
		setIsHex(newVal);
		localStorage.setItem('pref-isHex', newVal);
	};

	const COMPONENTS = ["START", "CANCEL", "SUBMIT", "VALUE"];
	
	function LeaderboardComponentStats() {
		function SectionStats({ block = null }) {
			const tag = block.substring(0, 3);
			return (<React.Fragment>
				<h2>{block}</h2>
				<LogicStats logic={lb.components[tag]} stats={feedback.stats[tag]} />
			</React.Fragment>);
		}

		const [blockContents, setContents] = React.useState(<SectionStats block="START" />);
		return (<div>
			<div>
				{COMPONENTS.map(b => <button key={b} onClick={() => {
					setContents(<SectionStats block={b} />);
				}}>{b}</button>)}
			</div>
			<div>
				{blockContents}
			</div>
		</div>);
	}

	return (<>
		<div className="main-header">
			<SetBadge href={`https://retroachievements.org/leaderboardinfo.php?i=${lb.id}`} />
			<div className="float-right">
			</div>
			<h2 id="asset-title">
				📊 <span className={`${feedback_targets.has("title") ? 'warn' : ''}`}>{lb.title}</span>
			</h2>
			<div className="float-right">
				<em>{`[${[lb.state.name,].filter(x => x).join(', ')}]`}</em>
			</div>
			<p id="asset-desc">
				<span className={`${feedback_targets.has("desc") ? 'warn' : ''}`}>{lb.desc}</span>
			</p>
		</div>

		<CollapsibleExplainer title={`Logic Analysis for: ${lb.title}`}>
			<h3>Start Conditions</h3>
			<LogicExplanation asset={{title: "Start Conditions"}} groups={lb.components['STA'].groups} showDecimal={!isHex} />
			
			<h3>Cancel Conditions</h3>
			<LogicExplanation asset={{title: "Cancel Conditions"}} groups={lb.components['CAN'].groups} showDecimal={!isHex} />
			
			<h3>Submit Conditions</h3>
			<LogicExplanation asset={{title: "Submit Conditions"}} groups={lb.components['SUB'].groups} showDecimal={!isHex} />
			
			<h3>Value Logic</h3>
			<LogicExplanation asset={{title: "Value Logic"}} groups={lb.components['VAL'].groups} showDecimal={!isHex} />
		</CollapsibleExplainer>

		<div className="data-table">
			{COMPONENTS.map(block => <React.Fragment key={block}>
				<h3>{block}</h3>
				<LogicTable logic={lb.components[block.substring(0, 3)]} issues={feedback.issues} isHex={isHex} toggleHex={toggleHex} />
			</React.Fragment>)}
		</div>
		<div className="stats">
			<h1>Statistics</h1>
			<ul>
				<li>Format: <code>{lb.format.type}</code> ({lb.format.name})</li>
				<li>Lower is better? {lb.lower_is_better ? 'Yes' : 'No'}</li>
				<li>Inferred Type: <code>{lb.getType()}</code></li>
			</ul>
			<LeaderboardComponentStats />
		</div>

		<AssetFeedback issues={feedback.issues} />
	</>);
}

function ChartCanvas({ setup })
{
	let graph = React.useRef();
	React.useEffect(() => { setup(graph.current) }, []);
	return (<canvas ref={graph} />);
}

function AchievementSetOverview()
{
	const feedback = current.set.feedback;
	const feedback_targets = new Set([].concat(...feedback.issues).map(x => x.target));
	const stats = feedback.stats;

	function AverageFeedback()
	{
		const ravg = Math.round(stats.avg_points);
		if (ravg <  5) return <strong>(low)</strong>;
		if (ravg <  4) return <strong>(very low)</strong>;
		if (ravg > 10) return <strong>(high)</strong>;
		if (ravg > 15) return <strong>(very high)</strong>;
		return null;
	}

	function CodeNotesInfo()
	{
		if (current.notes.length == 0) return null;
		let notestats = current.notes.feedback.stats;
		let setstats = current.set.feedback.stats;
		return (<>
			<li>Code Notes:</li>
			<ul>
				<li>
					<details>
						<summary>Missing code notes: {setstats.missing_notes.size} (click to expand)</summary>
						<ul>
							{[...setstats.missing_notes.entries()].sort(([a, _1], [b, _2]) => a - b)
								.map(([addr, loc]) => <React.Fragment key={addr}>
									<li><code>{toDisplayHex(addr)}</code></li>
									<ul>
										{loc.map((x, i) => <li key={i}>used in {x}</li>)}
									</ul>
								</React.Fragment>)}
						</ul>
					</details>
				</li>
			</ul>
		</>);
	}

	function RichPresenceInfo()
	{
		if (!current.rp || !current.rp.feedback) return null;
		const stats = current.rp.feedback.stats;
		return (<>
			<li>Rich Presence:</li>
			<ul>
				<li>Is dynamic? {stats.is_dynamic_rp ? 'Yes ✅' : 'No ❌⚠️'}</li>
				<li>Display clauses: {stats.display_groups} ({stats.cond_display} conditional displays)</li>
				<ul>
					<li>Max lookups in one display: {stats.max_lookups}</li>
					<li>Min lookups in one display: {stats.min_lookups}</li>
				</ul>
			</ul>
		</>);
	}

	function ShowPercentage({x})
	{
		if (Array.isArray(x)) x = x.length;
		return (<>{x} ({Math.round(100 * x / stats.achievement_count)}%)</>)
	}

	const achievements = current.set.getAchievements();
	const leaderboards = current.set.getLeaderboards();

	let set_contents = [
		[achievements.length, 'achievement'],
		[leaderboards.length, 'leaderboard'],
	];

	let isSetReady = true;
	isSetReady &= current.set?.feedback?.pass();
	isSetReady &= current.notes?.feedback?.pass();
	isSetReady &= current.rp?.feedback?.pass();
	isSetReady &= [achievements, leaderboards].every((assetgroup) => assetgroup.every((asset) => asset.feedback.pass()));

	let setNotReady = null;
	if (!isSetReady && !achievements.some((ach) => ach.state == AssetState.CORE))
		setNotReady = (<div class="set-warning">
			<h2>⚠️ This set may not yet be ready for review ⚠️</h2>
			<p>There are several errors not yet addressed. Please check the feedback provided for each asset.</p>
		</div>);
	
	return (<>
		<div className="main-header">
			<div className="float-right">
				<ConsoleIcon />
			</div>
			<SetBadge />
			<h1 id="asset-title">
				{get_game_title()}
			</h1>
			<p>
				Set contains {set_contents.filter(([c, _]) => c).map(([c, t]) => `${c} ${t}${c == 1 ? '' : 's'}`).join(' and ')}
			</p>
		</div>
		{setNotReady}
		<div className="chart float-right">
			<h3>Achievement Typing</h3>
			<ChartCanvas setup={(canvas) => {
				let chartdata = [...stats.achievement_type.entries()];
				const COLORS = { '': '#FBDD70', 'progression': '#8DD7E1', 'win_condition': '#A36FD4', 'missable': '#F28590', };
				new Chart(canvas,
					{
						type: 'doughnut',
						data: {
							labels: chartdata.map(([k, _]) => k ? k : '(none)'),
							datasets: [
								{
									label: 'achievement count',
									data: chartdata.map(([_, v]) => v.length),
									backgroundColor: chartdata.map(([k, _]) => COLORS[k]),
								}
							]
						},
					}
				);
			}} />
		</div>
		<div className="stats">
			<h1>Statistics</h1>
			<ul>
				<li>Achievements</li>
				<ul>
					<li>{stats.achievement_count} achievements: <></>
						{[...stats.achievement_type.entries()].map(([k, v]) => `${v.length} ${k ? k : 'standard'}`).join(', ')}</li>
					<li>Total points: {stats.total_points}</li>
					<li><span title="~7 points per achievement is a good target">Average points</span>: ~{stats.avg_points.toFixed(1)} <AverageFeedback /></li>
				</ul>

				<li>Leaderboards</li>
				<ul>
					<li>{stats.leaderboard_count} <span title="breakdown determined heuristically">leaderboards</span>:</li>
					<ul>
						{[...stats.leaderboard_type.entries()].map(([k, v]) => <li key={k}>{v.length} {k}</li>)}
					</ul>
					<li>Instant submission leaderboards: {stats.lb_instant_submission}</li>
					<li>Leaderboards with complex/conditional value: {stats.lb_conditional_value}</li>
				</ul>

				<RichPresenceInfo />

				<li>Proficiencies</li>
				<ul>
					<li>Flags used ({stats.all_flags.size}): <KeywordList list={[...stats.all_flags].map(x => x.name)} /></li>
					<ul>
						{[...stats.all_flags].sort().map(k => <li key={k.name}><code>{k.name}</code> used in {stats.using_flag.get(k).size} achievements</li>)}
						<li>Unused flags: <KeywordList list={[...new Set(Object.values(ReqFlag)).difference(stats.all_flags)].map(x => x.name)} /></li>
					</ul>
					<li>Comparisons used ({stats.all_cmps.size}): <KeywordList list={[...stats.all_cmps]} /></li>
					<li>Sizes used ({stats.all_sizes.size}): <KeywordList list={[...stats.all_sizes].map(x => x.name)} /></li>
					<li>Achievement features:</li>
					<ul>
						<li>Achievements using <code>Delta</code> checks: <ShowPercentage x={stats.using_delta} /></li>
						<li>Achievements using Alt groups: {stats.using_alt_groups.length}</li>
						<li>Achievements using hitcounts: {stats.using_hitcounts.length}</li>
						<li>Achievements using <span title="requirements with a hitcount of 1">checkpoint hits</span>: {stats.using_checkpoint_hits.length}</li>
						<li>Achievements using <span title="BitX and BitCount memory sizes">bit operations</span>: {stats.using_bit_ops.length}</li>
						<li>Achievements using <span title="PauseIf with a hitcount">PauseLocks</span>: {stats.using_pauselock.length} ({stats.using_pauselock_alt_reset.length} with Alt reset)</li>
					</ul>
				</ul>

				<CodeNotesInfo />
			</ul>
		</div>
		<AssetFeedback issues={feedback.issues} />
	</>);
}

function CodeReviewOverview()
{
	const feedback = current.set.feedback;
	const stats = feedback.stats;

	const achievements = current.set.getAchievements();
	const leaderboards = current.set.getLeaderboards();

	let set_contents = [
		[achievements.length, 'achievement'],
		[leaderboards.length, 'leaderboard'],
	];

	function AssetCardList({assets, label, warn = []})
	{
		let body = assets.map(asset => (
			<AssetCard key={asset.id} asset={asset} 
				warn={asset.feedback.issues.some(g => g.some(issue => warn.includes(issue.type) && issue.severity > FeedbackSeverity.INFO))}
			/>
		));

		return (<li><details>
			<summary>{label}: {assets.length} asset{assets.length == 1 ? "" : "s"}</summary>
			<ul>{body}</ul>
		</details></li>);
	}

	function AssetsByFlag({flag, warn = []})
	{
		return (
			<AssetCardList
				assets={[...stats.using_flag.get(flag)]}
				label={<><code>{flag.name}</code></>}
				warn={warn}
			/>
		);
	}

	return (<>
		<div className="main-header">
			<div className="float-right">
				<ConsoleIcon />
			</div>
			<SetBadge />
			<h1 id="asset-title">
				{get_game_title()}
			</h1>
			<p>
				Set contains {set_contents.filter(([c, _]) => c).map(([c, t]) => `${c} ${t}${c == 1 ? '' : 's'}`).join(' and ')}
			</p>
		</div>
		<div>
			<h1>Basic Toolkit</h1>
			<ul>
				<li>Comparison Operators used: ({stats.all_cmps.size}): <KeywordList list={[...stats.all_cmps]} /></li>
				<ul>
					<AssetCardList
						assets={achievements.filter(ach => ach.feedback.stats.unique_cmps.size > 1 || !ach.feedback.stats.unique_cmps.has('='))}
						label={<>Using non-equality comparators</>}
					/>
				</ul>
				<li>Memory Sizes used ({stats.all_sizes.size}): <KeywordList list={[...stats.all_sizes].map(x => x.name)} /></li>
				<ul>
					<AssetCardList
						assets={achievements.filter(ach => ach.feedback.stats.unique_sizes.size > 1 || !ach.feedback.stats.unique_sizes.has(MemSize.BYTE))}
						label={<>Using sizes other than <code>8-bit</code></>}
						warn={[Feedback.TYPE_MISMATCH, ]}
					/>
					<AssetCardList
						assets={stats.using_bit_ops}
						label={<>Using bit operations (<code>BitX</code> or <code>BitCount</code>)</>}
					/>
				</ul>
				<li><code>Mem</code> & <code>Delta</code> Usage</li>
				<ul>
					<AssetCardList
						assets={achievements.filter(ach => ach.feedback.issues.some(g => g.some(x => x.type == Feedback.MISSING_DELTA)))} 
						label={<>Lacking <code>Delta</code></>}
					/>
					<AssetCardList
						assets={achievements.filter(ach => ach.feedback.issues.some(g => g.some(x => x.type == Feedback.IMPROPER_DELTA)))}
						label={<>Using <code>Delta</code> improperly or insufficiently</>}
					/>
				</ul>
				<AssetCardList
					assets={stats.using_alt_groups}
					label={<>Using Alt groups</>}
					warn={[Feedback.COMMON_ALT, Feedback.USELESS_ALT, ]}
				/>
				<li>Hitcounts</li>
				<ul>
					<AssetCardList
						assets={stats.using_checkpoint_hits}
						label={<>Using Checkpoint hits</>}
						warn={[Feedback.HIT_NO_RESET, Feedback.RESET_HITCOUNT_1, ]}
					/>
					<AssetCardList
						assets={stats.using_hitcounts}
						label={<>Using hitcounts (<code>&gt;1</code>)</>}
						warn={[Feedback.HIT_NO_RESET, ]}
					/>
				</ul>
				<li>Specific Flags</li>
				<ul>
					<AssetsByFlag
						flag={ReqFlag.RESETIF}
						warn={[Feedback.PAUSELOCK_NO_RESET, Feedback.HIT_NO_RESET, Feedback.UUO_RESET, Feedback.RESET_HITCOUNT_1, ]}
					/>
					<AssetsByFlag
						flag={ReqFlag.PAUSEIF}
						warn={[Feedback.PAUSELOCK_NO_RESET, Feedback.UUO_PAUSE, Feedback.PAUSING_MEASURED, ]}
					/>
				</ul>
			</ul>
			<h1>Intermediate Toolkit</h1>
			<ul>
				<AssetCardList
					assets={achievements.filter(ach => ach.feedback.stats.priors > 0)}
					label={<>Using <code>Prior</code></>}
					warn={[Feedback.BAD_PRIOR, ]}
				/>
				<li>Specific Flags</li>
				<ul>
					<AssetsByFlag
						flag={ReqFlag.ANDNEXT}
						warn={[Feedback.USELESS_ANDNEXT, ]}
					/>
					<AssetsByFlag
						flag={ReqFlag.ADDHITS}
						warn={[Feedback.HIT_NO_RESET, ]}
					/>
				</ul>
			</ul>
			<h1>Advanced Toolkit</h1>
			<ul>
				<li>PauseLocks</li>
				<ul>
					<AssetCardList
						assets={stats.using_pauselock}
						label={<>PauseLocks</>}
						warn={[Feedback.PAUSELOCK_NO_RESET, ]}
					/>
					<AssetCardList
						assets={stats.using_pauselock_alt_reset}
						label={<>PauseLocks (with Alt resets)</>}
						warn={[Feedback.PAUSELOCK_NO_RESET, ]}
					/>
				</ul>
				<AssetCardList
					assets={achievements.filter(ach => ach.feedback.stats.mem_del > 0)}
					label={<>Using a <code>Mem</code> &ne; <code>Delta</code> counter</>}
					warn={[]}
				/>
				<li>Specific Flags</li>
				<ul>
					<AssetsByFlag
						flag={ReqFlag.RESETNEXTIF}
						warn={[Feedback.PAUSELOCK_NO_RESET, Feedback.HIT_NO_RESET, Feedback.UUO_RNI, ]}
					/>
					<AssetsByFlag
						flag={ReqFlag.SUBHITS}
						warn={[Feedback.HIT_NO_RESET, ]}
					/>
					<AssetsByFlag
						flag={ReqFlag.ADDADDRESS}
						warn={[Feedback.STALE_ADDADDRESS, ]}
					/>
					<AssetsByFlag
						flag={ReqFlag.ADDSOURCE}
						warn={[]}
					/>
					<AssetsByFlag
						flag={ReqFlag.SUBSOURCE}
						warn={[]}
					/>
					<AssetsByFlag
						flag={ReqFlag.MEASURED}
						warn={[Feedback.PAUSING_MEASURED, ]}
					/>
					<AssetsByFlag
						flag={ReqFlag.MEASUREDP}
						warn={[Feedback.PAUSING_MEASURED, ]}
					/>
					<AssetsByFlag
						flag={ReqFlag.MEASUREDIF}
						warn={[]}
					/>
					<AssetsByFlag
						flag={ReqFlag.TRIGGER}
						warn={[]}
					/>
					<AssetsByFlag
						flag={ReqFlag.ORNEXT}
						warn={[]}
					/>
					<AssetCardList
						assets={stats.using_remember_recall}
						label={<><code>Remember</code>+<code>Recall</code></>}
						warn={[]}
					/>
				</ul>
				<li>Source modification:</li>
				<ul>
					<AssetCardList
						assets={achievements.filter(ach => ['*', '/', '+', '-'].some(op => ach.feedback.stats.source_modification.get(op) > 0))}
						label={<>Using <code>*</code>, <code>/</code>, <code>+</code>, <code>-</code></>}
						warn={[]}
					/>
					<AssetCardList
						assets={achievements.filter(ach => ['&', '^', '%'].some(op => ach.feedback.stats.source_modification.get(op) > 0))}
						label={<>Using <code>&</code>, <code>^</code>, <code>%</code></>}
						warn={[]}
					/>
				</ul>
				<AssetCardList
					assets={achievements.filter(ach => ach.feedback.stats.mixed_andor_chains > 0)}
					label={<>Using complex <code>AndNext</code>+<code>OrNext</code> chains</>}
					warn={[]}
				/>
				<AssetCardList
					assets={achievements.filter(ach => ach.feedback.stats.addhits_complex_or > 0)}
					label={<>Using <code>AddHits</code> as complex-<code>OR</code></>}
					warn={[Feedback.HIT_NO_RESET, ]}
				/>
			</ul>
			<h1>Other Details</h1>
			<ul>
				<AssetCardList
					assets={achievements.filter(ach => ach.points == 25)}
					label={<>Achievements worth 25 points</>}
					warn={[]}
				/>
				<AssetCardList
					assets={achievements.filter(ach => ach.points > 25)}
					label={<>Achievements worth &gt;25 points</>}
					warn={[]}
				/>
			</ul>
			<h1>Badge Grid</h1>
			<BadgeGrid set={current.set} />
		</div>
	</>)
}

function CodeNotesTable({notes = [], issues = []})
{
	function toDisplayHex(addr)
	{ return '0x' + addr.toString(16).padStart(8, '0'); }

	function LinkToAsset({asset})
	{
		let handleclick = (e) => {
			jump_to_asset(asset);
			TooltipManager.startHide();
			e.preventDefault();
		};

		if (asset instanceof Achievement)
			return <>🏆 <a href="#" onClick={handleclick}>{asset.title}</a></>;
		else if (asset instanceof Leaderboard)
			return <>📊 <a href="#" onClick={handleclick}>{asset.title}</a></>;
		else
			return <>{asset}</>;
	}

	issues = [].concat(...issues);
	return (<div className="data-table">
		<table className="code-notes">
			<thead>
				<tr className="group-hdr header">
					<td colSpan="4">Code Notes</td>
				</tr>
				<tr className="col-hdr header">
					<td>Address</td>
					<td>Note</td>
					<td>Author</td>
					<td>Assets</td>
				</tr>
			</thead>
			<tbody>
				{notes.map(note => (
					<tr key={note.addr} id={note.toRefString()} className={issues.some(x => x.target == note) ? 'warn' : ''}>
						<td>{toDisplayHex(note.addr)}{note.isArray() ? (<><br/>&#x2010;&nbsp;{toDisplayHex(note.addr + note.size - 1)}</>) : <></>}</td>
						<td><pre>{note.note}</pre></td>
						<td>
							<span className="tooltip"
								onMouseEnter={(e) => {
									const rect = e.currentTarget.getBoundingClientRect();
									TooltipManager.show(<pre>{note.author}</pre>, rect);
								}}
								onMouseLeave={() => TooltipManager.startHide()}
							>
								<a href={`https://retroachievements.org/user/${note.author}`}>
									<img src={`https://media.retroachievements.org/UserPic/${note.author}.png`} width="24" height="24" />
								</a>
							</span>
						</td>
						<td>
							<span className="tooltip"
								onMouseEnter={(e) => {
									const rect = e.currentTarget.getBoundingClientRect();
									TooltipManager.show(<ul style={{width: "500px", "list-style-type": "none", "padding": 0, "margin": 0, }}>
										{note.assetList.map((a, i) => <li key={i}><LinkToAsset asset={a}/></li>)}
									</ul>, rect);
								}}
								onMouseLeave={() => TooltipManager.startHide()}
							>
								{note.assetList.length}
							</span>
						</td>
					</tr>))}
			</tbody>
		</table>
	</div>)
}

function CodeNotesOverview()
{
	const feedback = current.notes.feedback;
	const feedback_targets = new Set([].concat(...feedback.issues).map(x => x.target));
	const stats = feedback.stats;

	let authors = new Set(current.notes.map(note => note.author));
	const [authState, setAuthState] = React.useState(Object.fromEntries([...authors].map(a => [a, true])));
	const [warnsOnly, setWarnsOnly] = React.useState(false);
	const [hideUnused, setHideUnused] = React.useState(false);

	let displaynotes = current.notes.filter(note => authState[note.author]);
	if (warnsOnly) displaynotes = displaynotes.filter(note => feedback_targets.has(note))
	if (hideUnused) displaynotes = displaynotes.filter(note => note.assetList.length > 0)
	let displayissues = feedback.issues.filter(issue => !issue.target || displaynotes.includes(issue.target));

	return (<>
		<div className="main-header">
			<div className="float-right">
				<ConsoleIcon />
			</div>
			<SetBadge href={`https://retroachievements.org/codenotes.php?g=${current.id}`} />
			<h1 id="asset-title">
				{get_game_title()}
			</h1>
			<ul className="list-inside">
				<li>
					<a href={`https://retroachievements.org/codenotes.php?g=${current.id}`}>{current.notes.length} code notes</a> <></>
						by {authors.size} author(s): {[...authors].map((name, i) => <React.Fragment key={name}>{i > 0 ? ' | ' : ''} 
						<span>
							<input type="checkbox" defaultChecked onChange={(e) => {
								setAuthState(Object.assign({}, authState, {[name]: e.currentTarget.checked}));
							}} /> <a href={`https://retroachievements.org/user/${name}`}>{name}</a>
						</span>
					</React.Fragment>)}
				</li>
				<li>
					<label htmlFor="warnsOnly">Only show warnings</label><input id="warnsOnly" type="checkbox" onChange={(e) => {
						setWarnsOnly(e.currentTarget.checked);
					}} />
					{" | "}
					<label htmlFor="hideUnused">Hide unused notes</label><input id="hideUnused" type="checkbox" onChange={(e) => {
						setHideUnused(e.currentTarget.checked);
					}} />
				</li>
			</ul>
		</div>

		<button className='float-right' onClick={() => {
			let delnotes = `1.0.0.0\n${get_game_title()}\n`;
			for (const note of displaynotes)
				delnotes += `N0:${toDisplayHex(note.addr)}:""\n`;

			let e = document.createElement('a');
			e.setAttribute('href', 'data:text/plaincharset=utf-8,' + encodeURIComponent(delnotes));
			e.setAttribute('download', `${current.id}-User.txt`);

			e.style.display = 'none';
			document.body.appendChild(e);
			e.click();
			document.body.removeChild(e);
		}}>Quick Delete</button>
		<CodeNotesTable notes={displaynotes} issues={displayissues} />

		<div className="stats">
			<h1>Statistics</h1>
			<ul>
				<li>{stats.notes_count} code notes ({stats.notes_used} used, {stats.notes_unused} unused)</li>
				<li>Sizes noted</li>
				<ul>
					{[...stats.size_counts.entries()].map(([k, v]) => <li key={k}><code>{k}</code>: {v}</li>)}
				</ul>
				<li>Author contributions</li>
				<ul>
					{[...stats.author_counts.entries()].map(([k, v]) => <li key={k}>
						<a href={`https://retroachievements.org/user/${k}`}>{k}</a>: {v} ({(100 * v / stats.notes_count).toFixed(1)}%)
					</li>)}
				</ul>
			</ul>
		</div>

		<AssetFeedback issues={displayissues} />
	</>);
}

// --- RICH PRESENCE SIMULATOR & UI ---

function HighlightedRichPresence({script, onLogicSelected = null})
{
	if (!script) return null;

	let ref = React.useRef();
	React.useEffect(() => {
		let root = ref.current;
		for (let elt of root.querySelectorAll('.link'))
			elt.onclick = (x) => { document.getElementById(`def-${elt.innerText}`).scrollIntoView({behavior: 'smooth', block: 'nearest'}); }
	
		for (let elt of root.querySelectorAll('.logic'))
			elt.onclick = (x) => {
				for (let e2 of root.querySelectorAll('.logic.selected'))
					e2.classList.remove('selected');
				elt.classList.add('selected');
	
				const logic = Logic.fromString(elt.innerText, elt.classList.contains('value'));
				if (onLogicSelected) onLogicSelected(logic);
			}
	}, []);

	function addLookups(t)
	{ return t.replaceAll(/(@(\S*)\((.+?)\))/gi, '<span class="lookup">@<span class="link">$2</span>(<span class="value logic">$3</span>)</span>'); }

	let display = false;
	let rptext = script.split(/\r\n|(?!\r\n)[\n-\r\x85\u2028\u2029]/g).map(line => {
		line = line.trim();
		if (display) line = line.startsWith('?')
			? line.replaceAll(/\?(.+)\?(.*)/g, (_, p1, p2) => `?<span class="condition logic">${p1}</span>?${addLookups(p2)}`)
			: addLookups(line);
		if (line.startsWith('Display:')) display = true;
		return line;
	}).join('\n');
	rptext = rptext.replaceAll(/((Lookup|Format|Display):(\S+))/g, '<span class="header" id="def-$3">$1</span>');

	return (<div className="rich-presence clear">
		<pre><code ref={ref} dangerouslySetInnerHTML={{__html: rptext}}></code></pre>
	</div>);
}

function formatRPSimulationValue(value, format, parameter, scoreVal) {
	let displayValue = value;
	
	if (parameter) {
		let maxVal = 0xFFFFFFFF;
		if (parameter.includes("8-bit") || parameter.includes("Bit") || parameter.includes("4")) maxVal = 0xFF;
		else if (parameter.includes("16-bit")) maxVal = 0xFFFF;
		else if (parameter.includes("24-bit")) maxVal = 0xFFFFFF;
		displayValue = value % (maxVal + 1);
	}

	switch (format.toUpperCase()) {
		case "SCORE": return String(scoreVal).padStart(6, '0');
		case "FRAMES": return `${Math.floor(displayValue / 3600)}:${String(Math.floor((displayValue / 60) % 60)).padStart(2, '0')}.${String(Math.floor((displayValue * 100) / 60) % 100).padStart(2, '0')}`;
		case "MILLISECS": return `${Math.floor(displayValue / 6000)}:${String(Math.floor((displayValue / 100) % 60)).padStart(2, '0')}.${String(displayValue % 100).padStart(2, '0')}`;
		case "SECS": return `${Math.floor(displayValue / 60)}:${String(displayValue % 60).padStart(2, '0')}`;
		case "MINUTES": return `${Math.floor(displayValue / 60)}h${String(displayValue % 60).padStart(2, '0')}`;
		case "SECS_AS_MINS": return `${Math.floor(displayValue / 3600)}h${String(Math.floor((displayValue / 60) % 60)).padStart(2, '0')}:${String(displayValue % 60).padStart(2, '0')}`;
		case "UNSIGNED": return String(displayValue >>> 0);
		case "TENS": return String(displayValue * 10);
		case "HUNDREDS": return String(displayValue * 100);
		case "THOUSANDS": return String(displayValue * 1000);
		case "FIXED1": return (displayValue / 10.0).toFixed(1);
		case "FIXED2": return (displayValue / 100.0).toFixed(2);
		case "FIXED3": return (displayValue / 1000.0).toFixed(3);
		case "FLOAT1": return (Math.random() * 1000).toFixed(1);
		case "FLOAT2": return (Math.random() * 1000).toFixed(2);
		case "FLOAT3": return (Math.random() * 1000).toFixed(3);
		case "ASCIICHAR": return displayValue >= 0x20 && displayValue <= 0x7E ? String.fromCharCode(displayValue) : "?";
		case "UNICODECHAR": return displayValue >= 0x20 ? String.fromCharCode(displayValue) : "?";
		case "VALUE":
		default: return String(displayValue);
	}
}

function getFormattedPreview(ds, script) {
	let sb = "";
	const builtInMacros = {
		'Number': 'VALUE', 'Unsigned': 'UNSIGNED', 'Score': 'SCORE', 'Centiseconds': 'MILLISECS',
		'Seconds': 'SECS', 'Minutes': 'MINUTES', 'Fixed1': 'FIXED1', 'Fixed2': 'FIXED2', 'Fixed3': 'FIXED3',
		'Float1': 'FLOAT1', 'Float2': 'FLOAT2', 'Float3': 'FLOAT3', 'ASCIIChar': 'ASCIICHAR', 'UnicodeChar': 'UNICODECHAR'
	};

	for (let part of ds.parts) {
		if (part.isMacro) {
			let lookup = script.scriptLookups.find(l => l.name.toLowerCase() === part.text.toLowerCase());
			if (lookup) {
				if (lookup.entries.length > 0) sb += lookup.defaultVal || "";
				else sb += formatRPSimulationValue(0, lookup.format, part.parameter, 0);
			} else if (builtInMacros[part.text]) {
				sb += formatRPSimulationValue(0, builtInMacros[part.text], part.parameter, 0);
			} else {
				sb += `{${part.text}}`;
			}
		} else {
			sb += part.text;
		}
	}
	sb = sb.replace(/\s+/g, ' ').trim();
	return (ds.isDefault ? "[Default] " : "") + sb;
}

function RARPLivePreview({ script, displayString }) {
	const [tick, setTick] = React.useState(0);
	const [score, setScore] = React.useState(() => Math.floor(Math.random() * 10000));
	const lookupCache = React.useRef({});

	React.useEffect(() => {
		const timer = setInterval(() => {
			setTick(t => t + 1);
			setScore(s => Math.max(0, s + Math.floor(Math.random() * 101) - 50));
		}, 1000);
		return () => clearInterval(timer);
	}, [displayString]);

	if (!displayString) return <div className="rarp-live-preview" style={{color: '#666'}}>No string selected</div>;

	let previewText = "";
	const builtInMacros = {
		'Number': 'VALUE', 'Unsigned': 'UNSIGNED', 'Score': 'SCORE', 'Centiseconds': 'MILLISECS',
		'Seconds': 'SECS', 'Minutes': 'MINUTES', 'Fixed1': 'FIXED1', 'Fixed2': 'FIXED2', 'Fixed3': 'FIXED3',
		'Float1': 'FLOAT1', 'Float2': 'FLOAT2', 'Float3': 'FLOAT3', 'ASCIIChar': 'ASCIICHAR', 'UnicodeChar': 'UNICODECHAR'
	};

	for (let part of displayString.parts) {
		if (!part.isMacro) { previewText += part.text; continue; }

		let lookup = script.scriptLookups.find(l => l.name.toLowerCase() === part.text.toLowerCase());
		if (lookup) {
			if (lookup.entries.length > 0) {
				if (!lookupCache.current[lookup.name] || tick % 3 === 0) {
					let randomEntry = lookup.entries[Math.floor(Math.random() * lookup.entries.length)];
					lookupCache.current[lookup.name] = randomEntry ? randomEntry.value : (lookup.defaultVal || "");
				}
				previewText += lookupCache.current[lookup.name];
			} else {
				previewText += formatRPSimulationValue(tick, lookup.format, part.parameter, score);
			}
		} else if (builtInMacros[part.text]) {
			previewText += formatRPSimulationValue(tick, builtInMacros[part.text], part.parameter, score);
		} else {
			previewText += `{${part.text}}`;
		}
	}

	return <div className="rarp-live-preview"> {previewText}</div>;
}

function RARPTreeView({ script, selectedItem, setSelectedItem, dsSeverities, lookupSeverities, formatterSeverities, sidebarWidth }) {
	const [expanded, setExpanded] = React.useState({ lookups: true, formatters: true, display: true });
	const toggle = (cat) => setExpanded(prev => ({ ...prev, [cat]: !prev[cat] }));

	const formatters = script.scriptLookups.filter(l => l.entries.length === 0 && l.defaultVal === null);
	const lookups = script.scriptLookups.filter(l => l.entries.length > 0 || l.defaultVal !== null);

	const getIcon = (severity) => {
		if (severity >= 3) return '❌';
		if (severity === 2) return '⚠️';
		if (severity === 1) return 'ℹ️';
		return '✔️';
	};

	const arrowStyle = (isOpen) => ({
		width: '20px', 
		display: 'inline-block', 
		textAlign: 'center', 
		fontSize: '10px',
		transform: isOpen ? 'rotate(90deg)' : 'rotate(0deg)',
		transition: 'transform 0.3s ease'
	});

	return (
		<div className="rarp-sidebar" style={{ flexBasis: sidebarWidth }}>
			<div className="rarp-tree-group" onClick={() => toggle('lookups')}>
				<span style={arrowStyle(expanded.lookups)}>▶</span> Lookups
			</div>
			<div className={`explainer-anim-wrapper ${expanded.lookups ? 'open' : ''}`}>
				<div className="explainer-anim-inner">
					{lookups.map((l, i) => {
						let sev = lookupSeverities[i] || 0;
						let icon = getIcon(sev);
						return (
							<div key={`l-${i}`} className={`rarp-tree-node ${i % 2 === 0 ? 'striped' : ''} ${selectedItem.type === 'lookup' && selectedItem.index === i ? 'selected' : ''}`} onClick={() => setSelectedItem({type: 'lookup', index: i, macro: 'Condition'})} title={l.name}>
								<span style={{flexShrink: 0}}>{icon}</span> 
								<span style={{overflow: 'hidden', textOverflow: 'ellipsis'}}>{l.name}</span>
							</div>
						);
					})}
				</div>
			</div>

			<div className="rarp-tree-group" onClick={() => toggle('formatters')}>
				<span style={arrowStyle(expanded.formatters)}>▶</span> Formatters
			</div>
			<div className={`explainer-anim-wrapper ${expanded.formatters ? 'open' : ''}`}>
				<div className="explainer-anim-inner">
					{formatters.map((f, i) => {
						let sev = formatterSeverities[i] || 0;
						let icon = getIcon(sev);
						return (
							<div key={`f-${i}`} className={`rarp-tree-node ${i % 2 === 0 ? 'striped' : ''} ${selectedItem.type === 'formatter' && selectedItem.index === i ? 'selected' : ''}`} onClick={() => setSelectedItem({type: 'formatter', index: i, macro: 'Condition'})} title={f.name}>
								<span style={{flexShrink: 0}}>{icon}</span> 
								<span style={{overflow: 'hidden', textOverflow: 'ellipsis'}}>{f.name}</span>
							</div>
						);
					})}
				</div>
			</div>

			<div className="rarp-tree-group" onClick={() => toggle('display')}>
				<span style={arrowStyle(expanded.display)}>▶</span> Display Logic
			</div>
			<div className={`explainer-anim-wrapper ${expanded.display ? 'open' : ''}`}>
				<div className="explainer-anim-inner">
					{script.displayStrings.map((ds, i) => {
						let displayTitle = getFormattedPreview(ds, script);
						let sev = dsSeverities[i] || 0;
						let icon = getIcon(sev);
						if (ds.isDefault && sev === 0) icon = '⭐';

						return (
							<div key={`d-${i}`} className={`rarp-tree-node ${i % 2 === 0 ? 'striped' : ''} ${selectedItem.type === 'display' && selectedItem.index === i ? 'selected' : ''}`} onClick={() => setSelectedItem({type: 'display', index: i, macro: 'Condition'})} title={displayTitle}>
								<span style={{flexShrink: 0}}>{icon}</span> 
								<span style={{overflow: 'hidden', textOverflow: 'ellipsis'}}>{displayTitle}</span>
							</div>
						);
					})}
				</div>
			</div>
		</div>
	);
}

function RARPDisplayEditor({ ds, isHex, toggleHex, selectedItem, setSelectedItem }) {
	const selectedLogic = selectedItem.macro || "Condition";
	const macros = ds.parts.filter(p => p.isMacro);
	const macroNames = [...new Set(macros.map(m => m.text))];

	// Resizer state for the top row panels
	const [templateWidth, setTemplateWidth] = React.useState(55); // percentage
	const [isDragging, setIsDragging] = React.useState(false);

	React.useEffect(() => {
		const handleMouseMove = (e) => {
			if (!isDragging) return;
			// Estimate percentage based on window width minus sidebar
			const containerWidth = document.querySelector('.rarp-top-row').offsetWidth;
			const containerLeft = document.querySelector('.rarp-top-row').getBoundingClientRect().left;
			let newPct = ((e.clientX - containerLeft) / containerWidth) * 100;
			if (newPct < 20) newPct = 20;
			if (newPct > 80) newPct = 80;
			setTemplateWidth(newPct);
		};

		const handleMouseUp = () => {
			if (isDragging) setIsDragging(false);
		};

		if (isDragging) {
			document.addEventListener('mousemove', handleMouseMove);
			document.addEventListener('mouseup', handleMouseUp);
			document.body.style.cursor = 'col-resize';
		} else {
			document.body.style.cursor = 'default';
		}

		return () => {
			document.removeEventListener('mousemove', handleMouseMove);
			document.removeEventListener('mouseup', handleMouseUp);
		};
	}, [isDragging]);

	const handleLogicChange = (e) => {
		setSelectedItem({ ...selectedItem, macro: e.target.value });
	};

	let tableContent = null;

	if (selectedLogic === "Condition") {
		tableContent = ds.condition ? (
			<div className="data-table">
				<LogicTable logic={ds.condition} isHex={isHex} toggleHex={toggleHex} />
			</div>
		) : <div style={{padding: '15px', color: '#888', fontStyle: 'italic'}}>No condition defined (Default String).</div>;
	} else {
		const targetMacro = macros.find(m => m.text === selectedLogic);
		if (targetMacro) {
			let macroLogic;
			try { macroLogic = Logic.fromString(targetMacro.parameter, true); } catch(e) {}

			tableContent = (
				<div>
					{macroLogic ? <div className="data-table"><LogicTable logic={macroLogic} isHex={isHex} toggleHex={toggleHex} /></div> : <div style={{padding: '15px', color: 'red'}}>Invalid logic</div>}
				</div>
			);
		}
	}

	const rawTemplate = ds.parts.map(p => p.isMacro ? `{${p.text}}` : p.text).join('');

	return (
		<div className="rarp-main" id={ds.toRefString()}>
			<div className="rarp-top-row flex-panel-container">
				<div className="rarp-panel" style={{flexBasis: `${templateWidth}%`, flexGrow: 0, flexShrink: 0}}>
					<div className="rarp-panel-header">Display String Template</div>
					<div className="rarp-panel-content">
						<p className="rarp-template-text">{rawTemplate}</p>
					</div>
				</div>
				
				{/* Horizontal Splitter */}
				<div 
					className={`resizer-x ${isDragging ? 'active' : ''}`} 
					onMouseDown={(e) => { e.preventDefault(); setIsDragging(true); }}
				></div>

				<div className="rarp-panel" style={{flexBasis: `calc(${100 - templateWidth}% - 5px)`, flexGrow: 0, flexShrink: 0}}>
					<div className="rarp-panel-header">Live Preview Panel</div>
					<div className="rarp-panel-content">
						<RARPLivePreview script={current.rp} displayString={ds} />
					</div>
				</div>
			</div>
			
			<div className="rarp-panel" style={{ flex: '2' }}>
				<div className="rarp-panel-header">Logic Explorer</div>
				<div className="rarp-logic-toolbar">
					<select className="rarp-logic-select" value={selectedLogic} onChange={handleLogicChange}>
						<option value="Condition">Condition</option>
						{macroNames.map(m => <option key={m} value={m}>{m}</option>)}
					</select>
				</div>
				<div className="rarp-panel-content" style={{padding: 0}}>
					{tableContent}
				</div>
			</div>
		</div>
	);
}

function RARPDetailView({ script, selectedItem, setSelectedItem, isHex, toggleHex }) {
	if (selectedItem.type === 'display') {
		const ds = script.displayStrings[selectedItem.index];
		if (!ds) return null;
		return <RARPDisplayEditor ds={ds} isHex={isHex} toggleHex={toggleHex} selectedItem={selectedItem} setSelectedItem={setSelectedItem} />;
	}

	const formatters = script.scriptLookups.filter(l => l.entries.length === 0 && l.defaultVal === null);
	const lookups = script.scriptLookups.filter(l => l.entries.length > 0 || l.defaultVal !== null);

	const item = selectedItem.type === 'lookup' ? lookups[selectedItem.index] : formatters[selectedItem.index];
	if (!item) return null;

	return (
		<div className="rarp-main" id={item.toRefString()}>
			<div className="rarp-panel">
				<div className="rarp-panel-header">{selectedItem.type === 'lookup' ? 'Lookup Dictionary' : 'Formatter Definition'}</div>
				<div className="rarp-panel-content">
					<h2 style={{marginTop: 0}}>{item.name}</h2>
					<p style={{color: '#888'}}>Format Type: <strong>{item.format}</strong></p>
					
					{selectedItem.type === 'lookup' && (
						<div className="data-table" style={{marginTop: '20px'}}>
							<table>
								<thead>
									<tr className="col-hdr header">
										<td>Key (Hex)</td>
										<td>Key (Dec)</td>
										<td>Value</td>
									</tr>
								</thead>
								<tbody>
									{item.entries.sort((a,b) => a.keyValue - b.keyValue).map((e, i) => (
										<tr key={i}>
											<td>0x{e.keyValue.toString(16).toUpperCase()} {e.keyValueEnd && e.keyValueEnd !== e.keyValue ? `- 0x${e.keyValueEnd.toString(16).toUpperCase()}` : ''}</td>
											<td>{e.keyValue} {e.keyValueEnd && e.keyValueEnd !== e.keyValue ? `- ${e.keyValueEnd}` : ''}</td>
											<td>{e.value}</td>
										</tr>
									))}
									{item.defaultVal !== null && (
										<tr>
											<td colSpan="2" style={{color: '#999'}}>* (Default/Fallback)</td>
											<td style={{color: '#999'}}>{item.defaultVal}</td>
										</tr>
									)}
								</tbody>
							</table>
						</div>
					)}
				</div>
			</div>
		</div>
	);
}

// Extract text from React detail elements to map null-target issues
function extractReactText(node) {
	if (!node) return '';
	if (typeof node === 'string') return node;
	if (Array.isArray(node)) return node.map(extractReactText).join('');
	if (node.props && node.props.children) return extractReactText(node.props.children);
	return '';
}

function RPAssetFeedback({ issues, onIssueClick }) {
	if (!issues || issues.length === 0 || !issues.some(g => g.length > 0)) return null;
	return (<div className="feedback">
		<h1>Feedback</h1>
		{issues.map((group, i) => {
			if (!group || group.length === 0) return null;
			return (<React.Fragment key={i}>
				<h2>{group.label}</h2>
				<ul>{group.map((issue, j) => (
					<li key={j}>
						{issue.target ? <sup>(<a href="#" onClick={(e) => { e.preventDefault(); onIssueClick(issue); }}>#{j+1}</a>)</sup> : null}
						{' '}{issue.type.desc}
						{issue.type.ref.map((r, k) => <React.Fragment key={k}><sup key={r}>[<a href={r} target="_blank">ref</a>]</sup></React.Fragment>)}
						{issue.detail}
					</li>
				))}</ul>
			</React.Fragment>);
		})}
	</div>);
}

function RichPresenceOverview() {
	const feedback = current.rp.feedback;
	const script = current.rp;
	
	const [viewMode, setViewMode] = React.useState(() => localStorage.getItem('pref-rpViewMode') || 'rarp');
	const [selectedItem, setSelectedItem] = React.useState({ type: 'display', index: 0, macro: 'Condition' });
	const [logicData, setLogicData] = React.useState(null); 
	
	// Splitter State for RP UI Sidebar
	const [sidebarWidth, setSidebarWidth] = React.useState(350);
	const [isDraggingSidebar, setIsDraggingSidebar] = React.useState(false);
	
	const [isHex, setIsHex] = React.useState(() => localStorage.getItem('pref-isHex') === 'true');
	const toggleHex = () => {
		const newVal = !isHex;
		setIsHex(newVal);
		localStorage.setItem('pref-isHex', newVal);
	};

	const toggleViewMode = () => {
		const newMode = viewMode === 'rarp' ? 'raw' : 'rarp';
		setViewMode(newMode);
		localStorage.setItem('pref-rpViewMode', newMode);
	};

	// Global mouse events for RP sidebar splitter
	React.useEffect(() => {
		const handleMouseMove = (e) => {
			if (!isDraggingSidebar) return;
			const rarpLayout = document.querySelector('.rarp-layout');
			if (!rarpLayout) return;
			const containerLeft = rarpLayout.getBoundingClientRect().left;
			let newWidth = e.clientX - containerLeft;
			if (newWidth < 150) newWidth = 150;
			if (newWidth > window.innerWidth * 0.5) newWidth = window.innerWidth * 0.5;
			setSidebarWidth(newWidth);
		};

		const handleMouseUp = () => {
			if (isDraggingSidebar) setIsDraggingSidebar(false);
		};

		if (isDraggingSidebar) {
			document.addEventListener('mousemove', handleMouseMove);
			document.addEventListener('mouseup', handleMouseUp);
			document.body.style.cursor = 'col-resize';
		} else {
			document.body.style.cursor = 'default';
		}

		return () => {
			document.removeEventListener('mousemove', handleMouseMove);
			document.removeEventListener('mouseup', handleMouseUp);
		};
	}, [isDraggingSidebar]);

	const reqToNav = React.useMemo(() => {
		const map = {};
		script.displayStrings.forEach((ds, dsIndex) => {
			map[ds.toRefString()] = { type: 'display', index: dsIndex, macro: 'Condition' };
			if (ds.condition) {
				ds.condition.groups.forEach(g => g.forEach(req => {
					map[req.toRefString()] = { type: 'display', index: dsIndex, macro: 'Condition' };
				}));
			}
			ds.parts.forEach(p => {
				if (p.isMacro && p.logic) {
					p.logic.groups.forEach(g => g.forEach(req => {
						map[req.toRefString()] = { type: 'display', index: dsIndex, macro: p.text };
					}));
				}
			});
		});
		script.scriptLookups.forEach((l) => {
			const isFormatter = l.entries.length === 0 && l.defaultVal === null;
			const type = isFormatter ? 'formatter' : 'lookup';
			
			const formatters = script.scriptLookups.filter(x => x.entries.length === 0 && x.defaultVal === null);
			const lookups = script.scriptLookups.filter(x => x.entries.length > 0 || x.defaultVal !== null);
			
			const typeIndex = isFormatter ? formatters.indexOf(l) : lookups.indexOf(l);
			map[l.toRefString()] = { type: type, index: typeIndex, macro: 'Condition' };
		});
		return map;
	}, [script]);

	const { dsSeverities, lookupSeverities, formatterSeverities } = React.useMemo(() => {
		const dsSev = script.displayStrings.map(() => 0);
		const formatters = script.scriptLookups.filter(x => x.entries.length === 0 && x.defaultVal === null);
		const lookups = script.scriptLookups.filter(x => x.entries.length > 0 || x.defaultVal !== null);
		const lSev = lookups.map(() => 0);
		const fSev = formatters.map(() => 0);
		
		if (feedback && feedback.issues) {
			feedback.issues.forEach(group => group.forEach(issue => {
				if (issue.target) {
					const nav = reqToNav[issue.target.toRefString()];
					if (nav) {
						if (nav.type === 'display') dsSev[nav.index] = Math.max(dsSev[nav.index], issue.severity);
						else if (nav.type === 'lookup') lSev[nav.index] = Math.max(lSev[nav.index], issue.severity);
						else if (nav.type === 'formatter') fSev[nav.index] = Math.max(fSev[nav.index], issue.severity);
					}
				}
			}));
		}
		return { dsSeverities: dsSev, lookupSeverities: lSev, formatterSeverities: fSev };
	}, [script, feedback, reqToNav]);

	const handleIssueClick = (issue) => {
		if (!issue.target) return;
		const reqRef = issue.target.toRefString();
		const nav = reqToNav[reqRef];
		
		if (nav) {
			const targetMacro = issue.macro || nav.macro || 'Condition';
			if (viewMode === 'rarp') {
				setSelectedItem({ type: nav.type, index: nav.index, macro: targetMacro });
				setTimeout(() => {
					document.querySelectorAll('.logic-table .selected, .rarp-main.selected').forEach(e => e.classList.remove('selected'));
					const el = document.getElementById(reqRef);
					if (el) {
						el.scrollIntoView({ behavior: 'smooth', block: 'center' });
						el.classList.add('selected');
					} else if (issue.target.parts) { // If it's a general Display String issue targeting the string itself
						const mainContainer = document.getElementById(reqRef);
						if (mainContainer) mainContainer.classList.add('selected');
					}
				}, 100);
			} else {
				document.querySelectorAll('.logic-table .selected, .rarp-main.selected').forEach(e => e.classList.remove('selected'));
				const el = document.getElementById(reqRef);
				if (el) {
					el.scrollIntoView({ behavior: 'smooth', block: 'center' });
					el.classList.add('selected');
				}
			}
		}
	};

	// Generate summary metrics
	const lookupCount = script.scriptLookups.filter(l => l.entries.length > 0 || l.defaultVal !== null).length;
	const formatterCount = script.scriptLookups.filter(l => l.entries.length === 0 && l.defaultVal === null).length;
	const dsCount = script.displayStrings.length;
	
	// Strict Check: It is only a valid default display if it's conditionless AND static (contains no macros)
	const defaultDs = script.displayStrings.filter(ds => ds.isDefault && !ds.parts.some(p => p.isMacro)).length > 0 ? "Yes" : "No";

	return (<>
		<div className="main-header" style={{ marginBottom: '0', paddingBottom: '10px' }}>
			<div className="float-right" style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
				<button onClick={toggleViewMode}>
					{viewMode === 'rarp' ? 'Switch to Raw RP View' : 'Switch to RP UI'}
				</button>
				<ConsoleIcon />
			</div>
			<SetBadge />
			<h1 id="asset-title" style={{ margin: '0 0 8px 0' }}>
				{get_game_title()}
			</h1>
			<div style={{ fontStyle: 'italic', color: '#888', fontSize: '13px', lineHeight: '1.4' }}>
				<div>{lookupCount} Lookups</div>
				<div>{formatterCount} Formatters</div>
				<div>{dsCount} Display Strings (Default Display: {defaultDs})</div>
			</div>
			<div className="clear"></div>
		</div>

		<div key={viewMode} className="fade-in-view">
			{viewMode === 'rarp' ? (
				<div className="rarp-layout">
					<RARPTreeView script={script} selectedItem={selectedItem} setSelectedItem={setSelectedItem} dsSeverities={dsSeverities} lookupSeverities={lookupSeverities} formatterSeverities={formatterSeverities} sidebarWidth={sidebarWidth} />
					
					{/* Vertical Splitter */}
					<div 
						className={`resizer-x ${isDraggingSidebar ? 'active' : ''}`} 
						onMouseDown={(e) => { e.preventDefault(); setIsDraggingSidebar(true); }}
					></div>

					<RARPDetailView script={script} selectedItem={selectedItem} setSelectedItem={setSelectedItem} isHex={isHex} toggleHex={toggleHex} />
				</div>
			) : (
				<div style={{ marginTop: '20px' }}>
					<HighlightedRichPresence script={script.text} onLogicSelected={setLogicData} />
					<div className="data-table" style={{marginTop: '20px'}}>
						{logicData && <LogicTable logic={logicData} isHex={isHex} toggleHex={toggleHex} />}
					</div>
				</div>
			)}
		</div>

		<div style={{ marginTop: '20px' }}>
			<RPAssetFeedback issues={feedback.issues} onIssueClick={handleIssueClick} />
		</div>
	</>);
}

function BadgeGrid({set = current.set})
{
	const PADDING = 10;
	const ROWLEN = 10;
	let achs = set.getAchievements();

	const HEIGHT = PADDING + 96 + PADDING + (64 + PADDING) * Math.ceil(achs.length / ROWLEN);
	const WIDTH = 2 * PADDING + (64 + PADDING) * ROWLEN;

	let canvasRef = React.useRef();
	const [status, setStatus] = React.useState("⏳ Initializing...");
	const [isReady, setIsReady] = React.useState(false);

	const handleCopyClick = async () => {
		if (!isReady) return;
		
		setStatus("⚙️ Processing...");
		const canvas = canvasRef.current;
		
		try {
			canvas.toBlob(async (blob) => {
				if (!blob) {
					setStatus("❌ Error");
					return;
				}
				try {
					const item = new ClipboardItem({ "image/png": blob });
					await navigator.clipboard.write([item]);
					setStatus("✅ Copied!");
					setTimeout(() => setStatus("📋 Copy Image"), 2000);
				} catch (err) {
					console.error("Clipboard write failed:", err);
					setStatus("❌ Too Large?");
				}
			}, "image/png");
		} catch (err) {
			console.error("Canvas conversion failed:", err);
			setStatus("❌ Error");
		}
	};

	React.useEffect(() => {
		const canvas = canvasRef.current;
		if (!canvas) return;
		// Track if this effect is still active to prevent race conditions on fast set switching
		let isActive = true;

		const ctx = canvas.getContext('2d', { willReadFrequently: true });

		const loadImage = (url) => {
			return new Promise((resolve) => {
				const img = new Image();
				//img.crossOrigin = "Anonymous";
				img.src = url; 

				img.onload = () => resolve(img);
				img.onerror = (e) => {
					console.warn("Failed to load:", url, e);
					resolve(null);
				};
			});
		};

		const render = async () => {
			setIsReady(false);
			
			// 1. Draw Background
			ctx.fillStyle = '#2b374a';
			ctx.fillRect(0, 0, canvas.width, canvas.height);
			
			// 2. Draw Icon Backgrounds (Placeholders)
			ctx.fillStyle = '#111111';
			ctx.fillRect(PADDING+3, PADDING+3, 96, 96);
			
			for (let i = 0; i < achs.length; i++) {
				let x = 2 * PADDING + (i % ROWLEN) * (64 + PADDING);
				let y = PADDING + 96 + PADDING + Math.floor(i / ROWLEN) * (64 + PADDING);
				ctx.fillRect(x+3, y+3, 64, 64);
			}

			// 3. Draw Text Metadata
			let authorlist = achs.map(a => a.author).filter(a => a);
			let authcount = [], authors = new Set(authorlist);
			for (let auth of authors) authcount.push([auth, authorlist.filter((x) => x == auth).length]);
			authcount.sort(([a, _1], [b, _2]) => b-a);

			function dropShadow(text, x, y, font=null, maxwidth=10000)
			{
				if (font) ctx.font = font;
				ctx.fillStyle = 'black';
				ctx.fillText(text, x + 2, y + 2, maxwidth);
				ctx.fillStyle = 'white';
				ctx.fillText(text, x, y, maxwidth);
			}

			ctx.textBaseline = 'top';
			dropShadow(set.title || "Untitled", 
				PADDING + 96 + PADDING + 5, PADDING + 5, 'bold 32px serif', WIDTH - (PADDING * 3 + 96));
			
			const authorText = authcount.length > 0 ? "Set developed by " + authcount.map(([a, _]) => a).join(', ') : "";
			dropShadow(authorText, 
				PADDING + 96 + PADDING + 10, PADDING + 48, '18px serif', WIDTH - (PADDING * 3 + 96));

			if (set.console && set.console.icon) {
				ctx.textBaseline = 'middle';
				ctx.textAlign = 'right';
				dropShadow(set.console.name, WIDTH - (2 * PADDING + 32 + PADDING), PADDING + 96 - 16, '12px serif');
			}

			// 4. Load Icons (Set & Console) - Parallel
			const iconPromises = [];
			if (set.icon) iconPromises.push(loadImage(set.icon).then(img => ({ type: 'set', img })));
			if (set.console && set.console.icon) {
				const consoleIconUrl = `https://static.retroachievements.org/assets/images/system/${set.console.icon}.png`;
				iconPromises.push(loadImage(consoleIconUrl).then(img => ({ type: 'console', img })));
			}

			const icons = await Promise.all(iconPromises);
			if (!isActive) return;

			icons.forEach(({ type, img }) => {
				if (!img) return;
				if (type === 'set') ctx.drawImage(img, PADDING, PADDING, 96, 96);
				if (type === 'console') ctx.drawImage(img, WIDTH - 2 * PADDING - 32, PADDING + 96 - 32, 32, 32);
			});

			// 5. Load Badges in Parallel Batches
			const BATCH_SIZE = 10;
			const total = achs.length;
			let loaded = 0;

			for (let i = 0; i < total; i += BATCH_SIZE) {
				if (!isActive) return;

				const batch = achs.slice(i, i + BATCH_SIZE);
				const batchPromises = batch.map((ach, batchIdx) => {
					const globalIdx = i + batchIdx;
					if (!ach.badge) return Promise.resolve();

					return loadImage(ach.badge).then(badgeImg => {
						if (!isActive) return;
						if (badgeImg) {
							let x = 2 * PADDING + (globalIdx % ROWLEN) * (64 + PADDING);
							let y = PADDING + 96 + PADDING + Math.floor(globalIdx / ROWLEN) * (64 + PADDING);
							ctx.drawImage(badgeImg, x, y, 64, 64);
						}
					});
				});

				await Promise.all(batchPromises);
				loaded += batch.length;
				setStatus(`⏳ ${Math.min(100, Math.round((loaded / total) * 100))}%`);
			}

			if (!isActive) return;
			setIsReady(true);
			setStatus("📋 Copy Image");
		};

		render();

		return () => { isActive = false; };

	}, [set]); 

	return (
		<div style={{position: 'relative', display: 'inline-block'}}>
			<button className="copy-btn" onClick={handleCopyClick} disabled={!isReady} style={{display: 'none', opacity: isReady ? 1 : 0.7, cursor: isReady ? 'pointer' : 'wait'}}>
				{status}
			</button>
			<canvas ref={canvasRef} width={WIDTH} height={HEIGHT}></canvas>
		</div>
	);
}

function SetOverviewTab()
{
	if (current.set == null) return null;
	let warn = SEVERITY_TO_CLASS[current.set.feedback.status()];
	return (
	<tr
		id="asset-set-overview" className={`asset-row ${warn}`}
		data-route=""
		onClick={(e) => show_overview(e, <AchievementSetOverview />)}
	>
		<td className="asset-name">
			🗺️ Set Overview
		</td>
	</tr>);
}

function CodeReviewTab()
{
	if (current.set == null) return null;
	return (
	<tr
		id="asset-code-review" className={`asset-row`} 
		data-route="/review"
		onClick={(e) => show_overview(e, <CodeReviewOverview />)}
	>
		<td className="asset-name">
			🔍 Detailed Set Breakdown
		</td>
	</tr>);
}

function CodeNotesTab()
{
	if (current.notes.length == 0) return null;
	let warn = SEVERITY_TO_CLASS[current.notes.feedback.status()];
	return (
	<tr 
		id="asset-code-notes" className={`asset-row ${warn}`} 
		data-route="/notes"
		onClick={(e) => show_overview(e, <CodeNotesOverview />)}
	>
		<td className="asset-name">
			📝 Code Notes
		</td>
	</tr>);
}

function RichPresenceTab()
{
	if (!current.rp || current.rp.displayStrings.length === 0) return null;
	let warn = SEVERITY_TO_CLASS[current.rp.feedback.status()];
	return (
	<tr 
		id="asset-rich-presence" className={`asset-row ${warn}`} 
		data-route="/richp"
		onClick={(e) => show_overview(e, <RichPresenceOverview />)}
	>
		<td className="asset-name">
			🎮 Rich Presence
		</td>
	</tr>);
}

function AchievementTabs()
{
	let achievements = current.set.getAchievements();
	if (achievements.length == 0) return null;

	// preload all images
	new Image().src = current.set.icon;
	for (let ach of achievements) new Image().src = ach.badge;

	achievements = achievements.sort((a, b) => a.state.rank - b.state.rank);
	return(<>
		<tr className="asset-header">
			<td>Achievements</td>
		</tr>
		{achievements.map((ach) => {
			let warn = SEVERITY_TO_CLASS[ach.feedback.status()];
			return (
			<tr 
				key={`a${ach.id}`} id={ach.toRefString()} className={`asset-row ${warn}`} 
				data-route={`/achievement/${ach.id}`}
				onClick={(e) => show_overview(e, <AchievementInfo ach={ach} />)}
			>
				<td className="asset-name">
					🏆 {ach.state.marker}{ach.title} ({ach.points})
				</td>
			</tr>);
		})}
	</>);
}

function LeaderboardTabs()
{
	let leaderboards = current.set.getLeaderboards();
	if (leaderboards.length == 0) return null;

	leaderboards = leaderboards.sort((a, b) => a.state.rank - b.state.rank);
	return(<>
		<tr className="asset-header">
			<td>Leaderboards</td>
		</tr>
		{leaderboards.map((lb) => {
			let warn = SEVERITY_TO_CLASS[lb.feedback.status()];
			return (
			<tr 
				key={`b${lb.id}`} id={lb.toRefString()} className={`asset-row ${warn}`} 
				data-route={`/leaderboard/${lb.id}`}
				onClick={(e) => show_overview(e, <LeaderboardInfo lb={lb} />)}
			>
				<td className="asset-name">
					📊 {lb.state.marker}{lb.title}
				</td>
			</tr>);
		})}
	</>);
}

function SidebarTabs()
{
	React.useEffect(route_change);

	return (<>
		<SetOverviewTab />
		<CodeNotesTab />
		<RichPresenceTab />
		<CodeReviewTab />
		<AchievementTabs />
		<LeaderboardTabs />
	</>);
}

function show_overview(e, node)
{
	container.render(
		<React.Fragment>
			<GlobalTooltip />
			{node}
		</React.Fragment>
	);
	selectTab(e.currentTarget);

	let route = e.currentTarget.getAttribute('data-route');
	history.pushState({}, '', `#!/game/${current.id}${route}`);
}

function update()
{
	// assess all code notes
	current.notes.sort((a, b) => a.addr - b.addr);
	assess_code_notes(current.notes);

	// ensure that every achievement and leaderboard has been assessed
	// don't assume they have already been processed, as code notes might be new
	for (let ach of current.set.getAchievements()) assess_achievement(ach);
	for (let lb of current.set.getLeaderboards()) assess_leaderboard(lb);

	// assess rich presence
	assess_rich_presence(current.rp);

	// set assessment relies on other assessments for some stats,
	// so this should always be the last assessment
	assess_set(current.set);

	// re-render the sidebar with any newly-loaded assets
	sidebar.render(<SidebarTabs />);

	// change document title to match loaded game
	document.title = '[AutoCR] ' + (get_game_title() ?? "");
}

function load_achievement_set(json)
{
	current.set.addJSON(json);
	if (json.RichPresencePatch)
		load_rich_presence(json.RichPresencePatch, false);
	update();
}

function load_user_file(txt)
{
	current.set.addLocal(txt, current.notes);
	update();
}

function load_code_notes(json)
{
	for (const obj of json) if (obj.Note)
		current.notes.add(new CodeNote(obj.Address, obj.Note, obj.User));
	update();
}

function load_rich_presence(txt, from_file)
{
	if (!current.rp || from_file)
		current.rp = RichPresence.fromText(txt);
	update();
}

function route_change()
{
	let parts = location.hash.toLowerCase().split('/');
	switch (parts[3] ?? "") // choose a route
	{
		case 'ach':
		case 'achievement':
			jump_to_asset(current.set.achievements.get(+parts[4]));
			break;
		case 'lb':
		case 'leaderboard':
			jump_to_asset(current.set.leaderboards.get(+parts[4]));
			break;
		case 'notes':
		case 'codenotes':
		case 'code-notes':
		case 'memory':
			document.getElementById('asset-code-notes')?.click();
			break;
		case 'richp':
		case 'richpresence':
		case 'rich-presence':
		case 'rp':
			document.getElementById('asset-rich-presence')?.click();
			break;
		case 'review':
			document.getElementById('asset-code-review')?.click();
			break;
		default:
			document.querySelectorAll('#list-body .asset-row')?.[0]?.click();
	}
}

function main(event)
{
	if (location.hash.startsWith('#!/'))
	{
		let parts = location.hash.toLowerCase().split('/');
		switch (parts[1])
		{
			case 'game':
				if (parts[2] == current.id) return route_change();
				
				reset_loaded();
				document.getElementById("loading-overlay").classList.add('shown');
				fetch('https://autocr-tools.vercel.app/pack/' + parts[2])
					.then(response => {
						if (!response.ok)
							throw new Error(`HTTP error! status: ${response.status}`);
						return response.json();
					})
					.then(data => {
						current.id = data.game?.GameId;
						current.set.addJSON(data.game);
						if (data.game.RichPresencePatch)
							load_rich_presence(data.game.RichPresencePatch, false);
						for (const obj of data.notes) if (obj.Note)
							current.notes.add(new CodeNote(obj.Address, obj.Note, obj.User));
						update();
					})
					.catch(error => {
						console.error('Error fetching data:', error);
					})
					.finally(() => {
						document.getElementById("loading-overlay").classList.remove('shown');
					});
				return;
		}
	}
}

// --------------------------------------------------
// EXPLAINER UI COMPONENTS
// --------------------------------------------------

function LogicExplanation({ asset, groups, showDecimal = true }) {
	try {
		const { mainText, detailedInfo } = LogicExplainer.explainAsset(
			asset, 
			groups, 
			current.notes, 
			null, 
			showDecimal // Pass the prop to the explainer logic.
		);

		// Helper to wrap specific phrases in colored spans
		const highlightKeywords = (text) => {
			if (!text) return null;
			
			// Regex explanations:
			// 1. (reset|pause|lock) the achievement : Long phrases are safe
			// 2. (MeasuredIf) : Distinct flag name
			// 3. \b(Measured|Measured%)\b : Strict word boundary
			// 4. \bTrigger\b : Strict word boundary
			// 5. \bActivate\b : Strict word boundary for Transition logic
			// 6. \[.*?\] : Variables/Code Notes inside brackets
			// 7. \".*?\" : Quoted Strings (Enums)
			const regex = /(reset the achievement|pause the achievement|lock the achievement|MeasuredIf|\bMeasured%?\b|\bTrigger\b|\bActivate\b|\[.*?\]|\".*?\")/g;
			
			const parts = text.split(regex);
			
			return parts.map((part, i) => {
				const lower = part.toLowerCase();

				// 1. Variable Highlighting (Remove Brackets + Truncate)
				// We detect [Variables] and strip the brackets for display
				if (part.startsWith('[') && part.endsWith(']')) {
					const content = part.substring(1, part.length - 1);
					// Use title for tooltip (full content) in case CSS truncates it
					return <span key={i} className="logic-variable" title={content}>{content}</span>;
				}

				// 2. Enum Highlighting (Remove Quotes & Italicize)
				if (part.startsWith('"') && part.endsWith('"')) {
					const content = part.substring(1, part.length - 1);
					// Check if it's just empty quotes
					if (!content) return part; 
					return <em key={i} className="logic-enum">{content}</em>;
				}

				if (lower === 'reset the achievement') return <span key={i} className="logic-keyword-reset">{part}</span>;
				if (lower === 'pause the achievement' || lower === 'lock the achievement') return <span key={i} className="logic-keyword-pause">{part}</span>;
				if (part === 'MeasuredIf') return <span key={i} className="logic-keyword-measuredif">{part}</span>;
				if (part === 'Measured' || part === 'Measured%') return <span key={i} className="logic-keyword-measured">{part}</span>;
				
				if (part === 'Trigger') {
					const nextPart = parts[i+1];
					if (nextPart && (nextPart.startsWith(" when") || nextPart.startsWith(" Indicator"))) return <span key={i} className="logic-keyword-trigger">{part}</span>;
					return part;
				}

				if (part === 'Activate') return <span key={i} className="logic-keyword-activate">{part}</span>;

				return part;
			});
		};

		// Recursive parser to handle nested [[EXPAND]] tokens
		const parseContentRecursively = (text, uniqueKeyPrefix) => {
			if (!text) return null;
			
			// 1. Split by EXPAND tokens first
			const parts = text.split(/(\[\[EXPAND:.*?:.*?\]\])/g);
			
			return parts.map((part, index) => {
				const match = part.match(/^\[\[EXPAND:(.*?):(.*?)\]\]$/);
				if (match) {
					const id = match[1];
					const label = match[2];
					const rawDetailText = detailedInfo[id] || "No details found.";
					
					return (
						<details key={`${uniqueKeyPrefix}-${index}`} className="explainer-details" style={{display: 'inline-block', verticalAlign: 'top', margin: '2px'}}>
							<summary>{label}</summary>
							<div style={{marginTop: '5px', whiteSpace: 'pre-wrap'}}>
								{/* Recursively parse the inner detail text for nested structures */}
								{parseContentRecursively(rawDetailText, `${uniqueKeyPrefix}-${index}-inner`)}
							</div>
						</details>
					);
				}
				
				// 2. Process text for keywords and variables
				return <React.Fragment key={`${uniqueKeyPrefix}-${index}`}>{highlightKeywords(part)}</React.Fragment>;
			});
		};

		const renderLines = () => {
			const lines = mainText.split('\n');
			const elements = [];
			
			let listBuffer = [];

			const flushList = () => {
				if (listBuffer.length > 0) {
					const isFirst = elements.length === 0;
					const style = isFirst ? { marginTop: 0 } : undefined;
					elements.push(<ul key={`ul-${elements.length}`} style={style}>{listBuffer}</ul>);
					listBuffer = [];
				}
			};

			for (let i = 0; i < lines.length; i++) {
				let line = lines[i].trimEnd();
				
				if (line.trim() === "") {
					flushList();
					continue;
				}

				// Determine if this is the very first element to remove top margin
				const isFirst = elements.length === 0 && listBuffer.length === 0;
				const style = isFirst ? { marginTop: 0 } : undefined;

				// Markdown Headers
				if (line.startsWith("# ")) {
					flushList();
					// Parse content recursively in headers to support [[EXPAND]]
					elements.push(<h1 key={i} style={style}>{parseContentRecursively(line.substring(2), `h1-${i}`)}</h1>);
				}
				else if (line.startsWith("## ")) {
					flushList();
					// Parse content recursively in headers to support [[EXPAND]]
					elements.push(<h2 key={i} style={style}>{parseContentRecursively(line.substring(3), `h2-${i}`)}</h2>);
				}
				else if (line.startsWith("### ")) {
					flushList();
					// Parse content recursively in headers to support [[EXPAND]]
					elements.push(<h3 key={i} style={style}>{parseContentRecursively(line.substring(4), `h3-${i}`)}</h3>);
				}
				// List Items
				else if (line.startsWith("- ")) {
					// Use recursive parser for list items
					listBuffer.push(<li key={i}>{parseContentRecursively(line.substring(2), `li-${i}`)}</li>);
				}
				// Top-level block expanders (like Array Logic Details)
				else if (line.startsWith("[[EXPAND:")) {
					flushList();
					elements.push(<div key={i} style={style}>{parseContentRecursively(line, `block-${i}`)}</div>);
				}
				// Standard Paragraphs
				else {
					flushList();
					elements.push(<p key={i} style={style}>{parseContentRecursively(line, `p-${i}`)}</p>);
				}
			}
			flushList();
			return elements;
		};

		return (
			<div className="logic-explanation">
				{renderLines()}
			</div>
		);
	} catch (e) {
		console.error(e);
		return (
			<div className="logic-explanation" style={{color: 'red', border: '1px solid red', padding: '10px'}}>
				<h3>⚠️ Explainer Error</h3>
				<p>An error occurred while generating the explanation:</p>
				<pre>{e.message}</pre>
				<pre>{e.stack}</pre>
			</div>
		);
	}
}

let _testIndex = 0;
function testAchievement(mem)
{
	_testIndex += 1;
	let id = 9000000 + _testIndex;
	current.set.achievements.set(id, 
		Achievement.fromJSON({
			ID: id,
			Title: `Test Achievement #${_testIndex}`,
			Description: `Test Achievement #${_testIndex}`,
			Points: 0,
			Author: "Test User",
			Type: "",
			Flags: 5,
			MemAddr: mem,
		})
	);
	update();
}

reset_loaded();
main();
window.onhashchange = main;

// --- AutoCR Side Panel Toggle Feature & Main Layout Splitter ---
(function initAutoCRSidebarLayout() {
	// 1. Inject Transition CSS
	if (!document.getElementById('autocr-dynamic-slide-css')) {
		const style = document.createElement('style');
		style.id = 'autocr-dynamic-slide-css';
		style.innerHTML = `
			#asset-list {
				transition: flex-basis 0.3s cubic-bezier(0.4, 0, 0.2, 1), width 0.3s cubic-bezier(0.4, 0, 0.2, 1), min-width 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.2s ease, padding 0.3s ease;
			}
			/* When disabled via JS during drag, removing the class removes the transition */
			#asset-list.no-transition {
				transition: none !important;
			}
			body.autocr-sidebar-hidden #asset-list {
				flex-basis: 0 !important;
				width: 0 !important;
				min-width: 0 !important;
				padding-left: 0 !important;
				padding-right: 0 !important;
				border: none !important;
				opacity: 0 !important;
			}
			body.autocr-sidebar-hidden #main-splitter {
				display: none !important;
			}
			/* Keep hidden until animation completes */
			body.autocr-sidebar-fully-hidden #autocr-restore-btn {
				display: block !important;
			}
		`;
		document.head.appendChild(style);
	}

	// 2. Create the Splitter between asset-list and asset-info
	const assetList = document.getElementById('asset-list');
	const assetInfo = document.getElementById('asset-info');
	
	if (assetList && assetInfo && !document.getElementById('main-splitter')) {
		const splitter = document.createElement('div');
		splitter.id = 'main-splitter';
		splitter.className = 'resizer-x';
		
		// Insert between sidebar and main info
		assetList.parentNode.insertBefore(splitter, assetInfo);

		let isDragging = false;
		splitter.addEventListener('mousedown', (e) => {
			isDragging = true;
			assetList.classList.add('no-transition'); // prevent sluggish dragging
			splitter.classList.add('active');
			document.body.style.cursor = 'col-resize';
			e.preventDefault();
		});

		document.addEventListener('mousemove', (e) => {
			if (!isDragging) return;
			let newWidth = e.clientX;
			if (newWidth < 200) newWidth = 200; // minimum width
			if (newWidth > window.innerWidth * 0.8) newWidth = window.innerWidth * 0.8; // max width
			
			// Force absolute width everywhere so the internal table natively expands
			assetList.style.flexBasis = newWidth + 'px';
			assetList.style.width = newWidth + 'px';
			assetList.style.minWidth = newWidth + 'px';
			assetList.style.maxWidth = 'none';
		});

		document.addEventListener('mouseup', () => {
			if (isDragging) {
				isDragging = false;
				assetList.classList.remove('no-transition');
				splitter.classList.remove('active');
				document.body.style.cursor = 'default';
			}
		});
	}

	// 3. Create the persistent Restore Button (Hidden when sidebar is active)
	if (!document.getElementById('autocr-restore-btn')) {
		const restoreBtn = document.createElement('button');
		restoreBtn.id = 'autocr-restore-btn';
		restoreBtn.innerHTML = '&#x25B6;'; // ▶
		restoreBtn.title = 'Show AutoCR Side Panel';
		restoreBtn.style.position = 'fixed';
		restoreBtn.style.bottom = '11px';
		restoreBtn.style.left = '10px';
		restoreBtn.style.zIndex = '99999';
		restoreBtn.style.display = 'none'; // CSS toggles this
		restoreBtn.style.padding = '6px 12px'; // Squarish to match the screenshot footprint
		
		restoreBtn.addEventListener('click', () => {
			document.body.classList.remove('autocr-sidebar-fully-hidden');
			document.body.classList.remove('autocr-sidebar-hidden');
		});
		document.body.appendChild(restoreBtn);
	}

	// 4. Reliable loop to inject the Collapse button into the Sidebar footer next to Unload
	setInterval(() => {
		const footerTd = document.querySelector('#list-foot td');
		
		if (footerTd && !footerTd.querySelector('.autocr-collapse-btn')) {
			const collapseBtn = document.createElement('button');
			collapseBtn.innerHTML = '&#x25C0;'; // ◀
			collapseBtn.title = 'Hide Side Panel';
			collapseBtn.className = 'autocr-collapse-btn';
			collapseBtn.style.padding = '6px 12px';
			collapseBtn.style.marginRight = '5px'; // Separate it slightly from "Unload Set"
			
			collapseBtn.addEventListener('click', () => {
				document.body.classList.add('autocr-sidebar-hidden');
				setTimeout(() => {
					// Only add fully-hidden class if it hasn't been un-hidden in the meantime
					if (document.body.classList.contains('autocr-sidebar-hidden')) {
						document.body.classList.add('autocr-sidebar-fully-hidden');
					}
				}, 300); // 300ms matches the CSS transition duration
			});
			
			// Insert BEFORE the Unload Set button
			footerTd.insertBefore(collapseBtn, footerTd.firstChild);
		}
	}, 500); 
})();