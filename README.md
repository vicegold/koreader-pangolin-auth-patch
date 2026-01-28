# KOReader Cloudflare Access Bypass

A lightweight Lua patch for [KOReader](https://github.com/koreader/koreader) that enables authentication against **Cloudflare Access (Zero Trust)** using Service Tokens.

This patch allows you to access OPDS catalogs (like Calibre-Web Automated, Audiobookshelf, or Kavita) that are protected behind Cloudflare Access without needing a browser login, VPN client, or complex proxy setups on your e-reader.

## 🚀 How It Works
KOReader natively supports HTTP/HTTPS but does not support the interactive OAuth login flows (Google/GitHub) required by Cloudflare Access.

This script uses **"Monkey Patching"** to hook into the core Lua network libraries (`socket.http` and `ssl.https`) inside KOReader. It intercepts every network request made by the device and automatically injects the `CF-Access-Client-Id` and `CF-Access-Client-Secret` headers before the request leaves the device.

## 🛠️ Prerequisites
1.  A device running **KOReader** (Kindle, Kobo, Android, etc.).
2.  A **Cloudflare Zero Trust** account protecting your OPDS server.

## ⚙️ Cloudflare Setup
Before installing the patch, you must generate a **Service Token** in Cloudflare. This acts as a machine-to-machine username/password for your device.

1.  Open your **Cloudflare Zero Trust Dashboard**.
2.  Navigate to **Access** > **Service Auth**.
3.  Click **Create Service Token**.
    * **Name:** `KOReader Device` (or similar).
    * **Duration:** Set to `Non-expiring` (recommended) or a custom duration.
4.  **Copy the "Client ID" and "Client Secret" immediately.** You will not be able to see the secret again.
5.  Navigate to **Access** > **Applications** and select your OPDS application.
6.  Add a new **Policy** (or edit your existing one):
    * **Action:** `Service Auth` (Recommended) or `Allow`.
    * **Rule:** Select `Service Token` and choose the token you just created.

## 📥 Installation

1.  Download the `2-cloudflare-auth.lua` file from this repository.
2.  Open the file in a text editor (Notepad++, VS Code, etc.).
3.  Replace the placeholder credentials with your tokens from Cloudflare:
    ```lua
    local CF_ID = "put-your-client-id-here"
    local CF_SECRET = "put-your-client-secret-here"
    ```
4.  Connect your KOReader device to your computer via USB.
5.  Navigate to the KOReader directory on the device:
    * **Kindle:** `.adds/koreader/patches/`
    * **Kobo:** `.adds/koreader/patches/`
    * **Android:** `/koreader/patches/`
    * *(Note: If the `patches` folder does not exist, create it).*
6.  Copy your modified `2-cloudflare-auth.lua` into that folder.
7.  **Restart KOReader** (Exit and re-open, or full reboot).

## 🔍 Verification & Troubleshooting
This patch integrates with KOReader's internal logging system. If you are having issues:

1.  Open the `crash.log` file in your KOReader directory.
2.  Search for `CF-Auth`.
3.  You should see success messages like:
    ```text
    CF-Auth: Initializing...
    CF-Auth: ✓✓✓ Hooks installed successfully ✓✓✓
    CF-Auth: ✓ Injected headers for URL: [https://your-opds-url.com/opds](https://your-opds-url.com/opds)
    ```

### Common Issues
* **"Unable to Connect":** Check your `CF_ID` and `CF_SECRET` for typos. Ensure your Cloudflare Policy is set to "Service Auth" and includes the token.
* **Boot Loop:** If KOReader crashes on boot, delete the file from the `patches` folder via USB.

## ⚠️ Security Warning
Your **Client Secret** is stored in plain text on the device.
* If you lose your device, anyone with USB access could potentially copy the token.
* **Mitigation:** If your device is lost or stolen, simply revoke the Service Token in the Cloudflare Dashboard. This will immediately cut off access without needing to change your server passwords.

## 📄 License
MIT License. Feel free to use, modify, and distribute.
