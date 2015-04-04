def run_spec
  system "clear && date && rake spec"
end
watch('.*\.rb') { run_spec }
