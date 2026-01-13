---
title: Bridgetown on Windows
top_section: Setup
category: installation-guides
back_to: installation
order: 0
---

The easiest way to use Bridgetown on Windows is to install the _Windows Subsystem for Linux_. This provides a Linux development environment in which you can install Bash, Ruby, and other tools necessary to run Bridgetown in an optimized fashion.

## Installing the Windows Subsystem for Linux

You must be running Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11. 

Open PowerShell and run:

```sh
wsl --install --distribution Ubuntu-24.04
```

You might need to restart your computer during this process. Once the setup finishes, you’ll be asked to create a username and password for your Ubuntu installation. After that, you can launch Ubuntu directly from the Start menu and log in with your new credentials. 

{%@ Note type: "primary" do %}
If the Ubuntu terminal doesn't open, try running the installation command again and make sure the WSL feature is enabled in your Control Panel.
{% end %}

## Install dependencies on Ubuntu

Launch WSL from the Start menu and update your package list:

```sh
sudo apt update
```

Next, install the required dependencies:

```sh
sudo apt install build-essential rustc libssl-dev libyaml-dev zlib1g-dev libgmp-dev
```

## Installing the Mise version manager

We’ll use [Mise](https://mise.jdx.dev/), a version manager, to install Ruby and Node. Mise makes it easy to update development tools or switch between different versions whenever you need.

```sh
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc
```

## Install Ruby

The following command installs the latest version of ruby-3.x (if any 3.x version is not already installed) and makes it the global default version:

```sh
mise use --global ruby@3
```

Once Ruby is installed, you can verify it works by running:

```sh
ruby --version
```

## Install Node 

The following command installs the latest version of node-24.x and makes it the global default:

```sh
mise use --global node@24
```

Once Node is installed, you can also verify it works by running:

```sh
node --version
```

{%@ "docs/install/bridgetown" %}

{%@ Note type: "warning" do %}
  #### Important for WSL Users

  For the best experience, always create your projects within the native Linux file system (e.g., `~/my-projects`) rather than on the Windows mount (e.g., `/mnt/c/`). 

  Developing inside `/mnt/c/` causes significant performance lag, permission errors, and breaks live-reloading. This issue impacts WSL Version 2 and is not exclusive to Bridgetown. You can [learn more about it here.](https://github.com/microsoft/WSL/issues/216) 
 
  Installing [VS Code](https://code.visualstudio.com/Download) on Windows and the [WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) enables separate environments: the editor interface runs on Windows, while code execution and plugins run on WSL. Learn more about this in the [Developing in WSL](https://code.visualstudio.com/docs/remote/wsl) topic.
{% end %}