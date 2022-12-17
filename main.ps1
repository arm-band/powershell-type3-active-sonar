# Shift-JIS �ŃR�[�h�L�q

######################
# ���ݒ�            #
######################

# �t�@�C���o�͎��̕����R�[�h�ݒ�
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

######################
# �O���[�o���ϐ�      #
######################
[String]$configSamplePath = Join-Path ( Convert-Path . ) 'config.json.sample'
[String]$configPath = Join-Path ( Convert-Path . ) 'config.json'
[String]$strCmd = 'git'

######################
# �֐�               #
######################

##
# Find-ErrorMessage: �G���[���b�Z�[�W�g�ݗ���
#
# @param {Int} $code: �G���[�R�[�h
# @param {String} $someStr: �ꕔ�G���[���b�Z�[�W�Ŏg�p���镶����
#
# @return {String} $msg: �o�̓��b�Z�[�W
#
function Find-ErrorMessage([Int]$code, [String]$someStr) {
    $msg = ''
    $errMsgObj = [Hashtable]@{
        # 1x: �ݒ�t�@�C���n
        11 = '�ݒ�t�@�C�� (config.json) �����݂��܂���B'
        12 = '�p�����[�^������̒�������ł��B'
        # 2x: �o�͌n
        21 = '�o�͐�f�B���N�g�� ########## �ɃA�N�Z�X�ł��܂���ł����B'
        # 3x: ����
        31 = 'IP�A�h���X ########## �̒l���s���ł��B'
        # 9x: ���̑��A�������G���[
        99 = '##########'
    }
    $msg = $errMsgObj[$code]
    if ($someStr.Length -gt 0) {
        $msg = $msg.Replace('##########', $someStr)
    }

    return $msg
}
##
# Show-ErrorMessage: �G���[���b�Z�[�W�o��
#
# @param {Int} $code: �G���[�R�[�h
# @param {Boolean} $exitFlag: exit ���邩�ǂ����̃t���O
# @param {String} $someStr: �ꕔ�G���[���b�Z�[�W�Ŏg�p���镶����
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
# Assert-ParamStrGTZero: �p�����[�^�����񒷂��`�F�b�N
#
# @param {String} $paramStr: �t�@�C���p�X
#
# @return {Boolean} : ��������0���傫����� True, �����łȂ���� False
#
function Assert-ParamStrGTZero([String]$paramStr) {
    return ($paramStr.Length -gt 0)
}
##
# Assert-IpAddressFormat: IP�A�h���X�`���`�F�b�N
#
# @param {String} $ip: IP�A�h���X
#
# @return {Boolean} : IP�A�h���X���������Ǝv�����`���Ȃ�� True, ������Ȃ���� False
#
function Assert-IpAddressFormat([String]$ip) {
    return ($ip -match "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$")
}
##
# Assert-ExistFile: �t�@�C�����݃`�F�b�N
#
# @param {String} $filePath: �t�@�C���p�X
#
# @return {Boolean} : �t�@�C�������݂���� True, ������Ȃ���� False
#
function Assert-ExistFile([String]$filePath) {
    return (Test-Path $filePath)
}

######################
# main process       #
######################

if (Assert-ExistFile $configPath) {
    Write-Host '�������J�n���܂� ...'
    Write-Host `r`n

    # �ݒ�t�@�C���ǂݍ���
    $configData = Get-Content -Path $configPath -Raw -Encoding UTF8 | ConvertFrom-JSON
    # �o�͐�f�B���N�g��
    if (-not (Assert-ParamStrGTZero $configData.resultOutput.path)) {
        Show-ErrorMessage 12 $True ''
    }
    # �t�@�C����
    if (-not (Assert-ParamStrGTZero $configData.resultOutput.baseFilename)) {
        Show-ErrorMessage 12 $True ''
    }
    # IP�A�h���X�`�F�b�N
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
