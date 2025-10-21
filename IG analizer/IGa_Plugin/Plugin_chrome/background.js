// Background Service Worker - Simplified
console.log('Instagram Followers Scraper background script loaded');

// Handle extension installation
chrome.runtime.onInstalled.addListener((details) => {
    console.log('Extension installed/updated:', details.reason);
});

// Handle messages between content script and popup
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log('Background received message:', message);
    
    // Handle badge updates
    if (message.action === 'updateBadge') {
        chrome.action.setBadgeText({
            text: message.count > 0 ? message.count.toString() : '',
            tabId: sender.tab.id
        });
        chrome.action.setBadgeBackgroundColor({
            color: '#E1306C',
            tabId: sender.tab.id
        });
    }
    
    return true; // Keep message channel open
});