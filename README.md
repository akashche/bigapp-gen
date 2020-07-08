JNLP app generator
==================

Script that generates a JNLP application with the specified number of JARs (`JARS_COUNT` option) and classes inside each JAR (`CLASSES_COUNT` option). App entry point loads all the classes and makes simple arithmetic calculations.

    ./gen.sh
    # run directly
    java -cp './dist/*' Main
    # run webstart
    javaws ./dist/app.jnlp
