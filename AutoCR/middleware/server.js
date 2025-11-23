import express from 'express';
import {username, password} from './credentials.js';

const app = express();
app.use((req, res, next) =>
{
	res.setHeader("Access-Control-Allow-Origin", "*");
	res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
	res.setHeader("Access-Control-Allow-Headers", "Content-Type");

	if (req.method === "OPTIONS") {
		return res.status(200).end();
	}

	next();
});

async function doRequest(query)
{
	const params = new URLSearchParams(query);
	const res = await fetch(`https://retroachievements.org/dorequest.php?${params.toString()}`, {
		headers: { 'User-Agent': 'authorblues-tools/1.0' },
	});
	const body = await res.json();
	return body;
}

async function login()
{
	const data = await doRequest({ r: 'login2', u: username, p: password, });
	return data.Token;
}

app.get('/game/:id', async (req, res) =>
{
	try {
		const token = await login();
		const gameid = parseInt(req.params.id, 10);
		console.log(`[request] game ${gameid}`);
		
		const data = await doRequest({ r: 'achievementsets', t: token, g: gameid });
		res.send(data);
	} catch (err) {
		console.error(err);
		res.status(500).send('Error fetching achievements');
	}
});

app.get('/notes/:id', async (req, res) =>
{
	try {
		const token = await login();
		const gameid = parseInt(req.params.id, 10);
		console.log(`[request] notes ${gameid}`);
		
		const data = await doRequest({ r: 'codenotes2', t: token, g: gameid });
		res.send(data.CodeNotes);
	} catch (err) {
		console.error(err);
		res.status(500).send('Error fetching code notes');
	}
});

app.get('/pack/:id', async (req, res) =>
{
	try {
		const token = await login();
		const gameid = parseInt(req.params.id, 10);
		console.log(`[request] pack ${gameid}`);
		
		let pack = {};
		pack.game = await doRequest({ r: 'achievementsets', t: token, g: gameid });
		pack.notes = (await doRequest({ r: 'codenotes2', t: token, g: gameid })).CodeNotes;
		res.send(pack);
	} catch (err) {
		console.error(err);
		res.status(500).send('Error fetching data pack');
	}
});

app.get('/', (req, res) =>
{
	res.send('Hello RetroAchievements!');
});

export default app;