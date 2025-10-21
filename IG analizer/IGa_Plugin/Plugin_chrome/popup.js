// popup.js - Dual Mode: Followers & Following Collection
class InstagramAnalyzerPopup {
    constructor() {
        this.followers = [];
        this.following = [];
        this.profileName = '';
        this.initializeElements();
        this.bindEvents();
        this.checkInstagramTab();
        this.startPeriodicUpdate();
    }

    initializeElements() {
        // Profile info
        this.profileNameElement = document.getElementById('profileName');
        
        // Followers section
        this.followersCount = document.getElementById('followersCount');
        this.followersStatus = document.getElementById('followersStatus');
        this.startFollowersBtn = document.getElementById('startFollowersBtn');
        this.downloadFollowersBtn = document.getElementById('downloadFollowersBtn');
        
        // Following section
        this.followingCount = document.getElementById('followingCount');
        this.followingStatus = document.getElementById('followingStatus');
        this.startFollowingBtn = document.getElementById('startFollowingBtn');
        this.downloadFollowingBtn = document.getElementById('downloadFollowingBtn');
    }

    bindEvents() {
        // Action buttons
        this.startFollowersBtn.addEventListener('click', () => this.startCollection('followers'));
        this.startFollowingBtn.addEventListener('click', () => this.startCollection('following'));
        
        // Download buttons
        this.downloadFollowersBtn.addEventListener('click', () => this.downloadData('followers'));
        this.downloadFollowingBtn.addEventListener('click', () => this.downloadData('following'));
    }

    async checkInstagramTab() {
        try {
            const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
            
            if (!tab.url.includes('instagram.com')) {
                this.updateStatus('Naviga su Instagram per usare questa estensione', 'error');
                this.disableAllButtons();
                return;
            }

            // Extract profile name from URL
            this.profileName = this.extractProfileName(tab.url);
            if (this.profileNameElement) {
                this.profileNameElement.textContent = this.profileName || 'Sconosciuto';
            }
            
            // Notify content script of profile name
            chrome.tabs.sendMessage(tab.id, { 
                action: 'setMode', 
                mode: 'followers', // Default mode
                profileName: this.profileName 
            }, (response) => {
                // Ignore errors if content script isn't ready
            });
            
        } catch (error) {
            this.updateStatus('Errore nel controllo della scheda', 'error');
            console.error('Error checking tab:', error);
        }
    }

    extractProfileName(url) {
        try {
            const urlObj = new URL(url);
            const path = urlObj.pathname;
            
            // Remove leading/trailing slashes
            const cleanPath = path.replace(/^\/+|\/+$/g, '');
            
            // If it's a profile URL like /username/
            if (cleanPath && !cleanPath.includes('/') && cleanPath !== '') {
                return cleanPath;
            }
            
            // If it's a full profile URL like /username/followers or /username/following
            const pathParts = cleanPath.split('/');
            if (pathParts.length > 0 && pathParts[0] !== '') {
                return pathParts[0];
            }
            
            return '';
        } catch (error) {
            console.error('Error extracting profile name:', error);
            return '';
        }
    }

    disableAllButtons() {
        this.startFollowersBtn.disabled = true;
        this.startFollowingBtn.disabled = true;
    }

    async startCollection(mode) {
        try {
            const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
            
            // Send message to content script to start selection mode
            chrome.tabs.sendMessage(tab.id, { 
                action: 'startSelection', 
                mode: mode,
                profileName: this.profileName 
            }, (response) => {
                if (chrome.runtime.lastError) {
                    this.updateStatus('Errore: Ricarica la pagina Instagram', 'error', mode);
                    return;
                }
                
                if (response && response.success) {
                    this.updateStatus(`Modalità ${mode === 'followers' ? 'Followers' : 'Following'} attiva! Clicca sul popup di Instagram.`, 'working', mode);
                    
                    // Close popup so user can interact with the page
                    setTimeout(() => window.close(), 1000);
                }
            });

        } catch (error) {
            this.updateStatus('Errore nell\'avvio della raccolta', 'error', mode);
            console.error('Error starting collection:', error);
        }
    }

    startPeriodicUpdate() {
        // Update counts every 2 seconds
        setInterval(() => {
            this.updateCounts();
        }, 2000);
    }

    async updateCounts() {
        try {
            const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
            
            // Get current data from content script
            chrome.tabs.sendMessage(tab.id, { action: 'getData' }, (response) => {
                if (response) {
                    if (response.mode === 'followers') {
                        this.followersCount.textContent = response.count || 0;
                        this.followers = response.data || [];
                        if (response.count > 0) {
                            this.downloadFollowersBtn.style.display = 'block';
                        }
                    } else if (response.mode === 'following') {
                        this.followingCount.textContent = response.count || 0;
                        this.following = response.data || [];
                        if (response.count > 0) {
                            this.downloadFollowingBtn.style.display = 'block';
                        }
                    }
                }
            });

        } catch (error) {
            // Silently handle errors during periodic updates
        }
    }

    async downloadData(mode) {
        try {
            const data = mode === 'followers' ? this.followers : this.following;
            
            if (data.length === 0) {
                this.updateStatus(`Nessun ${mode} da scaricare`, 'error', mode);
                return;
            }
            
            this.performDownload(data, mode);

        } catch (error) {
            this.updateStatus(`Errore nel download dei ${mode}`, 'error', mode);
        }
    }

    performDownload(data, mode) {
        if (data.length === 0) {
            this.updateStatus(`Nessun ${mode} da scaricare`, 'error', mode);
            return;
        }

        // Create filename with profile name
        const profilePart = this.profileName ? `${this.profileName}_` : '';
        const filename = `${profilePart}${mode}_data.csv`;

        // Convert data to CSV format
        const headers = ['Username', 'Display Name', 'Profile URL', 'Profile Pic URL', 'Collected At'];
        const csvContent = [
            headers.join(','),
            ...data.map(([username, userData]) => [
                `"${userData.username}"`,
                `"${userData.displayName || ''}"`,
                `"${userData.profileUrl}"`,
                `"${userData.profilePicUrl || ''}"`,
                `"${userData.timestamp || userData.collectedAt || ''}"`
            ].join(','))
        ].join('\n');

        try {
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const url = URL.createObjectURL(blob);
            
            chrome.downloads.download({
                url: url,
                filename: filename,
                saveAs: true
            });

            this.updateStatus(`Scaricato ${data.length} ${mode}!`, 'ready', mode);
        } catch (error) {
            this.updateStatus('Errore nel download', 'error', mode);
            console.error('Download error:', error);
        }
    }

    updateStatus(message, type, mode = null) {
        const targetMode = mode || 'followers'; // Default to followers if no mode specified
        const statusElement = targetMode === 'followers' ? this.followersStatus : this.followingStatus;
        
        if (statusElement) {
            statusElement.textContent = message;
            // You could add color coding here based on type
        }
    }
}

// Initialize popup when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new InstagramAnalyzerPopup();
});