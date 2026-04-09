# KOReader Pangolin Access Bypass

A lightweight Lua patch for [KOReader](https://github.com/koreader/koreader) that enables authentication against **Pangolin** using headers.

This patch allows you to access OPDS catalogs (like Calibre-Web Automated, Audiobookshelf, or Kavita) that are protected behind Pangolin without needing a browser login, VPN client, or complex proxy setups on your e-reader.

## 🚀 How It Works
KOReader natively supports HTTP/HTTPS but does not support the interactive login flows required by Pangolin.

This script uses **"Monkey Patching"** to hook into the core Lua network libraries (`socket.http` and `ssl.https`) inside KOReader. It intercepts every network request made by the device and automatically injects the `P-Access-Token-Id` and `P-Access-Token` headers before the request leaves the device.

## 🛠️ Prerequisites
1.  A device running **KOReader** (Kindle, Kobo, Android, etc.).
2.  A **Pangolin** instance protecting your OPDS server.

## ⚙️ Pangolin Setup
Before installing the patch, you must generate a share link with 2 header key value pairs in Pangolin. This acts as a machine-to-machine credential for your device.

1.  Open your **Pangolin Dashboard**.
2.  Navigate to the **Access Tokens** section.
3.  Click **Create Access Token**.
    * **Name:** `KOReader Device` (or similar).
4.  **Copy the "Token ID" and "Token" immediately.** You will not be able to see the token again.
5.  Configure the appropriate access policy to allow the token to reach your OPDS application.

## 📥 Installation

1.  Download the `2-pangolin-auth.lua` file from this repository.
2.  Open the file in a text editor (Notepad++, VS Code, etc.).
3.  Replace the placeholder credentials with your tokens from Pangolin:
    ```lua
    local P_TOKEN_ID = "put-your-token-id-here"
    local P_TOKEN = "put-your-token-here"
    ```
4.  Connect your KOReader device to your computer via USB.
5.  Navigate to the KOReader directory on the device:
    * **Kindle:** `.adds/koreader/patches/`
    * **Kobo:** `.adds/koreader/patches/`
    * **Android:** `/koreader/patches/`
    * *(Note: If the `patches` folder does not exist, create it).*
6.  Copy your modified `2-pangolin-auth.lua` into that folder.
7.  **Restart KOReader** (Exit and re-open, or full reboot).

## 🔍 Verification & Troubleshooting
This patch integrates with KOReader's internal logging system. If you are having issues:

1.  Open the `crash.log` file in your KOReader directory.
2.  Search for `Pangolin-Auth`.
3.  You should see success messages like:
    ```text
    Pangolin-Auth: Initializing...
    Pangolin-Auth: ✓✓✓ Hooks installed successfully ✓✓✓
    Pangolin-Auth: ✓ Injected headers for URL: [https://your-opds-url.com/opds](https://your-opds-url.com/opds)
    ```

### Common Issues
* **"Unable to Connect":** Check your `P_TOKEN_ID` and `P_TOKEN` for typos. Ensure your Pangolin access policy includes the token.
* **Boot Loop:** If KOReader crashes on boot, delete the file from the `patches` folder via USB.

## ⚠️ Security Warning
Your **Access Token** is stored in plain text on the device.
* If you lose your device, anyone with USB access could potentially copy the token.
* **Mitigation:** If your device is lost or stolen, simply revoke the Access Token in the Pangolin Dashboard. This will immediately cut off access without needing to change your server passwords.

## 📄 License
MIT License. Feel free to use, modify, and distribute.
