# __Getting Started__

Opis w jaki sposób wygenerować dokument "Getting Started" znajduje się w repozytorium [Android API](https://gitlab.blastlab.local/indoornavi/Android-api) w zakładce **Documentation**.

# __IndoorNavi iOS API__

IndoorNavi iOS API jest frameworkiem dla iOS SDK zapewniającym funkcjonalności IndoorNavi w projekcie aplikacji mobilnej.
Pozwala na umieszczenie widoku mapy, jej konfigurację i obsługę.
Dodatkowo framework pozwala na korzystanie z lokalizacji oraz nawigację używając BLE w urządzeniu mobilnym.

## __Generowanie Frameworka__

Obecnie z frameworkiem nie jest skonfigurowany żaden Dependency Manager (CocoaPods lub Carthage). Można natomiast wygenerować zamknięty plik binarny, zawierający architektury zarówno dla urządzeń jak i symulatorów, który można zaimportować w innych projektach.
W tym celu należy otworzyć projekt IndoorNavi w Xcode, wybrać schemat **IndoorNavi-Universal** oraz zbudować projekt. W katalogu projektu zostanie wtedy utworzony plik *IndoorNavi.framework*.

<aside class="info">
Repozytorium zawiera submoduł z IndoorNavi JS API, który jest kluczowy do poprawnego działania frameworku. [Link do repozytorium](https://gitlab.blastlab.local/indoornavi/javascript-api).
</aside>

## __Wykorzystanie__

Tak wygenerowany plik można zaimportować w dowolnej aplikacji. Jest to framework uniwersalny, więc może być wykorzystany do budowania aplikacji zarówno na symulatory jak i rzeczywiste urządzenia.

<aside class="warning">
Tak zbudowana aplikacja nie przejdzie weryfikacji na AppStore ze względu na nadmiarowość (moduły zbudowane na architekturę *x86*, a więc symulatory). Aby temu zapobiec, należy wykonać czynności opisane poniżej.
</aside>

Można odłączyć nadmiarowe moduły z frameworku dodając *Run Script* w zakładce *Build Phases*, oraz wklejając poniższy skrypt.

```
################################################################################
#
# Copyright 2015 Realm Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# This script strips all non-valid architectures from dynamic libraries in
# the application's `Frameworks` directory.
#
# The following environment variables are required:
#
# BUILT_PRODUCTS_DIR
# FRAMEWORKS_FOLDER_PATH
# VALID_ARCHS
# EXPANDED_CODE_SIGN_IDENTITY

# Signs a framework with the provided identity
code_sign() {
# Use the current code_sign_identitiy
echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
echo "/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements $1"
/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements "$1"
}

echo "Stripping frameworks"
cd "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

for file in $(find . -type f -perm +111); do
# Skip non-dynamic libraries
if ! [[ "$(file "$file")" == *"dynamically linked shared library"* ]]; then
continue
fi
# Get architectures for current file
archs="$(lipo -info "${file}" | rev | cut -d ':' -f1 | rev)"
stripped=""
for arch in $archs; do
if ! [[ "${VALID_ARCHS}" == *"$arch"* ]]; then
# Strip non-valid architectures in-place
lipo -remove "$arch" -output "$file" "$file" || exit 1
stripped="$stripped $arch"
fi
done
if [[ "$stripped" != "" ]]; then
echo "Stripped $file of architectures:$stripped"
if [ "${CODE_SIGNING_REQUIRED}" == "YES" ]; then
code_sign "${file}"
fi
fi
done
```

Dokładny opis skryptu: <https://instabug.com/blog/ios-binary-framework/>.
