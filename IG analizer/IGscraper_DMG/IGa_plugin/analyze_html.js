// HTML Analyzer - Extract followers from saved Instagram HTML
// Run this in browser console or as a standalone script

function analyzeInstagramHTML() {
    console.log('🔍 Analyzing Instagram followers HTML...');
    
    const followers = new Map();
    
    // Find all profile links in the document
    const profileLinks = document.querySelectorAll('a[href^="/"]');
    
    profileLinks.forEach(link => {
        const href = link.getAttribute('href');
        
        // Skip non-profile links
        if (!href || href === '/' || 
            href.includes('/p/') || href.includes('/reel/') || 
            href.includes('/explore/') || href.includes('/stories/') ||
            href.includes('/reels/') || href.includes('/tagged/')) {
            return;
        }
        
        // Extract username from href
        const username = href.replace(/^\//, '').replace(/\/$/, '');
        if (!username || username.length < 1 || username.includes('/')) return;
        
        // Skip if already processed
        if (followers.has(username)) return;
        
        // Extract additional data from the link's container
        const container = link.closest('div') || link.parentElement;
        if (!container) return;
        
        // Try to find display name
        let displayName = '';
        const textElements = container.querySelectorAll('span, div');
        for (const el of textElements) {
            const text = el.textContent.trim();
            if (text && text !== username && !text.includes('•') && 
                !text.includes('Follow') && !text.includes('Remove') && 
                text.length > 0 && text.length < 100 &&
                !text.includes('followers') && !text.includes('following')) {
                displayName = text;
                break;
            }
        }
        
        // Try to find profile picture
        let profilePic = '';
        const img = container.querySelector('img[alt*="profile picture"]') || 
                   container.querySelector('img[src*="cdninstagram"]');
        if (img && img.src) {
            profilePic = img.src;
        }
        
        // Check if has Follow button (means user doesn't follow back)
        const followButton = container.querySelector('button') || 
                           container.parentElement?.querySelector('button');
        const isFollowingBack = !followButton || !followButton.textContent.includes('Follow');
        
        const followerData = {
            username: username,
            displayName: displayName,
            profileUrl: `https://www.instagram.com/${username}/`,
            profilePicUrl: profilePic,
            isFollowingBack: isFollowingBack,
            timestamp: new Date().toISOString()
        };
        
        followers.set(username, followerData);
    });
    
    const followersList = Array.from(followers.values());
    
    console.log(`✅ Found ${followersList.length} followers`);
    console.log('📊 Followers data:', followersList);
    
    // Auto-download CSV
    downloadFollowersCSV(followersList);
    
    return followersList;
}

function downloadFollowersCSV(followers) {
    if (followers.length === 0) {
        console.warn('No followers to export');
        return;
    }
    
    // Create CSV content
    const csvHeader = 'Username,Display Name,Profile URL,Profile Pic URL,Is Following Back,Collected At\n';
    const csvContent = followers
        .map(f => `"${f.username}","${f.displayName}","${f.profileUrl}","${f.profilePicUrl}","${f.isFollowingBack}","${f.timestamp}"`)
        .join('\n');
    
    const csvData = csvHeader + csvContent;
    
    // Download CSV
    const blob = new Blob([csvData], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `instagram_followers_${new Date().toISOString().split('T')[0]}.csv`;
    link.click();
    
    console.log(`📥 Downloaded ${followers.length} followers as CSV`);
}

// Auto-run if in browser
if (typeof window !== 'undefined' && window.location) {
    // Add a button to the page for easy access
    const analyzeButton = document.createElement('button');
    analyzeButton.textContent = '📊 Analyze Followers';
    analyzeButton.style.cssText = `
        position: fixed;
        top: 10px;
        right: 10px;
        z-index: 999999;
        background: #e1306c;
        color: white;
        border: none;
        padding: 10px 15px;
        border-radius: 8px;
        font-weight: bold;
        cursor: pointer;
        box-shadow: 0 2px 10px rgba(0,0,0,0.3);
    `;
    
    analyzeButton.addEventListener('click', () => {
        analyzeInstagramHTML();
    });
    
    document.body.appendChild(analyzeButton);
    
    console.log('✅ HTML Analyzer loaded! Click the button or run analyzeInstagramHTML() in console');
}

// Export for use in other contexts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { analyzeInstagramHTML, downloadFollowersCSV };
}