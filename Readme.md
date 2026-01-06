# IG Follower Analyzer

This project helps you analyze your Instagram followers and following lists using a simple desktop app (macOS, Xcode only) and a Chrome plugin. It is not a complete or fully automated solution: you need to manually select what to analyze and scroll the lists yourself. The tool is designed for personal use, is semi-automatic, and does not require any Instagram login or credentials.

---

## How It Works

### 1. Install the Chrome Plugin

1. Open Chrome and go to `chrome://extensions/`.
2. Enable Developer Mode (top right).
3. Click "Load unpacked" and select the folder `IG analizer/IGa_Plugin/Plugin_chrome`.

### 2. Collect Data from Instagram

1. Go to [instagram.com](https://instagram.com) and log in to your profile (as you normally would, no credentials are handled by this tool).
2. Click the plugin icon to open the popup.
3. Choose whether to collect followers or following.
4. Follow the popup instructions:
   - Press the button to start collecting.
   - Manually scroll the list to the bottom (the plugin only reads what is visible as you scroll).
   - When finished, press the download button to export the data as CSV.

### 3. Analyze Data with the App

1. Open the IG Follower Analyzer app on macOS via Xcode.
2. Drag and drop the CSV files exported from the plugin into the app.
3. You can view basic analysis and comparisons, such as who doesn't follow you back or who you have unfollowed. Features are limited and the process is not fully automatic.

---

## Important Notes
- The app currently only works if run from Xcode (no installer provided).
- The process is semi-automatic: you must manually select and scroll the lists.
- No Instagram credentials are ever requested or stored.
- The tool only reads data visible on your screen, just like a human would.
- No data is sent anywhere: everything stays on your computer.
- There is no tracking, analytics, or personal data collection of any kind.
- Because it is not a fully automated scraper and does not bypass Instagram's normal interface, it should not violate Instagram's Terms of Service (use at your own risk).

---

## Requirements
- macOS for the desktop app (Xcode required to run)
- Google Chrome for the plugin

---

## Support
For questions or issues, open a GitHub issue.
