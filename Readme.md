# IG Follower Analyzer

This project helps you analyze your Instagram followers and following lists using a web-based app and a Chrome plugin. It is not a complete or fully automated solution: you need to manually select what to analyze and scroll the lists yourself. The tool is designed for personal use, is semi-automatic, and does not require any Instagram login or credentials.

---

## How It Works

### 1. Install the Chrome Plugin

1. Open Chrome and go to `chrome://extensions/`.
2. Enable Developer Mode (top right).
3. Click "Load unpacked" and select the folder `chrome-extension`.

### 2. Collect Data from Instagram

1. Go to [instagram.com](https://instagram.com) and log in to your profile (as you normally would, no credentials are handled by this tool).
2. Click the plugin icon to open the popup.
3. Choose whether to collect followers or following.
4. Follow the popup instructions:
   - Press the button to start collecting.
   - Use the **Auto-Scroll** feature to automatically scroll through the list, or scroll manually.
   - The plugin collects usernames as they become visible.
   - When finished, press the download button to export the data as CSV.

### 3. Analyze Data with the Web App

1. Open `web-version/index.html` in your browser (or run a local server).
2. Choose between:
   - **Analysis**: Upload followers and following CSV/HTML files to see who doesn't follow you back and mutual connections.
   - **Compare**: Compare old and new follower lists to see who you've gained/lost.
3. Drag and drop CSV files exported from the plugin into the web app.
4. View analysis results with charts and detailed user lists.

---

## Privacy & Security

- The web app is fully client-side: no data is sent to any server.
- The process is semi-automatic: you must manually select and scroll the Instagram lists to export data or use the autoscroll feature (selecting the following/followers popup as a target to scroll).
- No Instagram credentials are ever requested or stored.
- The tool only reads data visible on your screen, just like a human would.
- No data is sent anywhere: everything stays on your computer.
- There is no tracking, analytics, or personal data collection of any kind.
- Analysis history is stored locally in your browser (localStorage).
- Because it is not a fully automated scraper and does not bypass Instagram's normal interface, it should not violate Instagram's Terms of Service (use at your own risk).

## Requirements

- Google Chrome for the plugin
- Any modern web browser (Chrome, Firefox, Safari, Edge) for the web app

---

## Support
For questions or issues, open a GitHub issue.
