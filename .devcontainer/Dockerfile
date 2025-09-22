FROM eclipse-temurin:21-jdk-jammy

# Basis-Tools + Fonts (keine alte Ubuntu-Node!)
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates unzip git \
      fonts-dejavu fonts-liberation fontconfig \
      bash-completion \
    && rm -rf /var/lib/apt/lists/*

# Node 20 via NodeSource (fix für SUSHI)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get update && apt-get install -y nodejs \
 && npm i -g fsh-sushi

# Ruby und Jekyll installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
      ruby-full build-essential zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && gem install jekyll bundler

# WORKDIR an VSCode-Standard mount anlehnen
WORKDIR /workspaces

# IG Publisher direkt im übergeordneten Ordner installieren
ARG IG_PUBLISHER_URL=https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar
RUN curl -L "$IG_PUBLISHER_URL" -o publisher.jar

# Unprivilegierter User
RUN useradd -m runner -s /bin/bash \
 && mkdir -p /workspaces \
 && chown -R runner:runner /workspaces

# Bash-completion für runner user aktivieren
RUN echo 'source /usr/share/bash-completion/bash_completion' >> /home/runner/.bashrc

USER runner