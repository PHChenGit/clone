FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
# build-essential: GCC/G++ and friends
# cmake, ninja-build: Build systems
# git, gdb, curl, wget, sudo: Tools
# zsh, neovim: User preferred tools
# Qt/Slint dependencies: Required libraries for UI compilation on Linux
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    gdb \
    curl \
    wget \
    sudo \
    zsh \
    zsh \
    neovim \
    ripgrep \
    fd-find \
    libfontconfig1-dev \
    libssl-dev \
    pkg-config \
    libxcb1-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    qtbase5-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user 'vscode'
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/zsh \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to the non-root user
USER $USERNAME

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/$USERNAME/.cargo/bin:$PATH"

# Install Oh My Zsh (Optional but nice for zsh users)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install User's Neovim Config
RUN git clone https://github.com/PHChenGit/nvim_config.git /home/$USERNAME/.config/nvim

# Fix fd-find binary name for Neovim/User
RUN mkdir -p /home/$USERNAME/.local/bin && ln -s /usr/bin/fdfind /home/$USERNAME/.local/bin/fd
ENV PATH="/home/$USERNAME/.local/bin:$PATH"

# Set working directory
WORKDIR /workspace

CMD ["/bin/zsh"]
