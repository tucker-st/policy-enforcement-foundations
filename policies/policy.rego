package gate

default allow := false

# Blocking reasons (set)
reasons contains r if {
  input.vulns.critical > 0
  r := sprintf("Denied: critical vulnerabilities present (%d).", [input.vulns.critical])
}

reasons contains r if {
  input.vulns.high > 0
  not input.controls.allow_high
  r := sprintf("Denied: high vulnerabilities present (%d) and allow_high=false.", [input.vulns.high])
}

reasons contains r if {
  input.vulns.medium > 0
  not input.controls.allow_medium
  r := sprintf("Denied: medium vulnerabilities present (%d) and allow_medium=false.", [input.vulns.medium])
}

# Non-blocking warnings (set)
warnings contains w if {
  input.changes.images_removed > 0
  w := sprintf("Warning: images removed (%d). Review change intent.", [input.changes.images_removed])
}

warnings contains w if {
  input.changes.images_added > 0
  w := sprintf("Warning: images added (%d). Review provenance and intent.", [input.changes.images_added])
}

# Allow when no reasons exist
allow if {
  count(reasons) == 0
}

# Lists for easy consumption
reasons_list := sort([r | reasons[r]])
warnings_list := sort([w | warnings[w]])
