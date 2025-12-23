# QuickWin


Windows
The Clean Windows Toolkit

Zero Bloat. Zero Dependencies.

A powerful, open-source automation toolkit designed to debloat, optimize, and set up Windows 10/11 environments with a single command.
⚡ Quick Install

Run the following command in PowerShell (Administrator):

irm https://M-d3bug.github.io/QuickWin/install.ps1 | iex

 

    Note: Ensure you are running PowerShell as Administrator for the script to execute correctly. 
     

🚀 Why QuickWin? 

QuickWin is the perfect utility for fresh Windows 10/11 installations, specifically tailored for LTSC and Enterprise editions that often lack modern tools out of the box. It is designed to be non-invasive, applying safe optimizations and tweaks that enhance performance without compromising system stability. 
Core Features 

     

    🛡️ LTSC Ready
    Automatically detects if winget is missing. If absent, it deploys a portable package manager (UniGetUI) so you never miss out on essential software tools. 
     

    🧹 Bloatware Removal
    Securely removes pre-installed third-party apps (Candy Crush, Twitter, etc.) and unnecessary telemetry services. 
     

    ⚙️ Privacy & Performance
    Hardens system privacy by disabling advertising ID, location tracking, and diagnostic data reporting. Includes UI tweaks like restoring the old Photo Viewer and enabling "End Task" on the taskbar. 
     

    📦 Essential Apps
    Automatically installs core software like 7-Zip, Brave, Notepad++, VLC, and qView silently via Winget. 
     

    🔌 External Utility Hub
    Seamlessly execute external community tools like Massgrave or Winscript. Supports running custom registry keys and advanced PowerShell commands directly from the menu. 
     

    ↩️ Revert Functionality
    Made a mistake? The Revert function safely restores default Windows settings and services, ensuring you are always in control. 
     

🛠️ Usage 

    Run the Powershell command above, or Download and Run QuickWin.cmd as Administrator.  
    Select an option from the menu:
         Install WingetUI: Sets up the package manager if missing.
         Install Essential Apps: Deploys your core software suite.
         Apply Safe Tweaks: Optimizes UI, Privacy, and Services.
         External Utility Hub: Run Massgrave, Winscript, or custom scripts.
         Run Complete Setup: Executes steps 1-3 automatically.
          

⚠️ System Requirements 

     OS: Windows 10 / 11 (Pro, Home, Enterprise, or LTSC)
     Privileges: Administrator access is required to modify registry keys and system services.

    

🙏 Credits & Attributions 

QuickWin is an automation wrapper script. All rights to the individual applications, utilities, and external scripts invoked by this tool belong to their respective authors and creators. 

External Tools Integrated: 

     UniGetUI  by marticliment - Used for package management compatibility on LTSC systems.
     Chris Titus Utility  by Chris Titus - Leveraged for advanced Windows system utilities.     

Software Distributed via Winget: 

     7-Zip  by Igor Pavlov
     Notepad++  by Don Ho
     VLC media player  by the VideoLAN organization
     qView  by jurplel
     Brave Browser  by Brave Software, Inc.
     

    Disclaimer: This script is provided as-is for educational and automation purposes. We do not host, redistribute, or claim ownership of any external software or scripts mentioned above. 
          

    <i>Made with ❤️ for a cleaner Windows experience.</i>
</div>
```
