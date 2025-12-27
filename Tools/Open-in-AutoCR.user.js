// ==UserScript==
// @name         Open in AutoCR
// @namespace    http://tampermonkey.net/
// @version      2025-12-27
// @description  adds Open in AutoCR button to game page
// @author       authorblues
// @match        https://retroachievements.org/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=retroachievements.org
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

	function addButton()
    {
        const buttonContainer = document.querySelector('div.-mt-1 > div:nth-child(2) > div:nth-child(1)');
        let button = buttonContainer.firstElementChild.cloneNode(true);

        button.querySelector('svg').parentNode.remove();
        button.firstElementChild.innerText = 'Open in AutoCR';
        buttonContainer.append(button);

        button.onclick = (e) => {
            let gameid = window.location.href.split('/game/')[1];
            window.location.href = 'https://authorblues.github.io/retroachievements/AutoCR/#!/game/' + gameid;
        };
    }

    let currentPath = window.location.pathname;
    let currentHash = window.location.hash;

    function onPageLoad(p)
	{
		if (p.startsWith('/game/'))
			setTimeout(addButton, 500);
    }

    function checkUrlChange()
	{
        const newPath = window.location.pathname;
        const newHash = window.location.hash;
        const fullOldPath = currentPath + currentHash;
        const fullNewPath = newPath + newHash;

        if (fullOldPath !== fullNewPath)
		{
            onPageLoad(newPath);
            currentPath = newPath;
            currentHash = newHash;
        }
    }

    const originalPushState = history.pushState;
    const originalReplaceState = history.replaceState;

    history.pushState = function(...args)
	{
        const result = originalPushState.apply(this, args);
        checkUrlChange();
        return result;
    };

    history.replaceState = function(...args)
	{
        const result = originalReplaceState.apply(this, args);
        checkUrlChange();
        return result;
    };

    window.addEventListener('popstate', checkUrlChange);
    window.addEventListener('hashchange', checkUrlChange);
	onPageLoad(currentPath);
})();
