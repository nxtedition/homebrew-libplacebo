class Libplacebo < Formula
  include Language::Python::Virtualenv

  desc "Reusable library for GPU-accelerated image/video processing primitives"
  homepage "https://code.videolan.org/videolan/libplacebo"
  license "LGPL-2.1-or-later"
  head "https://github.com/nxtedition/libplacebo.git", branch: "master"

  bottle do
    sha256 cellar: :any, arm64_sequoia:  "3d549716eb833fbc554605706f4e4740f0c1c4e6cf23732326444627ea14a8d5"
    sha256 cellar: :any, arm64_sonoma:   "72afc163cc9dfc5525ed856094449685f034dfbbd8528f04e448b0447dd44f06"
    sha256 cellar: :any, arm64_ventura:  "8860b6fd41fdd672a503b4951cb539d8ae11eaf953b64aef8188090f862138ab"
    sha256 cellar: :any, arm64_monterey: "bfba0779b291723de7012b77cfc04e2d2909764012580e002808658697768ef2"
    sha256 cellar: :any, sonoma:         "a5f15e9286de87a34619dbd377fd26a83fddb667ff45036fa7aa09ad3ca2a3d3"
    sha256 cellar: :any, ventura:        "7ee7837caa82be9fa7294eb11f9a34545aad429a2202aaef5b19ba50dc02ea08"
    sha256 cellar: :any, monterey:       "be243d1baa8e092186e1f6a7d8be0964e243bcb77fe2372dbc3736c3a3f8d910"
    sha256               x86_64_linux:   "db810576ae7bfb3bc20cf244271d00ab7e24701fe77d2540cf10407b22d6392d"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.13" => :build
  depends_on "vulkan-headers" => :build

  depends_on "little-cms2"
  depends_on "shaderc"
  depends_on "vulkan-loader"

  def install
    resources.each do |r|
      # Override resource name to use expected directory name
      dir_name = case r.name
      when "glad2", "jinja2"
        r.name.sub(/\d+$/, "")
      else
        r.name
      end

      r.stage(Pathname("3rdparty")/dir_name)
    end

    system "meson", "setup", "build",
                    "-Dvulkan-registry=#{Formula["vulkan-headers"].share}/vulkan/registry/vk.xml",
                    "-Dshaderc=enabled", "-Dvulkan=enabled", "-Dlcms=enabled",
                    *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <libplacebo/config.h>
      #include <stdlib.h>
      int main() {
        return (pl_version() != NULL) ? 0 : 1;
      }
    C
    system ENV.cc, "-o", "test", "test.c", "-I#{include}",
                   "-L#{lib}", "-lplacebo"
    system "./test"
  end
end