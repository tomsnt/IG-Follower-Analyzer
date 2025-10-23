// popup.js - Manual Selection Mode
class InstagramFollowersPopup {
    constructor() {
        this.followers = [];
        this.isObserving = false;
        this.initializeElements();
        this.bindEvents();
        this.checkInstagramTab();
        this.startPeriodicUpdate();
    }

    initializeElements() {
        this.startBtn = document.getElementById('startBtn');
        this.stopBtn = document.getElementById('stopBtn');
        this.downloadBtn = document.getElementById('downloadBtn');
        this.statusDiv = document.getElementById('status');
        this.progressDiv = document.getElementById('progress');
        this.progressFill = document.getElementById('progressFill');
        this.progressText = document.getElementById('progressText');
        this.statsDiv = document.getElementById('stats');
        this.followersCount = document.getElementById('followersCount');
    }

    bindEvents() {
        this.startBtn.addEventListener('click', () => this.startSelection());
        this.stopBtn.addEventListener('click', () => this.stopObserving());
        this.downloadBtn.addEventListener('click', () => this.downloadFollowers());
    }

    async checkInstagramTab() {
        try {
            const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
            
            if (!tab.url.includes('instagram.com')) {
                this.updateStatus('Navigate to Instagram to use this extension', 'error');
                this.startBtn.disabled = true;
                return;
            }

            this.updateStatus('Ready to collect followers', 'ready');
            this.startBtn.textContent = '🎯 Start Selection Mode';
        } catch (error) {
            this.updateStatus('Error checking tab', 'error');
            console.error('Error checking tab:', error);
        }
    }

    async startSelection() {
        try {
            const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
            
            // Send message to content script to start selection mode
            chrome.tabs.sendMessage(tab.id, { action: 'startSelection' }, (response) => {
                if (chrome.runtime.lastError) {
                    this.updateStatus('Error: Please refresh Instagram page', 'error');
                    return;
                }
                
                if (response && response.success) {
                    this.updateStatus('Look for the widget on Instagram! Click on followers popup.', 'working');
                    this.startBtn.style.display = 'none';
                    this.stopBtn.style.display = 'block';
                    
                    // Close popup so user can interact with the page
                    setTimeout(() => window.close(), 1000);
                }
            });

        } catch (error) {
            this.updateStatus('Error starting selection', 'error');
            console.error('Error starting selection:', error);
        }
    }

    async stopObserving() {
        try {
            const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
            
            chrome.tabs.sendMessage(tab.id, { action: 'stopObserving' }, (response) => {
                this.resetUI();
                this.updateStatus('Observation stopped', 'ready');
            });

        } catch (error) {
            this.resetUI();
            this.updateStatus('Stopped', 'ready');
        }
    }

    startPeriodicUpdate() {
        // Update follower count every 2 seconds
        setInterval(() => {
            this.updateFollowerCount();
        }, 2000);
    }

    async updateFollowerCount() {
        try {
            const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
            
            chrome.tabs.sendMessage(tab.id, { action: 'getFollowers' }, (response) => {
                if (response && typeof response.count === 'number') {
                    this.followers = response.followers || [];
                    this.followersCount.textContent = response.count;
                    this.progressText.textContent = `${response.count} followers collected`;
                    
                    // Update progress bar
                    const progress = Math.min(95, response.count * 0.1);
                    this.progressFill.style.width = `${progress}%`;
                    
                    // Show download button if we have followers
                    if (response.count > 0) {
                        this.downloadBtn.style.display = 'block';
                        this.progressDiv.style.display = 'block';
                        this.statsDiv.style.display = 'block';
                    }
                }
            });

        } catch (error) {
            // Silently handle errors during periodic updates
        }
    }

    async downloadFollowers() {
        try {
            const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
            
            chrome.tabs.sendMessage(tab.id, { action: 'getFollowers' }, (response) => {
                if (response && response.followers && response.followers.length > 0) {
                    this.followers = response.followers;
                    this.performDownload();
                } else {
                    this.updateStatus('No followers to download', 'error');
                }
            });

        } catch (error) {
            this.updateStatus('Error downloading followers', 'error');
        }
    }

    performDownload() {
        if (this.followers.length === 0) {
            this.updateStatus('No followers to download', 'error');
            return;
        }

        const format = document.querySelector('input[name="format"]:checked')?.value || 'csv';
        let content, filename, mimeType;

        if (format === 'json') {
            content = JSON.stringify(this.followers, null, 2);
            filename = `instagram_followers_${new Date().toISOString().split('T')[0]}.json`;
            mimeType = 'application/json';
        } else {
            // CSV format
            const headers = ['Username', 'Display Name', 'Profile URL', 'Profile Pic URL', 'Collected At'];
            const csvContent = [
                headers.join(','),
                ...this.followers.map(f => [
                    `"${f.username}"`,
                    `"${f.displayName || ''}"`,
                    `"${f.profileUrl}"`,
                    `"${f.profilePicUrl || ''}"`,
                    `"${f.timestamp}"`
                ].join(','))
            ].join('\n');
            
            content = csvContent;
            filename = `instagram_followers_${new Date().toISOString().split('T')[0]}.csv`;
            mimeType = 'text/csv';
        }

        try {
            const blob = new Blob([content], { type: mimeType });
            const url = URL.createObjectURL(blob);
            
            chrome.downloads.download({
                url: url,
                filename: filename,
                saveAs: true
            });

            this.updateStatus(`Downloaded ${this.followers.length} followers!`, 'ready');
        } catch (error) {
            this.updateStatus('Download error', 'error');
            console.error('Download error:', error);
        }
    }

    updateStatus(message, type) {
        this.statusDiv.textContent = message;
        this.statusDiv.className = `status ${type}`;
    }

    resetUI() {
        this.isObserving = false;
        this.startBtn.style.display = 'block';
        this.stopBtn.style.display = 'none';
        this.startBtn.textContent = '🎯 Start Selection Mode';
    }
}

// Initialize popup when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new InstagramFollowersPopup();
});