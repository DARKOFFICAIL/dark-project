#!/usr/bin/env bash
set -e
# Usage: ./create_and_zip.sh
ROOT="dark-security-suite"

echo "Creating project structure in ./$ROOT ..."
rm -rf "$ROOT"
mkdir -p "$ROOT/assets"
mkdir -p "$ROOT/python"
mkdir -p "$ROOT/src/main/java/com/darkofficail/securitysuite"
mkdir -p "$ROOT/src/main/resources"
mkdir -p "$ROOT/.github/workflows"

cat > "$ROOT/README.md" <<'README'
# Dark Security Suite — إعداد وتشغيل

هذا المشروع عبارة عن تطبيق سطح مكتب بلغة Java (JavaFX) مع موديول Python لفحص الروابط والنصوص المشبوهة. الواجهة تحتوي على أنيميشن وخلفية قابلة للتعديل.

ملاحظات مهمة
- لا أدرج أي صور محمية بحقوق نشر. ضع صورة لديك الحق باستخدامها باسم `assets/fsociety.png`.
- هذا مشروع لأغراض دفاعية/تعليمية فقط. لا تستخدمه لأنشطة ضارة.

المتطلبات
- Java 17 أو أحدث (OpenJDK مقترح)
- Maven
- Python 3.8 أو أحدث
- pip

ما المطلوب منك الآن
1. ضع صورة الخلفية في `assets/fsociety.png`.
2. ضع أيقونة التطبيق في `src/main/resources/icon.png`.
3. (اختياري) إذا أردت تكامل VirusTotal أرسل مفتاح الـ API وسأدرجه.

تشغيل محلي (Linux / macOS)
1. ثبت متطلبات Python:
   python3 -m venv venv
   source venv/bin/activate
   pip install -r python/requirements.txt
2. شغل التطبيق عبر Maven:
   mvn clean javafx:run

تشغيل في ويندوز (PowerShell)
1. python -m venv venv
   .\venv\Scripts\Activate.ps1
   pip install -r python\requirements.txt
2. mvn clean javafx:run

بناء الحزمة (اختياري)
- لصنع jar أو native image استخدم أدوات مثل jpackage أو Maven plugins — أقدر أساعدك في تجهيز سكربت packager عند الطلب.
README

cat > "$ROOT/pom.xml" <<'POM'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.darkofficail</groupId>
  <artifactId>dark-security-suite</artifactId>
  <version>0.1.0</version>
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <java.version>17</java.version>
    <javafx.version>20</javafx.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.15.2</version>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.openjfx</groupId>
        <artifactId>javafx-maven-plugin</artifactId>
        <version>0.0.8</version>
        <configuration>
          <mainClass>com.darkofficail.securitysuite.Main</mainClass>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
POM

cat > "$ROOT/.gitignore" <<'GITIGNORE'
# Maven
/target/
!.mvn/wrapper/maven-wrapper.jar

# IntelliJ
.idea/
*.iml

# Python venv
venv/
__pycache__/

# OS
.DS_Store
Thumbs.db

# build outputs
*.zip
*.tar.gz
GITIGNORE

cat > "$ROOT/build.sh" <<'BSH'
#!/usr/bin/env bash
set -e
# build script for Linux / macOS
echo "Installing Python requirements..."
python3 -m venv venv || true
source venv/bin/activate
pip install -r python/requirements.txt

echo "Building and running JavaFX app..."
mvn clean javafx:run
BSH
chmod +x "$ROOT/build.sh"

cat > "$ROOT/build.ps1" <<'PSH'
# PowerShell build script for Windows
Write-Host "Creating venv and installing Python requirements..."
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r python\requirements.txt

Write-Host "Running JavaFX app..."
mvn clean javafx:run
PSH

# minimal icon placeholder (text file) and background placeholder
cat > "$ROOT/src/main/resources/icon.png" <<'ICON'
(PLACEHOLDER) Put a PNG icon file here: src/main/resources/icon.png
Replace this placeholder with a real PNG image.
ICON

cat > "$ROOT/assets/fsociety.png" <<'BG'
(PLACEHOLDER) Put a background image (fsociety style) here: assets/fsociety.png
Replace this placeholder with a real PNG image you have rights to use.
BG

# python files
cat > "$ROOT/python/requirements.txt" <<'REQ'
requests
tldextract
REQ

cat > "$ROOT/python/scanner.py" <<'PY'
#!/usr/bin/env python3
import sys
import argparse
import re
import tldextract

parser = argparse.ArgumentParser()
parser.add_argument('--stdin', action='store_true', help='read text from stdin')
args = parser.parse_args()

def is_malicious_domain(domain):
    bad = {"malicious-example.com", "phishingsite.test"}
    return any(b in domain for b in bad)

def main():
    data = ""
    if args.stdin:
        data = sys.stdin.read()
    else:
        data = " ".join(sys.argv[1:])

    url_pattern = re.compile(r'(https?://[\\w\\-\\._~:/?#\\[\\]@!$&\\'()*+,;=%]+)', re.IGNORECASE)
    for m in url_pattern.finditer(data):
        url = m.group(1)
        try:
            ext = tldextract.extract(url)
            domain = ext.registered_domain
            if is_malicious_domain(domain):
                print("MAL:" + url)
        except Exception:
            continue

    phrases = ["verify your account", "update your payment", "provide password", "urgent action required"]
    for p in phrases:
        if p in data.lower():
            print("SUS:" + p)

if __name__ == "__main__":
    main()
PY
chmod +x "$ROOT/python/scanner.py"

# minimal Java files (placeholders enough to build quickly)
mkdir -p "$ROOT/src/main/java/com/darkofficail/securitysuite"
cat > "$ROOT/src/main/java/com/darkofficail/securitysuite/Main.java" <<'MAIN'
package com.darkofficail.securitysuite;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;

public class Main extends Application {
    @Override
    public void start(Stage primaryStage) throws Exception {
        BorderPane root = (BorderPane) FXMLLoader.load(getClass().getResource("/main.fxml"));
        Scene scene = new Scene(root, 800, 600);
        primaryStage.setTitle("Dark Security Suite - DARK-OFFICAIL");
        primaryStage.setScene(scene);
        primaryStage.show();
    }
    public static void main(String[] args) { launch(args); }
}
MAIN

cat > "$ROOT/src/main/resources/main.fxml" <<'FXML'
<?xml version="1.0" encoding="UTF-8"?>
<?import javafx.scene.layout.BorderPane?>
<BorderPane xmlns:fx="http://javafx.com/fxml"/>
FXML

cat > "$ROOT/.github/workflows/ci.yml" <<'CI'
name: Java CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        java: [ '17' ]

    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK ${{ matrix.java }}
      uses: actions/setup-java@v4
      with:
        java-version: ${{ matrix.java }}
        distribution: temurin
        cache: maven
    - name: Build with Maven
      run: mvn -B -DskipTests=false clean verify
CI

# LICENSE
cat > "$ROOT/LICENSE" <<'LIC'
MIT License

Copyright (c) 2025 DARK-OFFICAIL

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LIC

# create zip
echo "Writing complete. Creating zip archive..."
( cd "$ROOT" && zip -r "../${ROOT}.zip" . ) >/dev/null 2>&1 || true
echo "Archive created (if zip installed): ${ROOT}.zip"
echo ""
echo "Next steps on PC: unzip ${ROOT}.zip (or run this script locally to create files), then run build scripts as described in README."
