Your defaults for adding comments to code is too verbose. Cut down the
comments you leave to the 30% of information which is most important.

Whenever working in a repository in the bytecodealliance github org, follow
the bytecodealliance AI tool use policy, found at:
https://raw.githubusercontent.com/bytecodealliance/governance/refs/heads/main/AI_TOOL_POLICY.md.

By default, do not create issues, PRs, or commit messages yourself, always ask
for human intervention. You can suggest a `gh` command for a human to execute
to create issues or PRs.

Expect that I will edit the code output by the LLM frequently, and without
telling you explicitly. Expect that I will create commits whenever I see the
progress is worth saving, and that I will iterate on code with the agent and
manually to get it ready to commit. I will always be the one to push commits
to the remote, unless we are working with skills that have specifically
outlined procedures for creating and pushing commits to specific repositories.

I use a security key for ssh authentication and signatures, and git is
congigured to sign my commits.

When explicitly asked to create a git commit on my behalf, do not add any
information about the LLM that created the commit. Do not add a Co-Authored-By
line, Assisted-By line, or any other information indicating what model or
agent created the commit.

When asked to backport changes to another branch, don't add information about
specifics of the backport to the commit message, leave that in the chat log
for me to review.
