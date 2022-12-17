# Shift-JIS でコード記述

######################
# 環境設定            #
######################

# ファイル出力時の文字コード設定
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

######################
# グローバル変数      #
######################
[String]$configSamplePath = Join-Path ( Convert-Path . ) 'config.json.sample'
[String]$configPath = Join-Path ( Convert-Path . ) 'config.json'
[String]$strCmd = 'git'

######################
# 関数               #
######################

##
# Find-ErrorMessage: エラーメッセージ組み立て
#
# @param {Int} $code: エラーコード
# @param {String} $someStr: 一部エラーメッセージで使用する文字列
#
# @return {String} $msg: 出力メッセージ
#
function Find-ErrorMessage([Int]$code, [String]$someStr) {
    $msg = ''
    $errMsgObj = [Hashtable]@{
        # 1x: 設定ファイル系
        11 = '設定ファイル (config.json) が存在しません。'
        12 = 'パラメータ文字列の長さが空です。'
        # 2x: 出力系
        21 = '出力先ディレクトリ ########## にアクセスできませんでした。'
        # 3x: 宛先
        31 = 'IPアドレス ########## の値が不正です。'
        # 9x: その他、処理中エラー
        99 = '##########'
    }
    $msg = $errMsgObj[$code]
    if ($someStr.Length -gt 0) {
        $msg = $msg.Replace('##########', $someStr)
    }

    return $msg
}
##
# Show-ErrorMessage: エラーメッセージ出力
#
# @param {Int} $code: エラーコード
# @param {Boolean} $exitFlag: exit するかどうかのフラグ
# @param {String} $someStr: 一部エラーメッセージで使用する文字列
#
function Show-ErrorMessage([Int]$code, [Boolean]$exitFlag, [String]$someStr) {
    $msg = Find-ErrorMessage $code $someStr
    Write-Host('ERROR ' + $code + ': ' + $msg) -BackgroundColor DarkRed
    Write-Host `r`n

    if ($exitFlag) {
        exit
    }
}

##
# Assert-ParamStrGTZero: パラメータ文字列長さチェック
#
# @param {String} $paramStr: ファイルパス
#
# @return {Boolean} : 文字長が0より大きければ True, そうでなければ False
#
function Assert-ParamStrGTZero([String]$paramStr) {
    return ($paramStr.Length -gt 0)
}
##
# Assert-IpAddressFormat: IPアドレス形式チェック
#
# @param {String} $ip: IPアドレス
#
# @return {Boolean} : IPアドレスが正しいと思しき形式ならば True, そうれなければ False
#
function Assert-IpAddressFormat([String]$ip) {
    return ($ip -match "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$")
}
##
# Assert-ExistFile: ファイル存在チェック
#
# @param {String} $filePath: ファイルパス
#
# @return {Boolean} : ファイルが存在すれば True, そうれなければ False
#
function Assert-ExistFile([String]$filePath) {
    return (Test-Path $filePath)
}

######################
# main process       #
######################

if (Assert-ExistFile $configPath) {
    Write-Host '処理を開始します ...'
    Write-Host `r`n

    # 設定ファイル読み込み
    $configData = Get-Content -Path $configPath -Raw -Encoding UTF8 | ConvertFrom-JSON
    # 出力先ディレクトリ
    if (-not (Assert-ParamStrGTZero $configData.resultOutput.path)) {
        Show-ErrorMessage 12 $True ''
    }
    # ファイル名
    if (-not (Assert-ParamStrGTZero $configData.resultOutput.baseFilename)) {
        Show-ErrorMessage 12 $True ''
    }
    # IPアドレスチェック
    if (-not (Assert-ParamStrGTZero $configData.address)) {
        Show-ErrorMessage 12 $True ''
    }
    if (-not (Assert-IpAddressFormat $configData.address)) {
        Show-ErrorMessage 31 $True $configData.address
    }
    $today = Get-Date -Format 'yyyyMMdd'
    $filename = $configData.resultOutput.baseFilename + '-' + $today + '.log'
    $outputDir = Join-Path ( Convert-Path . ) $configData.resultOutput.path
    $outputFile = Join-Path $outputDir $filename
    if (Assert-ExistFile $outputDir) {
        ping -t $configData.address | ?{$_ -ne ""} | %{(Get-Date).ToString() + " $_"} >> $outputFile
    }
    else {
        Show-ErrorMessage 21 $True $outputDir
    }
}
else {
    Show-ErrorMessage 11 $True $configPath
}
