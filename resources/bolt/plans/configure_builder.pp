plan raspbian_builder::configure_builder (
  TargetSpec $targets,
) {
  wait_until_available($targets)

  run_task('raspbian_builder::configure_builder', $targets,
           {_run_as => root})
}
