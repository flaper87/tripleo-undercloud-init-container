FROM centos:7
MAINTAINER "Flavio Percoco" <flavio@redhat.com>

ARG OPENSTACK_RELEASE
LABEL openstack_release=$OPENSTACK_RELEASE

ADD install_packages.sh /tmp/
RUN /tmp/install_packages.sh && rm /tmp/install_packages.sh

ADD configure_container.sh /tmp/
RUN /tmp/configure_container.sh && rm /tmp/configure_container.sh

RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV container docker
ENV DOCKER_HOST unix:///var/docker/run/docker.sock

ADD run.sh /root
CMD [ "/root/run.sh" ]