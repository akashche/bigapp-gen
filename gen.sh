#!/bin/bash

set -e
#set -x

JARS_COUNT=2
CLASSES_COUNT=4

if [ -z "$JAVA_HOME" ] ; then
    echo "'JAVA_HOME' environment variable must be defined"
    exit 1
fi

rm -rf dist
rm -rf work
mkdir dist
mkdir work
pushd work

cat > ../dist/app.jnlp << EOL
<?xml version="1.0" encoding="utf-8"?>
<jnlp spec="1.0+">
    <information>
        <title>App</title>
        <vendor>App</vendor>
    </information>
    <resources>
        <jar href="app.jar" main="true" />
EOL

cat > Main.java << EOL
public class Main {
    public static void main(String[] args) {
        long count = 0;
EOL

javac_cp=.

for (( i = 1; i <= $JARS_COUNT; i++ )) ; do

mkdir entry$i
pushd entry$i

cat > Entry$i.java << EOL
public class Entry$i {
    public static long call(long count) {
EOL

for (( j = 1; j <= $CLASSES_COUNT; j++ )) ; do

cat > Class$i$j.java << EOL
class Class$i$j {
    static long call(long val) {
        return val + $i$j;
    } 
}
EOL

cat >> Entry$i.java << EOL
        count = Class$i$j.call(count);
EOL

done

cat >> Entry$i.java << EOL
        return count;
    }
}
EOL

"$JAVA_HOME"/bin/javac *.java
"$JAVA_HOME"/bin/jar -cf ../../dist/entry$i.jar *.class
javac_cp=$javac_cp:../dist/entry$i.jar

cat >> ../../dist/app.jnlp << EOL
        <jar href="entry$i.jar" main="false" />
EOL

popd

cat >> Main.java << EOL
        count = Entry$i.call(count);
EOL

done

cat >> Main.java << EOL
        System.out.println(count);
    }
}
EOL

"$JAVA_HOME"/bin/javac Main.java -g -cp $javac_cp
cat >> manifest.mf << EOL
Manifest-Version: 1.0
Main-Class: Main
EOL
"$JAVA_HOME"/bin/jar -cmf manifest.mf ../dist/app.jar Main.class

cat >> ../dist/app.jnlp << EOL
    </resources>
    <application-desc
         name="App"
         main-class="Main">
     </application-desc>
</jnlp>
EOL

popd
