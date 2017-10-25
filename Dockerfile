FROM jenkins/jenkins:lts

# Declare mount point for Docker (which is in Docker)
VOLUME /var/lib/docker

# Configure Jenkins plugins installation
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

USER root

# Install common packages
RUN apt-get update
RUN apt-get -y install apt-transport-https software-properties-common apt-utils ca-certificates curl gnupg2

# Install Docker CE
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
RUN apt-get update
RUN apt-get install -y docker-ce

# Add jenkins user to docker group to authorize Jenkins to run Docker
RUN gpasswd -a jenkins docker

##### Here start the hack with supervisor and wrapdocker to be able to run both Docker and Jenkins

# Install Supervisor
RUN apt-get install -y supervisor

# Copy Supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create log folders for Supervisor, Jenkins and Docker
RUN mkdir -p /var/log/supervisor /var/log/jenkins /var/log/docker
RUN chown -R jenkins /var/log/jenkins

# Download wrapdocker
RUN wget https://raw.githubusercontent.com/jpetazzo/dind/master/wrapdocker -O /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
