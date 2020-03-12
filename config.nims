##
## config.nims
##
## Adapted from https://scripter.co/nim-deploying-static-binaries/#code-snippet--musl-config-nims
##
from macros import error
from ospaths import splitFile, `/`

const releaseDir = "./dist/release/"

proc binOptimize(binFile: string) =
    echo ""
    if findExe("strip") != "":
        exec "strip --strip-all " & binFile
    else:
        echo "'strip' not found, continuing without"
    if findExe("upx") != "":
        exec "upx --best " & binFile
    else:
        echo "'upx' not found, continuing without"

task build, "Compiles a speed-optimized, static, stripped and minified binary":
    let
        numParams = paramCount()
    if numParams != 2:
        error("The 'build' sub-command needs exactly 1 argument, the Nim file (but " &
            $(numParams-1) & " were detected)." &
            "\n  Usage Example: nim build FILE.nim.")

    let
        nimFile = paramStr(numParams) ## The nim file name *must* be the last.
        (dirName, baseName, _) = splitFile(nimFile)
        binFile =  releaseDir / baseName 
        nimArgs = "compile -d:release --opt:speed --out:" & binFile & " " & nimFile

    # Build binary
    selfExec nimArgs

    # Optimize binary
    binOptimize(binFile)

    echo "\nCreated release binary: " & binFile
