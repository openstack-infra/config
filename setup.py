import datetime
from setuptools import setup

ci_cmdclass = {}

try:
    from sphinx.setup_command import BuildDoc

    class local_BuildDoc(BuildDoc):
        def run(self):
            for builder in ['html', 'man']:
                self.builder = builder
                self.finalize_options()
                BuildDoc.run(self)
    ci_cmdclass['build_sphinx'] = local_BuildDoc
except Exception:
    pass

setup(name='openstack-ci-puppet',
      version="%d.%02d" % (datetime.datetime.now().year,
                           datetime.datetime.now().month),
      description="OpenStack Continuous Integration Scripts",
      author="OpenStack CI Team",
      author_email="openstack-ci@lists.launchpad.net",
      url="http://launchpad.net/openstack-ci",
      cmdclass=ci_cmdclass)
