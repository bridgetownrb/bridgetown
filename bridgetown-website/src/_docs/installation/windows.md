---
title: Bridgetown on Windows
top_section: Setup
category: installation-guides
back_to: installation
order: 0
---

{%@ "docs/help_needed", resource: resource %}

The easiest way to use Bridgetown on Windows is to install the _Windows Subsystem for Linux_. This provides a Linux development environment in which you can install Bash, Ruby, and other tools necessary to run Bridgetown in an optimized fashion.

Try reading [these excellent instructions by GoRails](https://gorails.com/setup/windows/10) to install Ubuntu Linux on Windows, and then once you've reached the "**Installing Rails**" portion, you can come back and continue:

{%@ "docs/install/node_on_linux" %}
{%@ "docs/install/bridgetown" %}

{%@ Note type: "warning" do %}
    #### Windows Subsystem for Linux and Live-Reloading

    Projects residing on recent versions of WSL (Windows Subsystem for Linux) might face issues with live-reloading if the live-reload server is initialized from a non-Linux directory. For example: initializing the server from a directory within `/mnt/c/`. 
    
    This issue impacts WSL Version 2 and it's not Bridgetown-exclusive. You can [learn more about it here.](https://github.com/microsoft/WSL/issues/216)

    To minimize headaches, we recommend developing from within the Linux file system. If you use VS Code, the [Remote WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) allows you to interact with the the Linux subsystem directly. It may facilitate your development workflow.
{% end %}