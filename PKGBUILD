# Maintainer: oporpino <eu@porpi.no>

pkgname=arrow-cli
pkgver=1.0.0
pkgrel=1
pkgdesc="Arch Linux for humans — an intuitive wrapper for pacman"
arch=('any')
url="https://github.com/oporpino/arrow"
license=('MIT')
depends=('pacman' 'bash')
makedepends=('make')
optdepends=(
  'yay: AUR helper support (arrow aur)'
  'paru: AUR helper support (arrow aur)'
  'pacman-contrib: dependency tree via pactree (arrow deps)'
  'reflector: fast mirror selection (arrow mirrors)'
)
provides=('arrow')
conflicts=('arrow')
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
b2sums=('SKIP')

build() {
  cd "arrow-$pkgver"
  make build
}

package() {
  cd "arrow-$pkgver"
  make install PREFIX="$pkgdir/usr"
}
