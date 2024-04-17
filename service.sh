#!/bin/bash

REPO_URL="https://github.com/your_username/your_repository.git"
PROJECT_NAME="your_repository"

git clone $REPO_URL
cd $PROJECT_NAME

pip install -r requirements.txt

OS="$(uname -s)"

case "$OS" in
    "Linux")  
        SERVICE_FILE=/etc/systemd/system/myservice.service
        echo "[Unit]
Description=My Python Service
After=network.target

[Service]
User=$(whoami)
ExecStart=$(which python3) $(pwd)/main.py
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee $SERVICE_FILE

        sudo systemctl daemon-reload
        sudo systemctl enable myservice
        sudo systemctl start myservice
        ;;
    "Darwin") 
        PLIST=/Library/LaunchDaemons/com.myservice.plist
        echo "<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE plist PUBLIC '-//Apple Computer//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>
<plist version='1.0'>
<dict>
    <key>Label</key>
    <string>com.myservice</string>
    <key>ProgramArguments</key>
    <array>
        <string>$(which python3)</string>
        <string>$(pwd)/main.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>" | sudo tee $PLIST

        sudo launchctl load $PLIST
        sudo launchctl start com.myservice
        ;;
    *)
        echo "Unsupported operating system."
        exit 1
        ;;
esac
