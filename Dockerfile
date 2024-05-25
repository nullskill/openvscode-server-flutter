ARG VERSION="stable"
ARG FLUTTER_HOME="/opt/flutter"
ARG PUB_CACHE="/var/tmp/.pub_cache"
ARG FLUTTER_VERSION="3.22.1"
ARG FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
ARG FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"

FROM gitpod/openvscode-server:latest

USER root
WORKDIR /

ARG VERSION
ARG FLUTTER_HOME
ARG PUB_CACHE
ARG FLUTTER_ARCHIVE
ARG FLUTTER_URL

ENV VERSION=$VERSION \
    FLUTTER_HOME=$FLUTTER_HOME \
    FLUTTER_ROOT=$FLUTTER_HOME \
    PUB_CACHE=$PUB_CACHE \
    PATH="${PATH}:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin" \
    OPENVSCODE_SERVER_ROOT="/home/.openvscode-server" \
    OPENVSCODE="${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server"

# Install prerequisites
RUN echo "Installing prerequisites..."
RUN apt-get update
RUN apt-get install -y nano curl git unzip xz-utils
RUN mkdir $PUB_CACHE $FLUTTER_HOME

# Download and extract Flutter SDK
RUN echo "Downloading and extracting Flutter SDK..."
WORKDIR /opt
# Download the Flutter SDK (using -L to follow redirects)
RUN curl -L -o $FLUTTER_ARCHIVE $FLUTTER_URL \
    && tar xf $FLUTTER_ARCHIVE && rm $FLUTTER_ARCHIVE

# Add Flutter to PATH
RUN echo "Adding Flutter to PATH."
SHELL ["/bin/bash", "-c"]
RUN echo "export PATH=${PATH}" >> ~/.bashrc
RUN echo "alias ll=\"ls -la\"" >> ~/.bashrc
RUN . ~/.bashrc

# Accept Flutter licenses
RUN echo "Accepting Flutter licenses..."
RUN git config --global --add safe.directory /opt/flutter
RUN set -eux; flutter doctor --android-licenses \
    && flutter --disable-analytics \
    && flutter config --no-analytics

# Install Dart SDK
RUN echo "Installing Dart SDK..."
RUN flutter pub global activate dartdoc \
    && flutter pub global activate protoc_plugin \
    && flutter doctor && flutter precache --universal
RUN echo "Flutter and Dart installation completed successfully."

USER openvscode-server

RUN echo "Adding Oh My Bash"
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended

RUN echo "Adding Flutter completion for Bash"
RUN flutter bash-completion > ~/.bashrc

RUN echo "Adding Dart & Flutter VSCode extensions..."
SHELL ["/bin/bash", "-c"]
RUN \
    # # Direct download links to .vsix which are not available on https://open-vsx.org/
    # urls=(\
    #     https://github.com/rust-lang/rust-analyzer/releases/download/2022-12-26/rust-analyzer-linux-x64.vsix \
    #     https://github.com/VSCodeVim/Vim/releases/download/v1.24.3/vim-1.24.3.vsix \
    # )\
    # # Create a tmp dir for downloading
    # && tdir=/tmp/exts && mkdir -p "${tdir}" && cd "${tdir}" \
    # # Download via wget from $urls array.
    # && wget "${urls[@]}" && \
    # List the extensions in this array
    exts=(\
        # From https://open-vsx.org/ registry directly
        # gitpod.gitpod-theme \
        Dart-Code.dart-code \
        Dart-Code.flutter \
        # # From filesystem, .vsix that we downloaded (using bash wildcard '*')
        # "${tdir}"/* \
    )\
    # Install the $exts
    && for ext in "${exts[@]}"; do ${OPENVSCODE} --install-extension "${ext}"; done

RUN echo "Adding permissions..."
RUN sudo chown -R openvscode-server:openvscode-server $HOME $PUB_CACHE \
    && sudo chmod -R u+rw $HOME $PUB_CACHE
WORKDIR $HOME