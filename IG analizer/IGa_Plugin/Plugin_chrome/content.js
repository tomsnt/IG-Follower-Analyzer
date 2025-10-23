// Instagram Followers Scraper - Manual Selection Mode
// User manually selects the followers popup, then auto-collects

class InstagramFollowersSelector {
    constructor() {
        this.followers = new Map();
        this.following = new Map();
        this.mode = null; // 'followers' or 'following'
        this.isSelectionMode = false;
        this.isObserving = false;
        this.paused = false;
        this.selectedContainer = null;
        this.mutationObserver = null;
        this.counterWidget = null;
        this.profileName = this.extractProfileNameFromURL();
        console.log('🎯 Instagram Analyzer initialized');
        this.init();
    }

    init() {
        this.widgetVisible = false; // Imposta il widget inizialmente nascosto
        const widget = document.getElementById('instagram-analyzer-widget');
        if (widget) {
            widget.style.display = 'none';
        }
        // Create floating counter widget
        this.createCounterWidget();
        
        // Listen for messages from popup/background
        chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
            if (request.action === 'startSelection') {
                this.startSelectionMode();
                sendResponse({ success: true });
            } else if (request.action === 'stopObserving') {
                this.stopObserving();
                sendResponse({ success: true });
            } else if (request.action === 'getFollowers') {
                sendResponse({
                    followers: Array.from(this.followers.values()),
                    count: this.followers.size
                });
            } else if (request.action === 'clearData') {
                this.followers.clear();
                this.updateCounter();
                sendResponse({ success: true });
            }
        });
        this.createToggleButton();
    }

    createToggleButton() {
        this.toggleBtn = document.createElement('div');
        this.toggleBtn.id = 'ig-analyzer-toggle-btn';
        this.toggleBtn.style.position = 'fixed';
        this.toggleBtn.style.top = '18px';
        this.toggleBtn.style.right = '18px';
        this.toggleBtn.style.zIndex = '1000000';
        this.toggleBtn.style.width = '48px';
        this.toggleBtn.style.height = '48px';
        this.toggleBtn.style.cursor = 'pointer';
        this.toggleBtn.style.background = 'rgba(255,255,255,0.0)';
        this.toggleBtn.style.display = 'flex';
        this.toggleBtn.style.alignItems = 'center';
        this.toggleBtn.style.justifyContent = 'center';
        const iconUrl = chrome.runtime.getURL('Plugin_chrome/icons/IGa_icons-wnobg.png');
        this.toggleBtn.innerHTML = `<img src="${iconUrl}" alt="Toggle" style="width:40px;height:40px;">`;
        document.body.appendChild(this.toggleBtn);

        this.toggleBtn.onclick = () => {
            this.widgetVisible = !this.widgetVisible;
            const widget = document.getElementById('instagram-analyzer-widget');
            if (widget) {
                widget.style.display = this.widgetVisible ? 'block' : 'none';
            } else {
                console.error('Widget not found');
            }
        };
    }

    createCounterWidget() {
        this.counterWidget = document.createElement('div');
        this.counterWidget.id = 'instagram-analyzer-widget';
        this.counterWidget.innerHTML = `
            <div style="position: fixed; top: 24px; right: 24px; background: transparent; color: #fff; border-radius: 24px; box-shadow: 0 4px 24px rgba(0,0,0,0.18); z-index: 999999; padding: 0; min-width: 420px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; pointer-events: auto;">
                <div style="display: flex; gap: 32px; justify-content: center; padding: 24px 24px 24px 24px;">
                    <div id="followers-panel" style="background: #5a5a5a; border-radius: 32px; width: 150px; max-width: 150px; max-height: 160px; padding: 0 0 0px 0; display: flex; flex-direction: column; align-items: center;">
                        <div style="color: #fff; font-size: 14px; font-weight: 500; padding: 12px 0 0 0; text-align: center; border-top-left-radius: 32px; border-top-right-radius: 32px;">Followers</div>
                        <div style="background: #ededed; border-radius: 24px; margin-top: 8px; width: 90%; display: flex; flex-direction: column; align-items: center; padding: 12px 0 0 0;">
                            <div id="followers-count" style="font-size: 14px; font-weight: 600; color: #111; margin-bottom: 8px;">0</div>
                            <div id="followers-actions" style="display: flex; gap: 10px; justify-content: center; align-items: center;"></div>
                        </div>
                    </div>
                    <div id="following-panel" style="background: #5a5a5a; border-radius: 32px; width: 150px; max-width: 150px; max-height: 160px; padding: 0 0 0px 0; display: flex; flex-direction: column; align-items: center;">
                        <div style="color: #fff; font-size: 14px; font-weight: 500; padding: 12px 0 0 0; text-align: center; border-top-left-radius: 32px; border-top-right-radius: 32px;">Following</div>
                        <div style="background: #ededed; border-radius: 24px; margin-top: 8px; width: 90%; display: flex; flex-direction: column; align-items: center; padding: 12px 0 0 0;">
                            <div id="following-count" style="font-size: 14px; font-weight: 600; color: #111; margin-bottom: 8px;">0</div>
                            <div id="following-actions" style="display: flex; gap: 10px; justify-content: center; align-items: center;"></div>
                        </div>
                    </div>
                </div>
            </div>
        `;
        document.body.appendChild(this.counterWidget);
        this.renderActions();
    }

    updateCounter() {
        const followersCount = document.getElementById('followers-count');
        const followingCount = document.getElementById('following-count');
        if (followersCount) followersCount.textContent = this.followers.size;
        if (followingCount) followingCount.textContent = this.following.size;
        this.renderActions();
    }

    renderActions() {
        // Followers panel
        const followersActions = this.counterWidget.querySelector('#followers-actions');
        followersActions.innerHTML = '';
        if (!this.isObserving || this.mode !== 'followers') {
            followersActions.innerHTML = `<button id="analyze-followers-btn" style="background: linear-gradient(180deg, #D53D85 0%, #4E2FD1 100%); color: #fff; font-size: 14px; font-weight: 500; border: none; border-radius: 18px; padding: 6px 16px; min-width: 80px; margin-bottom: 8px; cursor: pointer;">Analizza</button>`;
        } else {
            const icon = this.paused
                ? `<svg width="28" height="28" viewBox="0 0 32 32"><circle cx="16" cy="16" r="14" fill="#d44a6a"/><polygon points="12,10 24,16 12,22" fill="#fff"/></svg>`
                : `<svg width="28" height="28" viewBox="0 0 32 32"><circle cx="16" cy="16" r="14" fill="#d44a6a"/><rect x="10" y="10" width="4" height="12" rx="2" fill="#fff"/><rect x="18" y="10" width="4" height="12" rx="2" fill="#fff"/></svg>`;
            const exportIcon = `<svg width="28" height="28" viewBox="0 0 32 32"><circle cx="16" cy="16" r="14" fill="#888"/><path d="M16 10v10M16 20l-5-5M16 20l5-5" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>`;
            const resetIcon = `<span style='font-size:22px;display:inline-block;vertical-align:middle;color:#111;'>&#x21BB;</span>`;
            followersActions.innerHTML = `
                <button id="pause-play-followers-btn" style="background: none; border: none; padding: 0 2px; margin-right: 8px; cursor: pointer;">${icon}</button>
                <button id="reset-followers-btn" style="background: none; border: none; padding: 0 2px; margin-right: 8px; cursor: pointer;">${resetIcon}</button>
                <button id="export-followers-btn" style="background: none; border: none; padding: 0 2px; cursor: pointer;">${exportIcon}</button>
            `;
        }
        // Following panel
        const followingActions = this.counterWidget.querySelector('#following-actions');
        followingActions.innerHTML = '';
        if (!this.isObserving || this.mode !== 'following') {
            followingActions.innerHTML = `<button id="analyze-following-btn" style="background: linear-gradient(180deg, #D53D85 0%, #4E2FD1 100%); color: #fff; font-size: 14px; font-weight: 500; border: none; border-radius: 18px; padding: 6px 16px; min-width: 80px; margin-bottom: 8px; cursor: pointer;">Analizza</button>`;
        } else {
            const icon = this.paused
                ? `<svg width="28" height="28" viewBox="0 0 32 32"><circle cx="16" cy="16" r="14" fill="#4f7ae9"/><polygon points="12,10 24,16 12,22" fill="#fff"/></svg>`
                : `<svg width="28" height="28" viewBox="0 0 32 32"><circle cx="16" cy="16" r="14" fill="#4f7ae9"/><rect x="10" y="10" width="4" height="12" rx="2" fill="#fff"/><rect x="18" y="10" width="4" height="12" rx="2" fill="#fff"/></svg>`;
            const exportIcon = `<svg width="28" height="28" viewBox="0 0 32 32"><circle cx="16" cy="16" r="14" fill="#888"/><path d="M16 10v10M16 20l-5-5M16 20l5-5" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>`;
            const resetIcon = `<span style='font-size:22px;display:inline-block;vertical-align:middle;color:#111;'>&#x21BB;</span>`;
            followingActions.innerHTML = `
                <button id="pause-play-following-btn" style="background: none; border: none; padding: 0 2px; margin-right: 8px; cursor: pointer;">${icon}</button>
                <button id="reset-following-btn" style="background: none; border: none; padding: 0 2px; margin-right: 8px; cursor: pointer;">${resetIcon}</button>
                <button id="export-following-btn" style="background: none; border: none; padding: 0 2px; cursor: pointer;">${exportIcon}</button>
            `;
        }
        // Add reset event listeners
        const resetFollowersBtn = this.counterWidget.querySelector('#reset-followers-btn');
        if (resetFollowersBtn) {
            resetFollowersBtn.onclick = () => {
                this.followers.clear();
                this.isObserving = false;
                this.paused = false;
                this.mode = null;
                this.updateCounter();
            };
        }
        const resetFollowingBtn = this.counterWidget.querySelector('#reset-following-btn');
        if (resetFollowingBtn) {
            resetFollowingBtn.onclick = () => {
                this.following.clear();
                this.isObserving = false;
                this.paused = false;
                this.mode = null;
                this.updateCounter();
            };
        }
        // Add event listeners
        const analyzeFollowersBtn = this.counterWidget.querySelector('#analyze-followers-btn');
        if (analyzeFollowersBtn) {
            analyzeFollowersBtn.onclick = () => {
                this.mode = 'followers';
                this.startSelectionMode();
            };
        }
        const analyzeFollowingBtn = this.counterWidget.querySelector('#analyze-following-btn');
        if (analyzeFollowingBtn) {
            analyzeFollowingBtn.onclick = () => {
                this.mode = 'following';
                this.startSelectionMode();
            };
        }
        const pausePlayFollowersBtn = this.counterWidget.querySelector('#pause-play-followers-btn');
        if (pausePlayFollowersBtn) {
            pausePlayFollowersBtn.onclick = () => {
                if (this.paused) {
                    // resume
                    this.paused = false;
                    this.startObserving();
                } else {
                    // pause
                    this.paused = true;
                    if (this.mutationObserver) {
                        this.mutationObserver.disconnect();
                    }
                }
                this.updateCounter();
            };
        }
        const pausePlayFollowingBtn = this.counterWidget.querySelector('#pause-play-following-btn');
        if (pausePlayFollowingBtn) {
            pausePlayFollowingBtn.onclick = () => {
                if (this.paused) {
                    // resume
                    this.paused = false;
                    this.startObserving();
                } else {
                    // pause
                    this.paused = true;
                    if (this.mutationObserver) {
                        this.mutationObserver.disconnect();
                    }
                }
                this.updateCounter();
            };
        }
        const exportFollowersBtn = this.counterWidget.querySelector('#export-followers-btn');
        if (exportFollowersBtn) {
            exportFollowersBtn.onclick = () => {
                this.exportData('followers');
            };
        }
        const exportFollowingBtn = this.counterWidget.querySelector('#export-following-btn');
        if (exportFollowingBtn) {
            exportFollowingBtn.onclick = () => {
                this.exportData('following');
            };
        }
    }

    startSelectionMode() {
        this.isSelectionMode = true;
        this.updateCounter();
        document.body.style.cursor = 'crosshair';
        this.createSelectionOverlay();
        if (this.mode === 'following') {
            console.log('🎯 Selection mode activated - click on the following popup');
        } else {
            console.log('🎯 Selection mode activated - click on the followers popup');
        }
    }

    createSelectionOverlay() {
        const hoverStyle = document.createElement('style');
        hoverStyle.id = 'selection-hover-style';
        hoverStyle.textContent = `
            .selection-highlight {
                outline: 3px solid #ff4444 !important;
                outline-offset: 2px !important;
                background: rgba(255, 68, 68, 0.1) !important;
            }
        `;
        document.head.appendChild(hoverStyle);
        this.selectionClickHandler = (e) => {
            e.preventDefault();
            e.stopPropagation();
            this.selectElement(e.target);
        };
        this.selectionHoverHandler = (e) => {
            document.querySelectorAll('.selection-highlight').forEach(el => {
                el.classList.remove('selection-highlight');
            });
            e.target.classList.add('selection-highlight');
        };
        document.addEventListener('click', this.selectionClickHandler, true);
        document.addEventListener('mouseover', this.selectionHoverHandler, true);
    }

    selectElement(element) {
        // Stop selection mode
        this.isSelectionMode = false;
        document.body.style.cursor = '';
        // Remove selection overlay
        document.removeEventListener('click', this.selectionClickHandler, true);
        document.removeEventListener('mouseover', this.selectionHoverHandler, true);
        const style = document.getElementById('selection-hover-style');
        if (style) style.remove();
        document.querySelectorAll('.selection-highlight').forEach(el => {
            el.classList.remove('selection-highlight');
        });
        // Find the scrollable container (go up the DOM tree)
        this.selectedContainer = this.findScrollableContainer(element);
        if (this.selectedContainer) {
            console.log('✅ Selected container:', this.selectedContainer);
            this.startObserving();
        } else {
            console.warn('❌ Could not find scrollable container');
            alert('Could not find a scrollable container. Please try selecting a different element.');
        }
    }

    findScrollableContainer(element) {
        let current = element;
        let depth = 0;
        
        while (current && depth < 10) {
            const style = window.getComputedStyle(current);
            const overflowY = style.overflowY;
            const overflowX = style.overflowX;
            
            // Check if element is scrollable
            if ((overflowY === 'auto' || overflowY === 'scroll' || 
                 overflowX === 'auto' || overflowX === 'scroll') &&
                current.scrollHeight > current.clientHeight) {
                return current;
            }
            
            // Also check for common Instagram dialog patterns
            if (current.querySelector && (
                current.querySelector('[role="dialog"]') ||
                current.querySelector('div[style*="overflow"]') ||
                current.classList.toString().includes('dialog')
            )) {
                return current;
            }
            
            current = current.parentElement;
            depth++;
        }
        
        // Fallback: return the element if we can't find a scrollable parent
        return element;
    }

    startObserving() {
        if (!this.selectedContainer) return;
        
        if (this.mutationObserver) {
            this.mutationObserver.disconnect();
        }
        
        this.isObserving = true;
        this.paused = false;
        this.updateCounter();
        
        console.log('👀 Starting to observe followers in selected container');
        
        // Initial scan
        this.scanForFollowers();
        
        // Set up mutation observer
        this.mutationObserver = new MutationObserver((mutations) => {
            let shouldScan = false;
            
            mutations.forEach((mutation) => {
                if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                    shouldScan = true;
                }
            });
            
            if (shouldScan) {
                // Debounce scanning
                clearTimeout(this.scanTimeout);
                this.scanTimeout = setTimeout(() => {
                    this.scanForFollowers();
                }, 300);
            }
        });
        
        this.mutationObserver.observe(this.selectedContainer, {
            childList: true,
            subtree: true
        });
    }

    scanForFollowers() {
        if (!this.selectedContainer) return;
        
        const profileLinks = this.selectedContainer.querySelectorAll('a[href^="/"]');
        
        profileLinks.forEach(link => {
            const href = link.getAttribute('href');
            
            if (!href || href === '/' || 
                href.includes('/p/') || href.includes('/reel/') || 
                href.includes('/explore/') || href.includes('/stories/')) {
                return;
            }
            
            const username = href.replace(/^\//, '').replace(/\/$/, '');
            if (!username || username.length < 1) return;
            
            if (this.mode === 'followers') {
                if (this.followers.has(username)) return;
                const data = this.extractFollowerData(link, username);
                if (data) {
                    this.followers.set(username, data);
                    this.updateCounter();
                    console.log(`👤 New follower: ${username}`);
                }
            } else if (this.mode === 'following') {
                if (this.following.has(username)) return;
                const data = this.extractFollowerData(link, username);
                if (data) {
                    this.following.set(username, data);
                    this.updateCounter();
                    console.log(`👤 New following: ${username}`);
                }
            }
        });
    }

    extractFollowerData(linkElement, username) {
        try {
            // Find the container that holds profile info
            const container = linkElement.closest('div');
            if (!container) return null;
            
            // Try to find display name
            let displayName = '';
            const textElements = container.querySelectorAll('span, div');
            for (const el of textElements) {
                const text = el.textContent.trim();
                if (text && text !== username && !text.includes('•') && 
                    !text.includes('Follow') && text.length > 0 && text.length < 100) {
                    displayName = text;
                    break;
                }
            }
            
            // Try to find profile picture
            let profilePic = '';
            const img = container.querySelector('img');
            if (img && img.src) {
                profilePic = img.src;
            }
            
            return {
                username: username,
                displayName: displayName,
                profileUrl: `https://www.instagram.com/${username}/`,
                profilePicUrl: profilePic,
                timestamp: new Date().toISOString()
            };
        } catch (error) {
            console.warn('Error extracting follower data:', error);
            return null;
        }
    }

    stopObserving() {
        this.isObserving = false;
        this.isSelectionMode = false;
        this.paused = false;
        if (this.mutationObserver) {
            this.mutationObserver.disconnect();
            this.mutationObserver = null;
        }
        this.updateCounter();
        setTimeout(() => this.updateCounter(), 100); // Ensure UI updates after DOM changes
        console.log(`🏁 Stopped observing. Total followers: ${this.followers.size}`);
    }

    exportData(type) {
        const dataMap = type === 'followers' ? this.followers : this.following;
        if (dataMap.size === 0) {
            alert(`No ${type} collected yet!`);
            return;
        }
        const dateStr = new Date().toISOString().split('T')[0];
        const filename = `${this.profileName}_${type}_${dateStr}.csv`;
        const csvHeader = 'Username,Display Name,Profile URL,Profile Pic URL,Collected At\n';
        const csvContent = Array.from(dataMap.values())
            .map(f => `"${f.username}","${f.displayName}","${f.profileUrl}","${f.profilePicUrl}","${f.timestamp}"`)
            .join('\n');
        const csvData = csvHeader + csvContent;
        const blob = new Blob([csvData], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = filename;
        link.click();
        console.log(`📥 Exported ${dataMap.size} ${type} to ${filename}`);
    }
    extractProfileNameFromURL() {
        try {
            const currentUrl = window.location.href;
            if (currentUrl.includes('instagram.com')) {
                const urlObj = new URL(currentUrl);
                const path = urlObj.pathname.replace(/^\/+|\/+$/g, '');
                const pathParts = path.split('/');
                if (pathParts.length > 0 && pathParts[0] !== '') {
                    return pathParts[0];
                }
            }
        } catch (error) {
            return 'Nome.Profilo';
        }
        return 'Nome.Profilo';
    }
}

// Initialize when page loads
if (window.location.hostname === 'www.instagram.com') {
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            new InstagramFollowersSelector();
        });
    } else {
        new InstagramFollowersSelector();
    }
}