# Aite OS — push to your repo

Two files in this archive:

* `aite-os-source.zip` — flat snapshot of the working tree (no git history).
* `aite-os.bundle` — full git bundle with the two branches (`main` + the
  feature branch). Recommended: this preserves history.

## Option A — using the bundle (recommended)

```bash
# 1) clone an empty copy of your remote repo (it's fine to do this in a
#    throwaway directory).
git clone https://github.com/a78009866/Aite-os.git aite-os && cd aite-os

# 2) pull the two branches from the bundle into local refs.
git fetch ../aite-os.bundle 'refs/heads/*:refs/heads/*'

# 3) push them up.
git push origin main
git push origin devin/1778175396-aite-os-initial-scaffold

# 4) on github.com, open a PR from the feature branch into main.
```

## Option B — using the zip (simpler but loses history)

```bash
# 1) unzip into the empty repo
git clone https://github.com/a78009866/Aite-os.git aite-os && cd aite-os
unzip -o ../aite-os-source.zip -d .

# 2) commit and push to main
git add archiso .github README.md LICENSE .gitignore .gitattributes
git commit -m "Initial Aite OS scaffold"
git push origin main
```

After either option, GitHub Actions will pick up `.github/workflows/build-iso.yml`
and build the ISO automatically. The first build takes 15–30 minutes; the ISO
appears as a workflow artifact named `aite-os-iso`.

To publish a release with the ISO attached:

```bash
git tag v0.1.0
git push origin v0.1.0
```
