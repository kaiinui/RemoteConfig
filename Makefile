podspec_path := $(wildcard *.podspec)

# @public
# @param VER: string
# @example make pod VER=v0.2.0
pod: podspec pod_push

# @public
# @param VER: string
# @example make release VER=v0.1.0
release: github_release podspec pod_push
	
# @param VER: string
# @example make release VER=v0.1.0
github_release:
	git tag $(VER) && git push --tags
	github-release release \
	--user $(USER) \
	--repo $(PROJECT) \
	--tag $(VER) \
	--name $(VER) \
	--pre-release

# Update *.podspec's version to specified version.
#
# @param VER: string
# @example make podspec VER=v0.1.0
podspec:
	sed \
	-i "" \
	-e 's/= "[0-9]*\.[0-9]*\.[0-9]*"/= \"$(subst v,,$(VER))\"/' \
	-e "s/v[0-9]*\.[0-9]*\.[0-9]*/$(VER)/" \
	$(podspec_path)

# Push to the CocoaPods Specs Repo
pod_push:
	pod trunk push
