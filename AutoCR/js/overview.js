const sidebar = ReactDOM.createRoot(document.getElementById('list-body'));
const container = ReactDOM.createRoot(document.getElementById('info-container'));

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

var current = { id: -1, };
function reset_loaded()
{
	current.set = new AchievementSet();
	current.notes = [];
	current.rp = null;
	clearSelected();
}

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
	for (const file of event.dataTransfer.files)
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
				try
				{
					let data = JSON.parse(event.target.result);
					load_code_notes(data);
				}
				catch (e)
				{
					if (e instanceof LogicParseError) alert(e.message);
					else console.error(e);
				}
			};
		else if (file.name.endsWith('.json'))
			reader.onload = function(event)
			{
				try
				{
					let data = JSON.parse(event.target.result);
					load_achievement_set(data);
				}
				catch (e)
				{
					if (e instanceof LogicParseError) alert(e.message);
					else console.error(e);
				}
			};
		else if (file.name.endsWith('-Rich.txt'))
			reader.onload = function(event)
			{
				try
				{
					let data = event.target.result;
					load_rich_presence(data, true);
				}
				catch (e)
				{
					if (e instanceof LogicParseError) alert(e.message);
					else console.error(e);
				}
			};
		else if (file.name.endsWith('-User.txt'))
			reader.onload = function(event)
			{
				try
				{
					let data = event.target.result;
					load_user_file(data);
				}
				catch (e)
				{
					if (e instanceof LogicParseError) alert(e.message);
					else console.error(e);
				}
			};
		reader.readAsText(file);
	}
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

function get_game_title()
{
	if (current.set) return current.set.title;
	return null;
}

function get_note_text(addr)
{
	let note = get_note(addr, current.notes);
	if (!note) return null;

	let note_text = "";
	let relevant_text = note.note;
	if (addr != note.addr)
	{
		let base = '0x' + note.addr.toString(16).padStart(8, '0');
		let offset = '0x' + (addr - note.addr).toString(16);
		note_text += `[Indirect ${base} + ${offset}]\n`;
	}
	note_text += relevant_text;
	return note_text;
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
{ document.getElementById('asset-list').getElementsByClassName(asset?.toRefString?.()).item(0)?.click(); }

function LogicTable({logic, issues = []})
{
	const [isHex, setIsHex] = React.useState(false);
	issues = [].concat(...issues);

	const COLUMNS = 10;
	function OperandCells({operand, skipNote = false})
	{
		function OperandValue()
		{
			if (operand == null) return null;
			// if it has no type, skip
			if (!operand.type) return operand.toString();
			// if this is a memory read, add the code note, if possible
			else if (operand.type.addr)
			{
				const note_text = get_note_text(operand.value);
				if (!skipNote && note_text) return (
					<span className="tooltip">
						{operand.toValueString()}
						<span className="tooltip-info">
							<pre>{note_text}</pre>
						</span>
					</span>
				);
				else return operand.toValueString();
			}
			// if it is a value, integers need both representations
			else if (Number.isInteger(operand.value) && operand.type != ReqType.FLOAT)
			{
				return (<>
					<span className="in-dec">{operand.value.toString()}</span>
					<span className="in-hex">0x{operand.value.toString(16).padStart(8, '0')}</span>
				</>);
			}

			// if we don't know what to do, just return the value
			return operand.toString();
		}
		return (<>
			<td>{operand ? operand.type.name : ''}</td>
			<td>{operand && operand.size ? operand.size.name : ''}</td>
			<td><OperandValue /></td>
		</>);
	}
	function LogicGroup({group, gi})
	{
		let header = gi == 0 ? "Core Group" : `Alt Group ${gi}`;
		if (logic.value) header = `Value Group ${gi+1}`;

		return (<>
			<tr className="group-hdr header">
				<td colSpan={COLUMNS}>{header}</td>
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
				let skipNote = ri > 0 && group[ri-1].flag && group[ri-1].flag == ReqFlag.ADDADDRESS;
				return (<tr key={`g${gi}-r${ri}`} className={`${match.some(([_, issue]) => issue.type.severity >= FeedbackSeverity.WARN) ? 'warn ' : ''}${req.toRefString()}`}>
					<td>{ri + 1} {match.map(([ndx, _]) => 
						<React.Fragment key={ndx}>{' '} <sup key={ndx}>(#{ndx+1})</sup></React.Fragment>)}</td>
					<td>{req.flag ? req.flag.name : ''}</td>
					<OperandCells operand={req.lhs} skipNote={skipNote} />
					<td>{req.op ? req.op : ''}</td>
					<OperandCells operand={req.rhs} skipNote={skipNote} />
					<td data-hits={req.hits}>{req.hasHits() ? `(${req.hits})` : ''}</td>
				</tr>);
			})}
		</>);
	}

	return (<div className="logic-table">
		<table className={isHex ? 'show-hex' : ''}>
			<tbody>
				{[...logic.groups.entries()].map(([gi, g]) => {
					return (<LogicGroup key={gi} group={g} gi={gi} />);
				})}
			</tbody>
		</table>
		<button className="float-right" onClick={() => setIsHex(!isHex)}>
			Toggle Hex Values
		</button>
		<button className="float-right" onClick={() => copy_to_clipboard(logic.toMarkdown())}>
			Copy Markdown
		</button>
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
			<li>Requirements with hitcounts: {stats.hit_counts_one + stats.hit_counts_many}</li>
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
		<li><span title="Number of unique lookups, including lookups with AddAddress">Memory Lookup Count</span>: {stats.memlookups.size} {logic && logic.value ? '' : (stats.addresses.size <= 1 ? '(definite OCA)' : (stats.memlookups.size <= 1 ? '(possible OCA)' : ''))}</li>
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
				if (ctarget) scrollTo(document.getElementsByClassName(ctarget).item(0));
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

function AchievementBadge({ach})
{
	return (<a href={`https://retroachievements.org/achievement/${ach.id}`}>
		<img className="icon float-left" src={ach.badge ? ach.badge : "https://media.retroachievements.org/Images/000001.png"} />
	</a>);
}

function AchievementCard({ach, warn})
{
	let icon = null;
	if (ach.achtype == 'progression')   icon = <span title="progression">✅</span>;
	if (ach.achtype == 'win_condition') icon = <span title="win_condition">🏅</span>;
	if (ach.achtype == 'missable')      icon = <span title="missable">⚠️</span>;

	return (<div className={"asset-card" + (warn ? " warning" : "")} onClick={() => { jump_to_asset(ach); }}>
		<div>
			<img className="icon" src={ach.badge ? ach.badge : "https://media.retroachievements.org/Images/000001.png"} />
		</div>
		<div>
			<p>🏆 <strong>{ach.title}</strong> ({ach.points}) {icon}</p>
			<p><em>{ach.desc}</em></p>
		</div>
	</div>);
}

function AchievementInfo({ach})
{
	let feedback = ach.feedback;
	let feedback_targets = new Set([].concat(...feedback.issues).map(x => x.target));

	return (<>
		<div className="main-header">
			<AchievementBadge ach={ach} />
			<div>
				<button className="float-right" onClick={() => copy_to_clipboard(`[${ach.title}](https://retroachievements.org/achievement/${ach.id})`)}>
					Copy Markdown Link
				</button>
			</div>
			<h2 className="asset-title">
				🏆 <span className={`${feedback_targets.has("title") ? 'warn' : ''}`}>{ach.title}</span> ({ach.points})
			</h2>
			<div className="float-right">
				<em>{`[${[ach.state.name, ach.achtype].filter(x => x).join(', ')}]`}</em>
			</div>
			<p className="asset-desc">
				<span className={`${feedback_targets.has("desc") ? 'warn' : ''}`}>{ach.desc}</span>
			</p>
		</div>
		<div className="data-table">
			<LogicTable logic={ach.logic} issues={feedback.issues} />
		</div>
		<div className="stats">
			<h1>Statistics</h1>
			<LogicStats logic={ach.logic} stats={feedback.stats} />
		</div>
		<AssetFeedback issues={feedback.issues} />
	</>);
}

function LeaderboardInfo({lb})
{
	let feedback = lb.feedback;
	let feedback_targets = new Set([].concat(...feedback.issues).map(x => x.target));

	const COMPONENTS = ["START", "CANCEL", "SUBMIT", "VALUE"];
	function LeaderboardComponentStats()
	{
		function SectionStats({ block = null })
		{
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
			<h2 className="asset-title">
				📊 <span className={`${feedback_targets.has("title") ? 'warn' : ''}`}>{lb.title}</span>
			</h2>
			<div className="float-right">
				<em>{`[${[lb.state.name, ].filter(x => x).join(', ')}]`}</em>
			</div>
			<p className="asset-desc">
				<span className={`${feedback_targets.has("desc") ? 'warn' : ''}`}>{lb.desc}</span>
			</p>
		</div>
		<div className="data-table">
			{COMPONENTS.map(block => <React.Fragment key={block}>
				<h3>{block}</h3>
				<LogicTable logic={lb.components[block.substring(0, 3)]} issues={feedback.issues} />
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
	
	return (<>
		<div className="main-header">
			<div className="float-right">
				<ConsoleIcon />
			</div>
			<SetBadge />
			<h1 className="asset-title">
				{get_game_title()}
			</h1>
			<p>
				Set contains {set_contents.filter(([c, _]) => c).map(([c, t]) => `${c} ${t}${c == 1 ? '' : 's'}`).join(' and ')}
			</p>
		</div>
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

	function AchievementCardList({achs, label, warn = []})
	{
		let body = achs.map(ach => (
			<AchievementCard key={ach.id} ach={ach} 
				warn={ach.feedback.issues.some(g => g.some(issue => warn.includes(issue.type) && issue.type.severity > FeedbackSeverity.PASS))}
			/>
		));

		return (<li><details>
			<summary>{label}: {achs.length} asset{achs.length == 1 ? "" : "s"}</summary>
			<ul>{body}</ul>
		</details></li>);
	}

	function AchievementsByFlag({flag, warn = []})
	{
		return (
			<AchievementCardList
				achs={[...stats.using_flag.get(flag)]}
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
			<h1 className="asset-title">
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
					<AchievementCardList
						achs={achievements.filter(ach => ach.feedback.stats.unique_cmps.size > 1 || !ach.feedback.stats.unique_cmps.has('='))}
						label={<>Using non-equality comparators</>}
					/>
				</ul>
				<li>Memory Sizes used ({stats.all_sizes.size}): <KeywordList list={[...stats.all_sizes].map(x => x.name)} /></li>
				<ul>
					<AchievementCardList
						achs={achievements.filter(ach => ach.feedback.stats.unique_sizes.size > 1 || !ach.feedback.stats.unique_cmps.has(MemSize.BYTE))}
						label={<>Using sizes other than <code>8-bit</code></>}
						warn={[Feedback.TYPE_MISMATCH, ]}
					/>
					<AchievementCardList
						achs={stats.using_bit_ops}
						label={<>Using bit operations (<code>BitX</code> or <code>BitCount</code>)</>}
					/>
				</ul>
				<li><code>Mem</code> & <code>Delta</code> Usage</li>
				<ul>
					<AchievementCardList
						achs={achievements.filter(ach => ach.feedback.issues.some(g => g.some(x => x.type == Feedback.MISSING_DELTA)))} 
						label={<>Lacking <code>Delta</code></>}
					/>
					<AchievementCardList
						achs={achievements.filter(ach => ach.feedback.issues.some(g => g.some(x => x.type == Feedback.IMPROPER_DELTA)))}
						label={<>Using <code>Delta</code> improperly or insufficiently</>}
					/>
				</ul>
				<AchievementCardList
					achs={stats.using_alt_groups}
					label={<>Using Alt groups</>}
					warn={[Feedback.COMMON_ALT, Feedback.USELESS_ALT, ]}
				/>
				<li>Hitcounts</li>
				<ul>
					<AchievementCardList
						achs={stats.using_checkpoint_hits}
						label={<>Using Checkpoint hits</>}
						warn={[Feedback.HIT_NO_RESET, Feedback.RESET_HITCOUNT_1, ]}
					/>
					<AchievementCardList
						achs={stats.using_hitcounts}
						label={<>Using hitcounts (<code>&gt;1</code>)</>}
						warn={[Feedback.HIT_NO_RESET, ]}
					/>
				</ul>
				<li>Specific Flags</li>
				<ul>
					<AchievementsByFlag
						flag={ReqFlag.RESETIF}
						warn={[Feedback.PAUSELOCK_NO_RESET, Feedback.HIT_NO_RESET, Feedback.UUO_RESET, Feedback.RESET_HITCOUNT_1, ]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.PAUSEIF}
						warn={[Feedback.PAUSELOCK_NO_RESET, Feedback.UUO_PAUSE, Feedback.PAUSING_MEASURED, ]}
					/>
				</ul>
			</ul>
			<h1>Intermediate Toolkit</h1>
			<ul>
				<AchievementCardList
					achs={achievements.filter(ach => ach.feedback.stats.priors > 0)}
					label={<>Using <code>Prior</code></>}
					warn={[Feedback.BAD_PRIOR, ]}
				/>
				<li>Specific Flags</li>
				<ul>
					<AchievementsByFlag
						flag={ReqFlag.ANDNEXT}
						warn={[Feedback.USELESS_ANDNEXT, ]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.ADDHITS}
						warn={[Feedback.HIT_NO_RESET, ]}
					/>
				</ul>
			</ul>
			<h1>Advanced Toolkit</h1>
			<ul>
				<li>PauseLocks</li>
				<ul>
					<AchievementCardList
						achs={stats.using_pauselock}
						label={<>PauseLocks</>}
						warn={[Feedback.PAUSELOCK_NO_RESET, ]}
					/>
					<AchievementCardList
						achs={stats.using_pauselock_alt_reset}
						label={<>PauseLocks (with Alt resets)</>}
						warn={[Feedback.PAUSELOCK_NO_RESET, ]}
					/>
				</ul>
				<AchievementCardList
					achs={achievements.filter(ach => ach.feedback.stats.mem_del > 0)}
					label={<>Using a <code>Mem</code> &ne; <code>Delta</code> counter</>}
					warn={[]}
				/>
				<li>Specific Flags</li>
				<ul>
					<AchievementsByFlag
						flag={ReqFlag.RESETNEXTIF}
						warn={[Feedback.PAUSELOCK_NO_RESET, Feedback.HIT_NO_RESET, Feedback.UUO_RNI, ]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.SUBHITS}
						warn={[Feedback.HIT_NO_RESET, ]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.ADDADDRESS}
						warn={[Feedback.STALE_ADDADDRESS, ]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.ADDSOURCE}
						warn={[]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.SUBSOURCE}
						warn={[]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.MEASURED}
						warn={[Feedback.PAUSING_MEASURED, ]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.MEASUREDP}
						warn={[Feedback.PAUSING_MEASURED, ]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.MEASUREDIF}
						warn={[]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.TRIGGER}
						warn={[]}
					/>
					<AchievementsByFlag
						flag={ReqFlag.ORNEXT}
						warn={[]}
					/>
				</ul>
				<AchievementCardList
					achs={achievements.filter(ach => [...ach.feedback.stats.source_modification.values()].some(x => x > 0))}
					label={<>Using source modification</>}
					warn={[]}
				/>
			</ul>
			<h1>Other Details</h1>
			<ul>
				<AchievementCardList
					achs={achievements.filter(ach => ach.points == 25)}
					label={<>Achievements worth 25 points</>}
					warn={[]}
				/>
				<AchievementCardList
					achs={achievements.filter(ach => ach.points > 25)}
					label={<>Achievements worth &gt;25 points</>}
					warn={[]}
				/>
			</ul>
		</div>
	</>)
}

function CodeNotesTable({notes = [], issues = []})
{
	function toDisplayHex(addr)
	{ return '0x' + addr.toString(16).padStart(8, '0'); }

	issues = [].concat(...issues);
	return (<div className="data-table">
		<table className="code-notes">
			<thead>
				<tr className="group-hdr header">
					<td colSpan="3">Code Notes</td>
				</tr>
				<tr className="col-hdr header">
					<td>Address</td>
					<td>Note</td>
					<td>Author</td>
				</tr>
			</thead>
			<tbody>
				{notes.map(note => (
					<tr key={note.addr} className={`${issues.some(x => x.target == note) ? 'warn ' : ''}${note.toRefString()}`}>
						<td>{toDisplayHex(note.addr)}{note.isArray() ? (<><br/>&#x2010;&nbsp;{toDisplayHex(note.addr + note.size - 1)}</>) : <></>}</td>
						<td><pre>{note.note}</pre></td>
						<td>
							<span className="tooltip">
								<a href={`https://retroachievements.org/user/${note.author}`}>
									<img src={`https://media.retroachievements.org/UserPic/${note.author}.png`} width="24" height="24" />
								</a>
								<span className="tooltip-info">
									{note.author}
								</span>
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

	let displaynotes = current.notes.filter(note => authState[note.author]);
	if (warnsOnly) displaynotes = displaynotes.filter(note => feedback_targets.has(note))
	let displayissues = feedback.issues.filter(issue => !issue.target || displaynotes.includes(issue.target));

	return (<>
		<div className="main-header">
			<div className="float-right">
				<ConsoleIcon />
			</div>
			<SetBadge href={`https://retroachievements.org/codenotes.php?g=${current.id}`} />
			<h1 className="asset-title">
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
					Only show warnings <input type="checkbox" onChange={(e) => {
						setWarnsOnly(e.currentTarget.checked);
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

/*
function HighlightedRichPresence({script})
{
	let refs = {};
	function addLookups(text)
	{ 
		let parts = text.split(/(@[ _a-z][ _a-z0-9]*\(.+?\))/gi);
		for (let i = 1; i < parts.length; i += 2)
		{
			let m = parts[i].split(/@([ _a-z][ _a-z0-9]*)\((.+?)\)/i);
			parts[i] = <span className="lookup">@<span class="link">{m[1]}</span>(<span className="value logic">{m[2]}</span>)</span>;
		}
		return parts;
	}
}
*/
function HighlightedRichPresence({script, update = null})
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
				update(<LogicTable logic={logic} />);
			}
	});

	function addLookups(t)
	{ return t.replaceAll(/(@([ _a-z][ _a-z0-9]*)\((.+?)\))/gi, '<span class="lookup">@<span class="link">$2</span>(<span class="value logic">$3</span>)</span>'); }

	let display = false;
	let rptext = script.split(/\r\n|(?!\r\n)[\n-\r\x85\u2028\u2029]/g).map(line => {
		line = line.trim();
		if (display) line = line.startsWith('?')
			? line.replaceAll(/\?(.+)\?(.*)/g, (_, p1, p2) => `?<span class="condition logic">${p1}</span>?${addLookups(p2)}`)
			: addLookups(line);
		if (line.startsWith('Display:')) display = true;
		return line;
	}).join('\n');
	rptext = rptext.replaceAll(/((Lookup|Format|Display):([a-zA-Z0-9_ ]+))/g, '<span class="header" id="def-$3">$1</span>');

	return (<div className="rich-presence clear">
		<pre><code ref={ref} dangerouslySetInnerHTML={{__html: rptext}}></code></pre>
	</div>);
}

function RichPresenceOverview()
{
	const feedback = current.rp.feedback;
	const feedback_targets = new Set([].concat(...feedback.issues).map(x => x.target));
	const stats = feedback.stats;

	const logictbl = React.useRef();
	const [logic, setLogic] = React.useState(null);

	// if the logic table is updated with data, scroll it into view
	React.useEffect(() => {
		if (logic != null)
			logictbl.current.scrollIntoView({behavior: 'smooth', block: 'nearest'});
	}, [logic]);

	return (<>
		<div className="main-header">
			<div className="float-right">
				<ConsoleIcon />
			</div>
			<SetBadge />
			<h1 className="asset-title">
				{get_game_title()}
			</h1>
		</div>

		<HighlightedRichPresence script={current.rp.text} update={setLogic} />
		<div className="data-table" ref={logictbl}>
			{logic}
		</div>

		<div className="stats">
			<h1>Statistics</h1>
			<ul>
				<li>Memory size: {stats.mem_length} / 65535</li>
				<li>Custom macros: {stats.custom_macros.size}</li>
				<ul>
					{[...stats.custom_macros.entries()].map(([k, v]) => <li key={k}><code>{k}</code> &rarr; {v ? <code>{v.type}</code> : 'unknown'}</li>)}
				</ul>
				<li>Lookups: {stats.lookups.size} ({[...stats.lookups.values()].filter(lookup => lookup.some(x => x.isFallback())).length} with default values)</li>
				<li>Display clauses: {stats.display_groups} ({stats.cond_display} conditional displays)</li>
				<ul>
					<li>Most lookups in one display clause: {stats.max_lookups}</li>
				</ul>
			</ul>
		</div>

		<AssetFeedback issues={feedback.issues} />
	</>);
}

const SEVERITY_TO_CLASS = ['pass', 'warn', 'fail', 'fail'];
function SetOverviewTab()
{
	if (current.set == null) return null;
	let warn = SEVERITY_TO_CLASS[current.set.feedback.status()];
	return (<tr className={`asset-row asset-set-overview ${warn}`} onClick={(e) => show_overview(e, <AchievementSetOverview />)}>
		<td className="asset-name">
			🗺️ Set Overview
		</td>
	</tr>);
}

function CodeReviewTab()
{
	if (current.set == null) return null;
	return (<tr className={`asset-row asset-code-review`} onClick={(e) => show_overview(e, <CodeReviewOverview />)}>
		<td className="asset-name">
			🔍 Detailed Set Breakdown
		</td>
	</tr>);
}

function CodeNotesTab()
{
	if (current.notes.length == 0) return null;
	let warn = SEVERITY_TO_CLASS[current.notes.feedback.status()];
	return (<tr className={`asset-row asset-code-notes ${warn}`} onClick={(e) => show_overview(e, <CodeNotesOverview />)}>
		<td className="asset-name">
			📝 Code Notes
		</td>
	</tr>);
}

function RichPresenceTab()
{
	if (!current.rp) return null;
	let warn = SEVERITY_TO_CLASS[current.rp.feedback.status()];
	return (<tr className={`asset-row asset-rich-presence ${warn}`} onClick={(e) => show_overview(e, <RichPresenceOverview />)}>
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
	for (let ach of achievements) new Image().src = ach.badge;

	achievements = achievements.sort((a, b) => a.state.rank - b.state.rank);
	return(<>
		<tr className="asset-header">
			<td>Achievements</td>
		</tr>
		{achievements.map((ach) => {
			let warn = SEVERITY_TO_CLASS[ach.feedback.status()];
			return (<tr key={`a${ach.id}`} className={`asset-row ${ach.toRefString()} ${warn}`} onClick={(e) => show_overview(e, <AchievementInfo ach={ach} />)}>
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
			return (<tr key={`b${lb.id}`} className={`asset-row ${lb.toRefString()} ${warn}`} onClick={(e) => show_overview(e, <LeaderboardInfo lb={lb} />)}>
				<td className="asset-name">
					📊 {lb.state.marker}{lb.title}
				</td>
			</tr>);
		})}
	</>);
}

function SidebarTabs()
{
	React.useEffect(() => {
		if (document.querySelectorAll('#list-body .selected').length == 0)
		{
			let first = document.querySelector('#list-body .asset-row');
			if (first) first.click();
		}
	})

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
	container.render(node);
	selectTab(e.currentTarget);
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
		current.notes.push(new CodeNote(obj.Address, obj.Note, obj.User));
	update();
}

function load_rich_presence(txt, from_file)
{
	if (!current.rp || from_file)
		current.rp = RichPresence.fromText(txt);
	update();
}