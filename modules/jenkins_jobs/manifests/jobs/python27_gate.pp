define jenkins_jobs::jobs::python27_gate($site, $project, $node_group, $trigger_branches) {
  jenkins_jobs::build_job { "gate-${name}-python27":
    site => $site,
    project => $project,
    job => "python27",
    node_group => $node_group,
    triggers => trigger("gerrit_comment"),
    builders => [builder("gerrit_git_prep"), builder("copy_bundle"), builder("python27")],
    trigger_branches => $trigger_branches
  }
}
