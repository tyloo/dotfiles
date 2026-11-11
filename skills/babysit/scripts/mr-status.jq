. as $mr
| ((.description // ""
    | capture("<!-- monocle:state (?<state>[^\\n]+) -->").state
    | fromjson) // null) as $monocle
| {
    sha,
    state,
    draft,
    detailed_merge_status,
    head_pipeline: (.head_pipeline | if . == null then null else {id, sha, status} end),
    monocle: {
      reviewed_sha: $monocle.reviewed_sha,
      run: ([$monocle.runs[]? | select(.head_sha == $mr.sha)]
        | max_by(.started_at)
        | if . == null then null else {run_id, head_sha, started_at, ended_at, cancelled_at} end)
    }
  }
