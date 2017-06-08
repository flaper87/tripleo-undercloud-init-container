FROM ansibleplaybookbundle/apb-base
MAINTAINER "Flavio Percoco" <flavio@redhat.com>

LABEL "com.redhat.apb.version"="0.1.0"
LABEL "com.redhat.apb.spec"=\
"aWQ6IGVmMWY5Yzk3LTY4YmYtNGUyMS05OTQ1LWNkOTEyOWY4Yzk5OQpuYW1lOiBhcGItdHJpcGxl\
by11bmRlcmNsb3VkCmltYWdlOiB0cmlwbGVvdXBzdHJlYW0vYXBiLXRyaXBsZW8tdW5kZXJjbG91\
ZApkZXNjcmlwdGlvbjogVGhpcyBpcyBhIHNhbXBsZSBhcHBsaWNhdGlvbiBnZW5lcmF0ZWQgYnkg\
YXBiIGluaXQKYmluZGFibGU6IFRydWUKYXN5bmM6IG9wdGlvbmFsCnBhcmFtZXRlcnM6IFtdCg=="

USER root

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

USER apb
ADD playbooks /opt/apb/actions
ADD roles /opt/ansible/roles

ADD run.sh /root
ADD deploy.sh /root
CMD [ "/root/run.sh" ]
