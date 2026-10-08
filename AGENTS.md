# Container rules
- Every image (Dockerfile FROM and compose image:) must come from dhi.io.
- Look up images with the dhi.io MCP tools. Do not use web search for image selection.
- Never use Docker Hub, public.ecr.aws, mirrors, or any other registry, even if blocked.
- If no DHI image exists, stop and report it as a gap.
- "Done" means `docker compose up --build` succeeds and you have checked every image line.
