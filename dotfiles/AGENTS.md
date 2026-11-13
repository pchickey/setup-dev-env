Your defaults for adding comments to code is too verbose. Cut down the
comments you leave to the 30% of information which is most important.

Whenever working in a repository in the bytecodealliance github org, follow
the bytecodealliance AI tool use policy, found at:
https://raw.githubusercontent.com/bytecodealliance/governance/refs/heads/main/AI_TOOL_POLICY.md.

By default, do not create issues, PRs, or commit messages yourself, always ask
for human intervention. You can suggest a `gh` command for a human to execute
to create issues or PRs.

Never comment on, review, label, react to, or otherwise write to issues or PRs
on GitHub (or any other forge). Reading them is fine.

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

When creating a git worktree of a repo at `repo/`, create the worktree for
`branchname` at `repo.worktrees/branchname`: in the same parent directory, but
with in a new directory with the .worktrees suffix, and then in a directory in
there named like the branch.

When we're developing an nginx module, unless instructed otherwise, I keep a
checkout of an up-to-date nginx at ~/src/nginx, and the nginx-tests repo at
~/src/nginx/tests. I keep a checkout of njs at ~/src/njs if the build requires
that module.

When you need to use temporary files, try not to use /tmp or ~ for these. If
you're working in a git worktree, make a directory .claude/tmp and use that
for any temporary storage needs.

When testing the wasmtime-wasi-http crate, the p2::sync, p2::async_ and p3
http_outbound_request_timeout tests will fail when run on my development
laptop due to interactions with my corporate vpn. Ignore these failures.

## Docker containers and the corporate TLS proxy

On this machine, outbound TLS goes through a Netskope intercepting proxy
(certificates issued by `ca.f5.goskope.com`). Containers don't trust it, so
git, curl, pip, cargo, rustup etc. fail with "self-signed certificate in
certificate chain" or git's "server certificate verification failed".
Setting GIT_SSL_CAINFO to the image's own bundle does not help.

Every image we build must install the corporate CA bundle. The host's
bundle is `/Library/corp-ca/corp-ca-bundle.pem`, a symlink, so copy it with
`cp -L` into the build context (Docker can't COPY from outside the context
or follow symlinks out of it), and don't commit that copy:

    cp -L /Library/corp-ca/corp-ca-bundle.pem <build-context>/corp-ca.crt

Debian/Ubuntu Dockerfile, placed right after ca-certificates is installed
and before any network fetch (rustup, git clone, pip):

    COPY corp-ca.crt /usr/local/share/ca-certificates/corp-ca.crt
    RUN update-ca-certificates

Alpine: same COPY, then `RUN apk add ca-certificates && update-ca-certificates`.
Fedora/RHEL: COPY to /etc/pki/ca-trust/source/anchors/ and `RUN update-ca-trust`.

For a stock image you run without building (no Dockerfile), mount the
bundle and point the tools at it:

    docker run -v /Library/corp-ca/corp-ca-bundle.pem:/corp-ca.pem:ro \
      -e SSL_CERT_FILE=/corp-ca.pem -e GIT_SSL_CAINFO=/corp-ca.pem \
      -e CURL_CA_BUNDLE=/corp-ca.pem -e REQUESTS_CA_BUNDLE=/corp-ca.pem \
      -e PIP_CERT=/corp-ca.pem -e CARGO_HTTP_CAINFO=/corp-ca.pem ...
