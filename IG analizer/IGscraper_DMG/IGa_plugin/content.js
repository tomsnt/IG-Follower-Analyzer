// Instagram Followers Scraper - Manual Selection Mode
// User manually selects the followers popup, then auto-collects

class InstagramFollowersSelector {
    constructor() {
        this.followers = new Map();
        this.isSelectionMode = false;
        this.isObserving = false;
        this.selectedContainer = null;
        this.mutationObserver = null;
        this.counterWidget = null;
        
        console.log('🎯 Instagram Followers Selector initialized');
        this.init();
    }

    init() {
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
    }

    createCounterWidget() {
        // Create floating widget in top-right corner
        this.counterWidget = document.createElement('div');
        this.counterWidget.id = 'instagram-followers-widget';
        this.counterWidget.innerHTML = `
            <div style="
                position: fixed;
                top: 20px;
                right: 20px;
                background: linear-gradient(45deg, #405de6, #5851db, #833ab4, #c13584, #e1306c, #fd1d1d);
                color: white;
                padding: 12px 16px;
                border-radius: 12px;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                font-size: 14px;
                font-weight: 600;
                box-shadow: 0 4px 12px rgba(0,0,0,0.3);
                z-index: 999999;
                cursor: pointer;
                user-select: none;
                transition: transform 0.2s ease;
                min-width: 200px;
                text-align: center;
            " onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">
                <div id="widget-status">🎯 Click to Select Popup</div>
                <div id="widget-counter" style="font-size: 18px; margin-top: 4px;">Followers: 0</div>
                <div id="widget-buttons" style="margin-top: 8px; display: none;">
                    <button id="export-btn" style="
                        background: rgba(255,255,255,0.2);
                        border: 1px solid rgba(255,255,255,0.3);
                        color: white;
                        padding: 6px 12px;
                        border-radius: 6px;
                        font-size: 12px;
                        cursor: pointer;
                        margin-right: 8px;
                    ">📥 Export CSV</button>
                    <button id="stop-btn" style="
                        background: rgba(255,255,255,0.2);
                        border: 1px solid rgba(255,255,255,0.3);
                        color: white;
                        padding: 6px 12px;
                        border-radius: 6px;
                        font-size: 12px;
                        cursor: pointer;
                    ">⏹️ Stop</button>
                </div>
            </div>
        `;
        
        document.body.appendChild(this.counterWidget);
        
        // Add event listeners
        this.counterWidget.addEventListener('click', () => {
            if (this.isSelectionMode) {
                this.startSelectionMode();
            } else if (!this.isObserving) {
                this.startSelectionMode();
            }
        });
        
        // Export button
        document.addEventListener('click', (e) => {
            if (e.target.id === 'export-btn') {
                this.exportFollowers();
            } else if (e.target.id === 'stop-btn') {
                this.stopObserving();
            }
        });
    }

    updateCounter() {
        const counter = document.getElementById('widget-counter');
        const status = document.getElementById('widget-status');
        const buttons = document.getElementById('widget-buttons');
        
        if (counter) counter.textContent = `Followers: ${this.followers.size}`;
        
        if (this.isSelectionMode) {
            if (status) status.textContent = '👆 Click on Followers Popup';
        } else if (this.isObserving) {
            if (status) status.textContent = '👀 Observing... Scroll to collect!';
            if (buttons) buttons.style.display = 'block';
        } else {
            if (status) status.textContent = '🎯 Click to Select Popup';
            if (buttons) buttons.style.display = 'none';
        }
    }

    startSelectionMode() {
        this.isSelectionMode = true;
        this.updateCounter();
        
        // Add visual indicator for selection
        document.body.style.cursor = 'crosshair';
        
        // Create overlay to show hoverable elements
        this.createSelectionOverlay();
        
        console.log('🎯 Selection mode activated - click on the followers popup');
    }

    createSelectionOverlay() {
        // Add hover effects to potential containers
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
        
        // Add click listener to document
        this.selectionClickHandler = (e) => {
            e.preventDefault();
            e.stopPropagation();
            this.selectElement(e.target);
        };
        
        this.selectionHoverHandler = (e) => {
            // Remove previous highlights
            document.querySelectorAll('.selection-highlight').forEach(el => {
                el.classList.remove('selection-highlight');
            });
            
            // Add highlight to current element
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
        if (this.isObserving || !this.selectedContainer) return;
        
        this.isObserving = true;
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
        
        // Find all links that look like profile links
        const profileLinks = this.selectedContainer.querySelectorAll('a[href^="/"]');
        
        profileLinks.forEach(link => {
            const href = link.getAttribute('href');
            
            // Skip non-profile links
            if (!href || href === '/' || 
                href.includes('/p/') || href.includes('/reel/') || 
                href.includes('/explore/') || href.includes('/stories/')) {
                return;
            }
            
            // Extract username from href
            const username = href.replace(/^\//, '').replace(/\/$/, '');
            if (!username || username.length < 1) return;
            
            // Check if we already have this follower
            if (this.followers.has(username)) return;
            
            // Extract additional data
            const followerData = this.extractFollowerData(link, username);
            
            if (followerData) {
                this.followers.set(username, followerData);
                this.updateCounter();
                console.log(`👤 New follower: ${username}`);
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
        
        if (this.mutationObserver) {
            this.mutationObserver.disconnect();
            this.mutationObserver = null;
        }
        
        this.updateCounter();
        console.log(`🏁 Stopped observing. Total followers: ${this.followers.size}`);
    }

    exportFollowers() {
        if (this.followers.size === 0) {
            alert('No followers collected yet!');
            return;
        }
        
        // Create CSV content
        const csvHeader = 'Username,Display Name,Profile URL,Profile Pic URL,Collected At\n';
        const csvContent = Array.from(this.followers.values())
            .map(f => `"${f.username}","${f.displayName}","${f.profileUrl}","${f.profilePicUrl}","${f.timestamp}"`)
            .join('\n');
        
        const csvData = csvHeader + csvContent;
        
        // Download CSV
        const blob = new Blob([csvData], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `instagram_followers_${new Date().toISOString().split('T')[0]}.csv`;
        link.click();
        
        console.log(`📥 Exported ${this.followers.size} followers to CSV`);
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