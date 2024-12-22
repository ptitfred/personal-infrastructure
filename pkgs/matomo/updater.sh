version="$(http https://builds.matomo.org/LATEST_5X)"
url="https://builds.matomo.org/matomo-${version}.tar.gz"
generic-updater matomo "${version}" "${url}"
