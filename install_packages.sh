set -ex

yum -y autoremove `yum list installed | grep group_ansible | awk '{ print $1 }'`
rm /etc/yum.repos.d/asb.repo || true

yum -y install epel-release git python-requests

cd
git clone https://git.openstack.org/openstack/tripleo-repos
cd tripleo-repos
python setup.py install
cd
tripleo-repos current

yum -y update

yum install -y \
    vim \
    sudo \
    docker \
    python-dev \
    python-setuptools \
    curl vim-enhanced telnet 

yum install -y \
  python-heat-agent \
  python-heat-agent-hiera \
  python-heat-agent-ansible \
  python-heat-agent-json-file \
  python-heat-agent-docker-cmd \
  python-heat-agent-apply-config \
  python-heat-agent-puppet python-ipaddr \
  python-tripleoclient \
  docker \
  openvswitch \
  openstack-heat-monolith \
  openstack-heat-api \
  openstack-heat-engine \
  openstack-puppet-modules

# Remove unnecessary packages
yum autoremove -y
yum clean all
