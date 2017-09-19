# helper for go list command to display package dependencies

DEPS_PROJECT=${DEPS_PROJECT:-dimap}

deps() {
    go list -f '{{ join .Deps "\n" }}' | grep $DEPS_PROJECT
}
