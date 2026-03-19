# 🕹️ VPin-DMD-Highscore

**Automatically generate animated DMD highscore GIFs for PinUP Popper and Real DMD hardware (PIN2DMD).**

---

### 📝 Description

**VPin-DMD-Highscore** is a lightweight PowerShell utility designed for the Virtual Pinball (VPin) community. It bridges the gap between your game's NVRAM data and your Front-End (PinUP Popper).

When a table closes, the script extracts the top 3 real-time highscores, formats them with trophy icons (Gold, Silver, Bronze), and generates a sleek animated GIF. This media is then displayed on your **Real DMD (PIN2DMD)** or **FullDMD** screen within the Popper menu, making your cabinet feel more alive, professional, and competitive.

---

### ✨ Key Features

*   **Hardware Compatible**: Fully supports **Real DMD hardware (PIN2DMD)** through PinUP Popper's media handling.
*   **Real Data Extraction**: Uses `PINemHi` to read actual highscores stored in your NVRAM files.
*   **Dynamic Visuals**: Generates alternating frames (Player Name / Score) with customizable colors per rank.
*   **Trophy Icons**: Integrated support for **32x32 PNG icons** (Gold, Silver, Bronze) to highlight the podium.
*   **Smart Filtering**: Automatically skips tables with no recorded scores to prevent broken media.

---

### 🛠️ Prerequisites

Before installing, ensure the following requirements are met:

1.  **Hardware Setup**: Your **PIN2DMD** (or real DMD) must be already configured and fully functional within your Pincab environment.
2.  **Software Tools**:
    *   [PINemHi](http://pinemhi.com/) (The core engine for score extraction - it should be configured, check pinemhi.ini ).
    *   [ImageMagick](https://imagemagick.org/) (Required for image processing and GIF creation).
3.  **OS**: Windows PowerShell (Standard on Windows 10/11).

---

### 🚀 Quick Start Guide

1.  **Clone the Repo**: Download or clone this repository into your VPin tools folder.
2.  **Configure**: Edit `config.psd1` with your local paths:
    *   Set the path to your `pinemhi.exe`.
    *   Set the path to your `magick.exe`.
    *   Point `MediaRootDir` to your PinUP Popper DMD media folder (e.g., `C:\vPinball\PinUPSystem\POPMedia\Visual Pinball X\DMD`).
3.  **Setup Icons**: Ensure your `or.png`, `silver.png`, and `bronze.png` assets are in the `/image` subfolder.
4.  **Integrate with Popper**:
    *   Open PinUP Popper Setup.
    *   Go to **Emulators** -> **Visual Pinball X** -> **Launch Script**.
    *   In the **Post-Game** section, add the following line (adjust the path to your script):
        ```
        START /min powershell.exe -ExecutionPolicy Bypass -File "C:\your_path\Update_Score.ps1" "[ROM]" "[GAMENAME]"
        ```

---

### 📂 File Structure

*   `Highscore_Lib.ps1`: The core library containing the generation logic.
*   `Update_Score.ps1`: The trigger script for single table updates.
*   `config.psd1`: Centralized configuration file.
*   `/image`: Folder for your rank icons (Gold, Silver, Bronze).

---

### ⚖️ License

This project is licensed under the **MIT License**. Feel free to use, modify, and share it within the VPin community!

---

### 💡 Topics
`vpinball` `visual-pinball` `pinuppopper` `powershell` `highscore` `dmd` `pin2dmd` `virtual-pinball`