#!/usr/bin/env ruby

# This is a cron-job like script which is triggered from upstart (/etc/init/.)
# In slave nodes, it registers with jenkins.opencontrail.org master with
# appropriate node label, so that the master can scheduler jobs.
#
# In the sub-slave mode, this checks for periodic keep-alives (file based
# time-stamps. If time-stamp is not updated in time, sub-slave node is deleted
# from the cluster. This is done, to avoid zombie sub-slave VMs from hogging
# build cluster resources.

$LOAD_PATH.unshift "/usr/local/jenkins/slave_scripts/",
                   "/usr/local/jenkins/slave_scripts/ci-infra"
require 'util'

def setup_hostname
    @hostname = Vm.get_hostname()
    @hostip = Vm.get_interface_ip

    Sh.run "\grep #{@hostname} /etc/hosts || echo #{@hostip} #{@hostname} >> /etc/hosts"
    Sh.run "echo #{@hostname} > /etc/hostname"
    Sh.run "service hostname restart", true
end

def slave
    # Skip in test mode
    loop do
        skip, e = Sh.rrun "ssh root@jenkins.opencontrail.org ls -1 /root/ci-test/\*#{@HOSTNAME}\*-test"
        break if skip.nil? or skip !~ /#{@hostname}/
        sleep 10
    end

    jenkins_user = "ci-admin-f"
    jenkins_password = ""

    # Get jenkins master user name and password via ssh
    IO.popen("ssh -q jenkins.opencontrail.org cat /etc/jenkins_jobs/jenkins_jobs.ini").readlines.each { |line|
        jenkins_user = $1 if line =~ /user=(.*)\n/
        jenkins_password = $1 if line =~ /password=(.*)\n/
    }

    # Download the jenkins swarm client file if necessary.
    jar_file = "/root/swarm-client-1.15-jar-with-dependencies.jar"
    if !File.file? jar_file then
        Sh.run "wget -o #{jar_file} http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/1.15/swarm-client-1.15-jar-with-dependencies.jar"
    end

    slave_labels, e = Sh.rrun(%{curl -s http://169.254.169.254/openstack/2012-08-10/meta_data.json | python -m json.tool | \grep \\"slave-labels\\": | awk -F '\"' '{print $4}'})
    slave_executors, e = Sh.rrun(%{curl -s http://169.254.169.254/openstack/2012-08-10/meta_data.json | python -m json.tool | \grep \\"slave-executors\\": | awk -F '\"' '{print $4}'})

    slave_labels = "juniper-tests" if slave_labels.nil? or slave_labels.empty?
    slave_executors = "1" if slave_executors.nil? or slave_executors.empty?

    # CI-Slaves register to jenkins.opencontrail.org
    Sh.run(%{java -jar #{jar_file} -labels #{slave_labels} -mode normal -master http://jenkins.opencontrail.org:8080/ -executors #{slave_executors} -fsroot /home/jenkins -username #{jenkins_user} -password #{jenkins_password} -name #{@hostname} 2>&1 | tee /root/jenkins-slave.log}, true)
end

def subslave

    # Read the time object, periodically updated by the master.
    last_updated = Time.now

    kfile = "/root/#{@hostname}-jenkins-keepalive.log"
    dfile = "/root/#{@hostname}-jenkins-keepalive.debug"
    loop do
        last_updated = File.open(kfile, "r") { |fp| Time.mktime *fp.readlines }\
            if File.file? kfile
        elapsed = (Time.now - last_updated)/60
        File.open(dfile, "w") { |fp|
            fp.puts "#{@hostname}: #{elapsed} minutes elapsed since last update"

            # If it is not updated within some time, commit suicide!, not if we
            # we want to skip this intentionally (for testing purposes)
            if !File.file? "/root/skip_subslave_keepalive" and elapsed > 120 then
#               o, e = Sh.crun "nova delete #{@hostname}"
                fp.puts(o)
            end
        }
        sleep 10
    end
end

def main
    setup_hostname
    pp @hostname, @hostip
    loop do
        subslave if @hostname =~ /ci-oc-subslave/
        slave if @hostname =~ /ci-o[cs]-slave/ # oc or os slave
        sleep 10
    end
end

main
